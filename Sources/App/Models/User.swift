import Fluent
import Vapor


final class User: Model {
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "username")
    var userName: String
    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String) {
        self.id = id
        self.name = name
        self.userName = username
    }
    
    static let schema = "users"
    
}
// what is this doing?
extension User: Content {}
