import Fluent
import Vapor

final class Category: Model {
    @ID // fluent knows it is model id
    var id: UUID?
    
    @Field(key: "name")
    var name: String
        
    @Siblings(through: AcronymCategoryPivot.self, from: \.$category, to: \.$acronym)
    var acronyms: [Acronym]
    
    // fluent uses empty init when construcing models from db
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
    static let schema = "categories"
}

extension Category: Content {}
