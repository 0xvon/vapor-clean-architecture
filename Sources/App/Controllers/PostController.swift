import Domain
import Endpoint
import Foundation
import Persistance
import Vapor

private func injectProvider<T, URI>(
    _ handler: @escaping (Request, URI, Domain.PostRepository) async throws -> T
)
    -> ((Request, URI) async throws -> T)
{
    return { req, uri in
        let repository = Persistance.PostRepository(db: req.db)
        return try await handler(req, uri, repository)
    }
}

struct PostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        try routes.on(endpoint: Endpoint.CreatePost.self, use: injectProvider { req, uri, repository in
            let useCase = CreatePostUseCase(repository: repository, eventLoop: req.eventLoop)
            let input = try req.content.decode(Endpoint.CreatePost.Request.self)
            return try await useCase((input))
        })
        try routes.on(endpoint: Endpoint.GetAllPosts.self, use: injectProvider { req, uri, repository in
            return try await repository.get(page: uri.page, per: uri.per)
        })
    }
}

extension Endpoint.Page: Content {}
extension Endpoint.Post: Content {}
