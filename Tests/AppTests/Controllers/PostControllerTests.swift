import Domain
import Endpoint
import StubKit
import XCTVapor

@testable import App

class PostControllerTests: XCTestCase {
    var app: Application!
    var appClient: AppClient!
    override func setUp() {
        app = Application(.testing)
        DotEnvFile.load(path: dotEnvPath.path)
        XCTAssertNoThrow(try configure(app))
        appClient = AppClient(application: app)
    }

    override func tearDown() {
        app.shutdown()
        app = nil
        appClient = nil
    }
    
    func testGetAllPosts() throws {
        _ = try appClient.createPost()
        try app.test(.GET, "posts?page=1&per=100", headers: appClient.makeHeaders()) { res in
            XCTAssertEqual(res.status, .ok, res.body.string)
            let response = try res.content.decode(GetAllPosts.Response.self)
            XCTAssertGreaterThanOrEqual(response.items.count, 1)
        }
    }
}
