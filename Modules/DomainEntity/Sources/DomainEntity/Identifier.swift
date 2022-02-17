import Foundation

public struct Identifier<Target>: Equatable, RawRepresentable, Codable, Hashable {
    public var rawValue: UUID
    public init(_ rawValue: UUID) {
        self.rawValue = rawValue
    }

    public init(rawValue: UUID) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(UUID.self)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Identifier: CustomStringConvertible {
    public var description: String { rawValue.uuidString }
}
