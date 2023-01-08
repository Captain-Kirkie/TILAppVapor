
import Fluent

struct CreateCategory: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        //MARK: User Table
        database.schema("categories")
            .id()
            .field("name", .string, .required)
            .create() // create the table
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories").delete() // delete category table
    }
    
}
