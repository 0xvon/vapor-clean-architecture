import Domain
import FluentKit
import Foundation

final class Post: Model {
    static let schema: String = "posts"
    @ID(key: .id)
    var id: UUID?

    @Field(key: "text")
    var text: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(
        id: UUID? = nil,
        text: String
    ) {
        self.id = id
        self.text = text
    }
}

extension Endpoint.Post {
    static func translate(fromPersistance entity: Post, on db: Database) async throws -> Self {
        let id = try entity.requireID()

        return Self.init(
            id: ID(id),
            text: entity.text,
            createdAt: entity.createdAt!
        )
    }
}
