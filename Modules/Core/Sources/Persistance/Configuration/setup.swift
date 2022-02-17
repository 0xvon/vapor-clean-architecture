import FluentKit
import FluentMySQLDriver

public protocol DatabaseSecrets {
    var databaseURL: String { get }
}

// configures persistance system
public func setup(
    databases: Databases,
    secrets: DatabaseSecrets
) throws {
    guard let databaseURL = URL(string: secrets.databaseURL),
        let config = MySQLConfiguration.certificateVerificationDisabled(url: databaseURL)
    else {
        fatalError("Invalid database url: \(secrets.databaseURL)")
    }
    databases.use(
        .mysql(configuration: config, connectionPoolTimeout: .minutes(1)), as: .mysql,
        isDefault: true)

}

public func setupMigration(
    migrator: Migrator,
    migrations: Migrations
) throws {
    migrations.add([
        CreatePost(),
    ])

    try migrator.setupIfNeeded().flatMap {
        migrator.prepareBatch()
    }.wait()
}

extension MySQLConfiguration {
    static func certificateVerificationDisabled(url: URL) -> Self? {
        guard url.scheme?.hasPrefix("mysql") == true else {
            return nil
        }
        guard let username = url.user else {
            return nil
        }
        guard let password = url.password else {
            return nil
        }
        guard let hostname = url.host else {
            return nil
        }
        let port = url.port ?? Self.ianaPortNumber

        let tlsConfiguration = TLSConfiguration.forClient(certificateVerification: .none)

        return self.init(
            hostname: hostname,
            port: port,
            username: username,
            password: password,
            database: url.path.split(separator: "/").last.flatMap(String.init),
            tlsConfiguration: tlsConfiguration
        )
    }
}
