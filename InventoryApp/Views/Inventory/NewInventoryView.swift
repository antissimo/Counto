import SwiftUI
import SwiftData

/// Core feature screen (spec section 7): instant search, big mic button,
/// list of items already scanned into the current inventory.
struct NewInventoryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NewInventoryViewModel

    init(inventory: Inventory, context: ModelContext) {
        _viewModel = StateObject(wrappedValue: NewInventoryViewModel(inventory: inventory, context: context))
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            if !viewModel.searchText.isEmpty {
                articleResultsList
            } else {
                addedItemsList
            }
        }
        .navigationTitle(viewModel.inventory.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Završi") {
                    viewModel.inventory.status = .completed
                    try? context.save()
                    dismiss()
                }
            }
        }
        .sheet(item: $viewModel.activeSheet) { sheet in
            switch sheet {
            case .quantity(let article, let existing):
                QuantityInputView(article: article, existingQuantity: existing) { quantity in
                    viewModel.confirmQuantity(article: article, quantity: quantity)
                }
            case .voiceConfirmation:
                VoiceConfirmationView(
                    candidates: viewModel.voiceCandidates,
                    parsedQuantity: viewModel.voiceParsedQuantity,
                    rawTranscript: viewModel.voiceRawTranscript,
                    onConfirm: viewModel.confirmVoiceMatch,
                    onCancel: viewModel.cancelVoice
                )
            }
        }
        .alert("Greška", isPresented: Binding(
            get: { viewModel.voiceErrorMessage != nil },
            set: { isPresented in
                if !isPresented { viewModel.voiceErrorMessage = nil }
            }
        )) {
            Button("U redu") { viewModel.voiceErrorMessage = nil }
        } message: {
            Text(viewModel.voiceErrorMessage ?? "")
        }
        .onAppear { viewModel.loadArticles() }
    }

    @ViewBuilder
    private var searchBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Pretraži artikle", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Button {
                    viewModel.toggleVoiceRecording()
                } label: {
                    Image(systemName: viewModel.isRecording ? "mic.fill" : "mic")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(viewModel.isRecording ? Color.red : Color.accentColor)
                        .clipShape(Circle())
                }
            }

            if viewModel.isRecording {
                HStack(spacing: 6) {
                    Circle().fill(Color.red).frame(width: 10, height: 10)
                    Text("Slušam...")
                        .font(.subheadline.bold())
                        .foregroundStyle(.red)
                    Spacer()
                }
            }
        }
        .padding()
    }

    private var articleResultsList: some View {
        List(viewModel.filteredArticles) { article in
            Button {
                viewModel.selectArticle(article)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(article.code)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var addedItemsList: some View {
        if viewModel.items.isEmpty {
            ContentUnavailableView(
                "Nema dodanih artikala",
                systemImage: "shippingbox",
                description: Text("Pretražite ili izgovorite artikl za dodavanje u inventuru.")
            )
        } else {
            List(viewModel.items) { item in
                HStack {
                    Text(item.article?.name ?? "Nepoznat artikl")
                    Spacer()
                    Text(formatQuantity(item.quantity))
                        .font(.body.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let article = item.article {
                        viewModel.selectArticle(article)
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private func formatQuantity(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.2f", value)
    }
}
