import Foundation
import SwiftData

@Model
final class InventoryItem {
    @Attribute(.unique) var id: UUID
    var quantity: Double
    var inventory: Inventory?
    var article: Article?

    init(
        id: UUID = UUID(),
        quantity: Double,
        inventory: Inventory? = nil,
        article: Article? = nil
    ) {
        self.id = id
        self.quantity = quantity
        self.inventory = inventory
        self.article = article
    }
}
