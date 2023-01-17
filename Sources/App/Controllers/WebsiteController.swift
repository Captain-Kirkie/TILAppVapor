
import Vapor
struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: indexHandler)
    }
    
    func indexHandler(_ req: Request) throws -> EventLoopFuture<View> {
        Acronym.query(on: req.db).all().flatMap{ acronyms in
            let context = IndexContext(title: "Homepage", acronyms: acronyms.isEmpty ? nil : acronyms)
            return req.view.render("index", context)
        }
       
    }
}

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}
