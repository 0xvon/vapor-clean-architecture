import Foundation
import NIO

public struct CreatePostUseCase: UseCase {
    public typealias Request = CreatePost.Request
    public typealias Response = Post
    public let repository: PostRepository
    public let eventLoop: EventLoop

    public init(
        repository: PostRepository,
        eventLoop: EventLoop
    ) {
        self.repository = repository
        self.eventLoop = eventLoop
    }

    public func callAsFunction(_ request: Request) async throws -> Response {
        return try await repository.create(input: request)
    }
}
