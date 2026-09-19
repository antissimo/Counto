import SwiftUI

/// Simple quantity entry sheet (spec section 9). Supports decimals,
/// pre-fills the existing quantity when the article is already in this
/// inventory (spec section 10 — duplicate prevention).
struct QuantityInputView: View {
    let article: Article
    let existingQuantity: Double?
    let onConfirm: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var quantityText: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(article.name)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 32)

                if let existingQuantity {
                    Text("Trenutno: \(formatQuantity(existingQuantity))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                TextField("Količina", text: $quantityText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 32)
                    .focused($isFocused)

                Spacer()

                Button {
                    submit()
                } label: {
                    Text("DODAJ")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid ? Color.accentColor : Color.gray.opacity(0.4))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!isValid)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Odustani") { dismiss() }
                }
            }
            .onAppear {
                if let existingQuantity {
                    quantityText = formatQuantity(existingQuantity)
                }
                isFocused = true
            }
        }
    }

    private var normalizedText: String {
        quantityText.replacingOccurrences(of: ",", with: ".")
    }

    private var isValid: Bool {
        guard let value = Double(normalizedText) else { return false }
        return value > 0
    }

    private func submit() {
        guard let value = Double(normalizedText) else { return }
        onConfirm(value)
    }

    private func formatQuantity(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.2f", value)
    }
}
