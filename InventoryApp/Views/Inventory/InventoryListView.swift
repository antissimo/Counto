import SwiftUI
import SwiftData

struct InventoryListView: View {
    @Query(sort: \Inventory.createdAt, order: .reverse) private var inventories: [Inventory]

    var body: some View {
        List(inventories) { inventory in
            NavigationLink(value: inventory) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(inventory.name)
                        .font(.body.weight(.medium))
                    Text("\(inventory.items.count) artikala · \(inventory.status.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Inventure")
        .navigationDestination(for: Inventory.self) { inventory in
            InventoryDetailView(inventory: inventory)
        }
        .overlay {
            if inventories.isEmpty {
                ContentUnavailableView(
                    "Nema inventura",
                    systemImage: "archivebox",
                    description: Text("Napravite novu inventuru na početnom ekranu.")
                )
            }
        }
    }
}
