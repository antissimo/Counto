import SwiftUI
import SwiftData

/// Home screen: exactly 3 big options, no dashboard, no charts
/// (spec section 2).
struct HomeView: View {
    @Environment(\.modelContext) private var context
    @State private var activeInventory: Inventory?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 6) {
                    Text("Inventura")
                        .font(.largeTitle.bold())
                    Text("Brz unos, bez nepotrebnih koraka")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 16) {
                    BigActionButton(title: "NOVA INVENTURA", systemImage: "plus.circle.fill", style: .primary) {
                        startNewInventory()
                    }

                    NavigationLink {
                        InventoryListView()
                    } label: {
                        BigActionButtonLabel(title: "INVENTURE", systemImage: "archivebox.fill", style: .secondary)
                    }

                    NavigationLink {
                        DataView()
                    } label: {
                        BigActionButtonLabel(title: "PODACI", systemImage: "tray.full.fill", style: .secondary)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
                Spacer()
            }
            .navigationDestination(item: $activeInventory) { inventory in
                NewInventoryView(inventory: inventory, context: context)
            }
        }
    }

    private func startNewInventory() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy."
        let name = "Inventura — \(formatter.string(from: .now))"

        let inventory = Inventory(name: name)
        context.insert(inventory)
        try? context.save()

        activeInventory = inventory
    }
}
