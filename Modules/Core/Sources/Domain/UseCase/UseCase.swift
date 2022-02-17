import Foundation
import NIO

public protocol UseCase {
    associatedtype Request
    associatedtype Response

    func callAsFunction(_ request: Request) async throws -> Response
}

public struct AnyUseCase<Request, Response>: UseCase {
    private let _callAsFunction: (_ request: Request) async throws -> Response

    public init<U: UseCase>(_ useCase: U) where U.Request == Request, U.Response == Response {
        _callAsFunction = useCase.callAsFunction
    }

    public func callAsFunction(_ request: Request) async throws -> Response {
        try await _callAsFunction(request)
    }
}
