import Foundation
import SwiftData

@Model
final class Article {
    @Attribute(.unique) var id: UUID
    var code: String
    var name: String
    var unitOfMeasure: UnitOfMeasure?
    var category: Category?

    init(
        id: UUID = UUID(),
        code: String,
        name: String,
        unitOfMeasure: UnitOfMeasure? = nil,
        category: Category? = nil
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.unitOfMeasure = unitOfMeasure
        self.category = category
    }
}
