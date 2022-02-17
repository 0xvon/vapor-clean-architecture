import Domain
import Endpoint
import FluentKit

public class PostRepository: Domain.PostRepository {
    private let db: Database
    public enum Error: Swift.Error {
        case notFound
    }

    public init(db: Database) {
        self.db = db
    }

    public func create(input: Endpoint.CreatePost.Request) async throws -> Domain.Post {
        let post = Post(text: input.text)
        try await post.create(on: db)
        return try await Domain.Post.translate(fromPersistance: post, on: db)
    }

    public func get(page: Int, per: Int) async throws -> Domain.Page<Domain.Post> {
        let posts = try await Post.query(on: db)
            .sort(\.$createdAt)
            .paginate(PageRequest(page: page, per: per))

        return try await Domain.Page<Domain.Post>.translate(page: posts) { post in
            try await Domain.Post.translate(fromPersistance: post, on: db)
        }
    }
}
