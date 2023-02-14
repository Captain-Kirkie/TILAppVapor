import Fluent
import FluentPostgresDriver
import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory)) // for serving static files?
    app.logger.logLevel = .debug
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    
    // add user
    // must create user before Acronym because acronym refers to it
    app.migrations.add(CreateUser())
    
    
    // add table, run acronym migration
    app.migrations.add(CreateAcronym())

    // add category
    app.migrations.add(CreateCategory())
    
    // AcronymCategoryPivot
    app.migrations.add(CreateAcronymCategoryPivot())
    
    // token table
    app.migrations.add(CreateToken())
    
    // register routes
    try routes(app)
    
    try app.autoMigrate().wait() // run the migration on every app launch
    
    app.views.use(.leaf)
}
