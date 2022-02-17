import CodableURL
import Foundation

extension Identifier: ExpressibleByURLComponent {
    public init?(urlComponent: String) {
        guard let rawValue = UUID(uuidString: urlComponent) else { return nil }
        self.init(rawValue: rawValue)
    }

    public var urlComponent: String? {
        rawValue.uuidString
    }
}
