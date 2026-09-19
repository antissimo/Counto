import SwiftUI

/// Confirmation screen after voice recognition (spec sections 12-13).
/// Shows the single high-confidence match with POTVRDI/PROMIJENI, or a
/// disambiguation list ("Jeste li mislili...") when confidence is low.
/// The AI layer never writes to the inventory directly — only this screen,
/// on explicit user confirmation, does.
struct VoiceConfirmationView: View {
    let candidates: [ArticleMatch]
    let parsedQuantity: Double?
    let rawTranscript: String
    let onConfirm: (ArticleMatch) -> Void
    let onCancel: () -> Void

    private var topMatch: ArticleMatch? { candidates.first }

    private var isHighConfidence: Bool {
        guard let top = topMatch else { return false }
        guard candidates.count > 1 else { return top.confidence > 0.6 }
        return top.confidence > 0.75 && (top.confidence - candidates[1].confidence) > 0.15
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Prepoznato")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 24)

                if !rawTranscript.isEmpty {
                    Text("\"\(rawTranscript)\"")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if isHighConfidence, let match = topMatch {
                    highConfidenceContent(match: match)
                } else {
                    disambiguationContent
                }
            }
        }
    }

    @ViewBuilder
    private func highConfidenceContent(match: ArticleMatch) -> some View {
        VStack(spacing: 12) {
            Text(match.article.name)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            if let parsedQuantity {
                Text("\(formatQuantity(parsedQuantity)) \(match.article.unitOfMeasure?.name ?? "")")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()

        Spacer()

        VStack(spacing: 12) {
            Button {
                onConfirm(match)
            } label: {
                Text("POTVRDI")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button(role: .destructive) {
                onCancel()
            } label: {
                Text("PROMIJENI")
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }

    @ViewBuilder
    private var disambiguationContent: some View {
        Text("Jeste li mislili:")
            .font(.subheadline)
            .foregroundStyle(.secondary)

        List(candidates, id: \.article.id) { match in
            Button {
                onConfirm(match)
            } label: {
                HStack {
                    Text(match.article.name)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(Int(match.confidence * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.plain)

        Button("Odustani", role: .cancel) {
            onCancel()
        }
        .padding(.bottom, 24)
    }

    private func formatQuantity(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.2f", value)
    }
}
