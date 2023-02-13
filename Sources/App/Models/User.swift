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
    
    @Field(key: "password")
    var password: String
    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String, password: String) {
        self.id = id
        self.name = name
        self.userName = username
        self.password = password
    }
    
    // public facing user... no password
    struct Public: Content {
        var id: UUID?
        var name: String
        var username: String
    }
    
    static let schema = "users"
    
}
// what is this doing?
// make new model conform to content
extension User: Content {
    func convertToPublic() -> User.Public {
        User.Public(id: self.id, name: self.name, username: self.userName)
    }
}
// convert future user into future public.user
extension EventLoopFuture where Value: User {
    func convertToPublic() -> EventLoopFuture<User.Public> {
        self.map { user in
            user.convertToPublic()
        }
    }
}

// convert array of users to array of public users
extension Collection where Element: User {
    func convertToPublic() -> [User.Public] {
        self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<User> {
    func convertToPublic() -> EventLoopFuture<[User.Public]> {
        self.map { $0.convertToPublic() }
    }
}
