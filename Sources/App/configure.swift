import Vapor
import Authentication
import FluentMySQL
import Leaf


/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())
    services.register(PrivateFileMiddleware.self)
//    let mailConfig = MailgunConfig(apiKey: "SG.something", domain: "mg.example.com")
//    services.register(mailConfig)
    try services.register(MailgunProvider())
    try services.register(LeafProvider())
    services.register { container -> LeafTagConfig in
        var config = LeafTagConfig.default()
        config.use(DateFormat(), as: "formatDate")
        config.use(ConfigValueTag(), as: "configValueFor")
        return config
    }
    /// Register routes to the router
    try services.register(AuthenticationProvider())
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(PrivateFileMiddleware.self)
//    middlewares.use(BasicAuthenticationMiddleware<User>.self)
    services.register(middlewares)
    // Configure a MySQL database

    var databases = DatabasesConfig()
    if env == .testing {
        databases.add(database: Bespin.BespinTest, as: .Bespin)
    } else {
        databases.add(database: Bespin.Bespin, as: .Bespin)
    }
    
    
    services.register(databases)
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: EmailTemplate.self, database: .Bespin)
    migrations.add(model: Token.self, database: .Bespin)
    migrations.add(model: User.self, database: .Bespin)
    services.register(migrations)

    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}
