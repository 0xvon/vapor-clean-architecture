import Domain
import NIO

private func unimplemented(
    function: StaticString = #function,
    file: StaticString = #file, line: UInt = #line
) -> Never {
    fatalError("unimplemented \"\(function)\"", file: file, line: line)
}

protocol PostRepositoryMock: PostRepository {}
extension PostRepositoryMock {
    func create(input: CreatePost.Request) async throws -> Post {
        unimplemented()
    }
    func get(page: Int, per: Int) async throws -> Page<Post> {
        unimplemented()
    }
}
