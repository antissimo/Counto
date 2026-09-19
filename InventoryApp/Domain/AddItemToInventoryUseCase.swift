import Foundation
import SwiftData

/// Adds an article + quantity to an inventory, or updates the quantity if the
/// article was already scanned/entered in this inventory (duplicate prevention,
/// spec section 10 — default behaviour is to REPLACE the existing quantity).
@MainActor
struct AddItemToInventoryUseCase {
    let context: ModelContext

    func execute(inventory: Inventory, article: Article, quantity: Double) {
        if let existing = inventory.items.first(where: { $0.article?.id == article.id }) {
            existing.quantity = quantity
        } else {
            let item = InventoryItem(quantity: quantity, inventory: inventory, article: article)
            context.insert(item)
        }
        try? context.save()
    }
}
