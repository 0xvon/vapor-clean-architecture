@_exported import CodableURL

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

public protocol EndpointProtocol {
    associatedtype Request: Codable
    associatedtype Response: Codable
    associatedtype URI: CodableURL

    static var method: HTTPMethod { get }
}

public struct Empty: Codable {
    public init() {}
}

public protocol PaginationQuery {
    /// Current page number. Starts at `1`.
    var page: Int { get set }

    /// Max items per page.
    var per: Int { get set }
}

public struct PageMetadata: Codable {
    /// Current page number. Starts at `1`.
    public let page: Int

    /// Max items per page.
    public let per: Int

    /// Total number of items available.
    public let total: Int

    public init(page: Int, per: Int, total: Int) {
        self.page = page
        self.per = per
        self.total = total
    }
}

public struct Page<Item>: Codable where Item: Codable {
    public let items: [Item]
    public let metadata: PageMetadata

    public init(items: [Item], metadata: PageMetadata) {
        self.items = items
        self.metadata = metadata
    }
}
