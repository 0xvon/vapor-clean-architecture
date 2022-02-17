import DomainEntity
import Fluent
import FluentMySQLDriver
import Persistance
import Vapor
import JWTKit
import Foundation

protocol Secrets: DatabaseSecrets {
}

public struct EnvironmentSecrets: Secrets {
    public init() {
        func require(_ key: String) -> String {
            guard let value = Environment.get(key) else {
                fatalError("Please set \"\(key)\" environment variable")
            }
            return value
        }
        self.databaseURL = require("DATABASE_URL")
    }
    public let databaseURL: String
}

extension Application {
    struct SecretsKey: StorageKey {
        typealias Value = Secrets
    }
    var secrets: Secrets {
        get {
            guard let secrets = storage[SecretsKey.self] else {
                fatalError("Please set app.secrets")
            }
            return secrets
        }
        set { storage[SecretsKey.self] = newValue }
    }
}

public func configure(
    _ app: Application,
    secrets: EnvironmentSecrets = EnvironmentSecrets(),
    authenticator: Authenticator? = nil
) throws {
    app.secrets = secrets
    try Persistance.setup(
        databases: app.databases,
        secrets: secrets
    )
    try Persistance.setupMigration(
        migrator: app.migrator,
        migrations: app.migrations
    )
    try routes(app)
}
