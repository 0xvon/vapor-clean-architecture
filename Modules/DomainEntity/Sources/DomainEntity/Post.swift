import Foundation

public struct Post: Codable, Equatable {
    public typealias ID = Identifier<Self>
    public var id: ID
    public var text: String
    public var createdAt: Date

    public init(
        id: Post.ID,
        text: String,
        createdAt: Date
    ) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}