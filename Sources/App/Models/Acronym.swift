import Fluent
import Vapor


final class Acronym: Model {
    @ID // fluent knows it is model id
    var id: UUID?
    
    @Field(key: "short")
    var short: String
    
    @Field(key: "long")
    var long: String
    
    // one user owns many acronyms, acronymns only have one user
    // bulding a one to one relationship from acronym -> user
    // one to many relationshisp user -> acronym
    @Parent(key: "userID")
    var user: User
    
    // fluent uses empty init when construcing models from db
    init() {}
    
    init(id: UUID? = nil, short: String, long: String, userID: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID // set id on userobject... dont replace user
    }
    
    static let schema = "acronyms"
}

extension Acronym: Content {}
