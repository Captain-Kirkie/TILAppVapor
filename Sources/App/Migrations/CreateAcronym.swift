import Fluent


struct CreateAcronym: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        //MARK: Acronym Table
        database.schema("acronyms") // matches schema name in model
            .id() // add fields, create table
            .field("short", .string, .required)
            .field("long", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms").delete() // delete acronyms table
    }
    
}
