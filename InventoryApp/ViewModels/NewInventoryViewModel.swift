import Foundation
import SwiftData

enum ActiveSheet: Identifiable {
    case quantity(Article, existingQuantity: Double?)
    case voiceConfirmation

    var id: String {
        switch self {
        case .quantity(let article, _):
            return "quantity-\(article.id)"
        case .voiceConfirmation:
            return "voiceConfirmation"
        }
    }
}

/// Drives the core "Nova inventura" screen: instant search, manual quantity
/// entry, and the full voice pipeline (record → transcribe → parse →
/// match → confirm). This is the only screen with a dedicated ViewModel —
/// the simple CRUD screens use SwiftData's @Query directly.
@MainActor
final class NewInventoryViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var activeSheet: ActiveSheet?
    @Published var isRecording: Bool = false
    @Published var voiceCandidates: [ArticleMatch] = []
    @Published var voiceParsedQuantity: Double?
    @Published var voiceRawTranscript: String = ""
    @Published var voiceErrorMessage: String?
    @Published private(set) var items: [InventoryItem] = []
    @Published private var allArticles: [Article] = []

    let inventory: Inventory
    private let context: ModelContext
    private let speechService: SpeechRecognitionService

    init(
        inventory: Inventory,
        context: ModelContext,
        speechService: SpeechRecognitionService = SpeechRecognitionService()
    ) {
        self.inventory = inventory
        self.context = context
        self.speechService = speechService
        loadArticles()
        refreshItems()
    }

    func loadArticles() {
        let descriptor = FetchDescriptor<Article>(sortBy: [SortDescriptor(\.name)])
        allArticles = (try? context.fetch(descriptor)) ?? []
    }

    var filteredArticles: [Article] {
        SearchArticlesUseCase.search(searchText, in: allArticles)
    }

    private func refreshItems() {
        items = inventory.items.sorted { ($0.article?.name ?? "") < ($1.article?.name ?? "") }
    }

    func existingQuantity(for article: Article) -> Double? {
        inventory.items.first(where: { $0.article?.id == article.id })?.quantity
    }

    func selectArticle(_ article: Article) {
        activeSheet = .quantity(article, existingQuantity: existingQuantity(for: article))
    }

    func confirmQuantity(article: Article, quantity: Double) {
        AddItemToInventoryUseCase(context: context).execute(inventory: inventory, article: article, quantity: quantity)
        refreshItems()
        activeSheet = nil
        searchText = ""
    }

    // MARK: - Voice

    func toggleVoiceRecording() {
        if speechService.isRecording {
            stopVoiceRecording()
        } else {
            startVoiceRecording()
        }
    }

    private func startVoiceRecording() {
        voiceErrorMessage = nil
        speechService.requestAuthorization { [weak self] granted in
            guard let self else { return }
            if granted {
                self.isRecording = true
                self.speechService.startRecording()
            } else {
                self.voiceErrorMessage = self.speechService.authorizationError ?? "Pristup mikrofonu nije odobren."
            }
        }
    }

    private func stopVoiceRecording() {
        speechService.stopRecording()
        isRecording = false
        processVoiceResult()
    }

    private func processVoiceResult() {
        let transcript = speechService.transcript
        voiceRawTranscript = transcript

        guard !transcript.isEmpty else {
            voiceErrorMessage = "Nije prepoznat govor. Pokušajte ponovno."
            return
        }

        let parsed = VoiceCommandParser.parse(transcript: transcript)
        voiceParsedQuantity = parsed.quantity

        let matches = ArticleMatcher.match(text: parsed.articleText, in: allArticles)
        voiceCandidates = Array(matches.prefix(3))

        if voiceCandidates.isEmpty {
            voiceErrorMessage = "Artikl nije prepoznat. Pokušajte ponovno ili pretražite ručno."
            return
        }

        activeSheet = .voiceConfirmation
    }

    func confirmVoiceMatch(_ match: ArticleMatch) {
        guard let quantity = voiceParsedQuantity else {
            let article = match.article
            resetVoiceState()
            activeSheet = .quantity(article, existingQuantity: existingQuantity(for: article))
            return
        }
        confirmQuantity(article: match.article, quantity: quantity)
        resetVoiceState()
    }

    func cancelVoice() {
        activeSheet = nil
        resetVoiceState()
    }

    private func resetVoiceState() {
        voiceCandidates = []
        voiceParsedQuantity = nil
        voiceRawTranscript = ""
    }
}
