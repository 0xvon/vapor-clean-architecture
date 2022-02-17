import NIO
import StubKit
import XCTest

@testable import Domain

enum Expect<Success> {
    case success((Success) throws -> Void)
    case failure((Error) throws -> Void)

    func receive<E>(result: Result<Success, E>) throws {
        switch (self, result) {
        case (let .success(matcher), let .success(value)):
            try matcher(value)
        case (let .failure(matcher), let .failure(error)):
            try matcher(error)
        case (.failure(_), .success(_)):
            XCTFail("expect failure but got success")
        case (.success(_), .failure(_)):
            XCTFail("expect success but got failure")
        }
    }
}

class CreatePostUseCaseTests: XCTestCase {
    func testCreate() async throws {
         class Mock: PostRepositoryMock {
             let eventLoop: EventLoop
             func create(input: CreatePost.Request) async throws -> Post {
                 let post = try! Stub.make(Post.self)
                 return post
             }
             
             init(
                eventLoop: EventLoop
             ) {
                 self.eventLoop = eventLoop
             }
         }
         let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
         let mock = Mock(eventLoop: eventLoopGroup.next())
         
         typealias Input = (
             request: CreatePostUseCase.Request,
             expect: Expect<CreatePostUseCase.Response>
         )
         
         let input: Input = try! (
            request: Stub.make(),
            expect: .success { res in
                XCTAssertNotNil(res.id)
            }
         )
         
         let useCase = CreatePostUseCase(
             repository: mock,
             eventLoop: eventLoopGroup.next()
         )
         let response = try await useCase((input.request))
         try input.expect.receive(result: Result { response })
     }
}
