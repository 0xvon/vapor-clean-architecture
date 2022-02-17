import Endpoint
import StubKit
import Vapor

class AppClient {
    let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private let app: Application
    init(application: Application) {
        self.app = application
    }
    
    func makeHeaders() -> HTTPHeaders {
        makeHeaders(for: "xxxxxx")
    }

    func makeHeaders(for token: String) -> HTTPHeaders {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(token)")
        headers.add(name: .contentType, value: HTTPMediaType.json.serialize())
        return headers
    }
    
    func createPost(
        text: String = "some posts. some posts. some posts. some posts. some posts. some posts. some posts."
    ) throws -> Endpoint.Post {
        let body: CreatePost.Request = try! Stub.make() {
            $0.set(\.text, value: text)
        }
        let bodyData = try ByteBuffer(data: encoder.encode(body))
        var post: Endpoint.Post!
        try app.test(.POST, "posts/create", headers: makeHeaders(), body: bodyData) { res in
            post = try res.content.decode(Endpoint.Post.self)
        }
        return post
    }
}
