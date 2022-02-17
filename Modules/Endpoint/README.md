# Endpoint

APIエンドポイントのI/O, path, methodを定義するモジュール
VaporやSwiftNIOなどServer Side Swift向けライブラリ依存が入らないようにしている


ex.)

```swift
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
```