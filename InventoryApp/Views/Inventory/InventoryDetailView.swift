import SwiftUI

struct InventoryDetailView: View {
    let inventory: Inventory

    private var sortedItems: [InventoryItem] {
        inventory.items.sorted { ($0.article?.name ?? "") < ($1.article?.name ?? "") }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Datum")
                    Spacer()
                    Text(inventory.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Status")
                    Spacer()
                    Text(inventory.status.rawValue)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Broj artikala")
                    Spacer()
                    Text("\(inventory.items.count)")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Artikli") {
                ForEach(sortedItems) { item in
                    HStack {
                        Text(item.article?.name ?? "Nepoznat artikl")
                        Spacer()
                        Text(formatQuantity(item.quantity))
                            .font(.body.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(inventory.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatQuantity(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.2f", value)
    }
}
