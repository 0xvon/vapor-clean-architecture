public struct GetAllPosts: EndpointProtocol {
    public typealias Request = Empty
    public typealias Response = Page<Post>
    public struct URI: CodableURL, PaginationQuery {
        @StaticPath("posts") public var prefix: Void
        @Query public var page: Int
        @Query public var per: Int
        public init() {}
    }
    public static let method: HTTPMethod = .get
}

public struct CreatePost: EndpointProtocol {
    public struct Request: Codable {
        public var text: String

        public init(
            text: String
        ) {
            self.text = text
        }
    }

    public typealias Response = Post
    public struct URI: CodableURL {
        @StaticPath("posts", "create") public var prefix: Void
        public init() {}
    }
    public static let method: HTTPMethod = .post
}