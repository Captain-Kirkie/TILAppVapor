import Fluent


struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        //MARK: User Table
        database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .field("password", .string, .required)
            .create() // create the table
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete() // delete user table
    }
    
}
