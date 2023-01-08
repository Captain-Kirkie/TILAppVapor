import Fluent
import Vapor


final class Acronym: Model {
    @ID // fluent knows it is model id
    var id: UUID?
    
    @Field(key: "short")
    var short: String
    
    @Field(key: "long")
    var long: String
    
    // fluent uses empty init when construcing models from db
    init() {}
    
    init(id: UUID? = nil, short: String, long: String) {
        self.id = id
        self.short = short
        self.long = long
    }
    
    static let schema = "acronyms"
}

extension Acronym: Content {}
