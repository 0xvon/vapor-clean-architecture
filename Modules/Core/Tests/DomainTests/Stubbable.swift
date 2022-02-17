import Endpoint
import Foundation
import StubKit

extension Identifier: Stubbable {
    public static func stub() -> Identifier<Target> {
        Self(UUID())
    }
}
