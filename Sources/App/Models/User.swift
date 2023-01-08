import Fluent
import Vapor


final class User: Model {
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "username")
    var userName: String
    
    // user has one to many relationship with Acronym.... a user can hold many acronymsØ
    @Children(for: \.$user)
    var acronyms: [Acronym]
    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String) {
        self.id = id
        self.name = name
        self.userName = username
    }
    
    static let schema = "users"
    
}
// what is this doing?
// make new model conform to content
extension User: Content {}
