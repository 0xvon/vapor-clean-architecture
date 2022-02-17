import Domain
import FluentKit
import Foundation
import MySQLNIO

struct CreatePost: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Post.schema)
            .id()
            .field("text", .string, .required)
            .field("created_at", .datetime, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Post.schema).delete()
    }
}
