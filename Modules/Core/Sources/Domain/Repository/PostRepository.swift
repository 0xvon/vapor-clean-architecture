import Foundation
import NIO

public protocol PostRepository {
    func create(input: CreatePost.Request) async throws -> Post
    func get(page: Int, per: Int) async throws -> Page<Post>
}
