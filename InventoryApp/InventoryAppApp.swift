import SwiftUI
import SwiftData

@main
struct InventoryAppApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            Article.self,
            UnitOfMeasure.self,
            Category.self,
            Inventory.self,
            InventoryItem.self
        ])
        let configuration = ModelConfiguration(schema: schema)

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Ne mogu inicijalizirati SwiftData spremište: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(container)
    }
}
