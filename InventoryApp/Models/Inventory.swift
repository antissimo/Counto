import Foundation
import SwiftData

enum InventoryStatus: String, Codable {
    case inProgress = "U tijeku"
    case completed = "Završena"
}

@Model
final class Inventory {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var name: String
    var statusRaw: String

    @Relationship(deleteRule: .cascade, inverse: \InventoryItem.inventory)
    var items: [InventoryItem] = []

    var status: InventoryStatus {
        get { InventoryStatus(rawValue: statusRaw) ?? .inProgress }
        set { statusRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        name: String,
        status: InventoryStatus = .inProgress
    ) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.statusRaw = status.rawValue
    }
}
