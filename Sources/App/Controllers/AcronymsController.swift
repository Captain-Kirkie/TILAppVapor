import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws { // boot comes from RouteCollection, configures routes
        let acronymsRoutes = routes.grouped("api", "acronyms") // everything behind /api/acronyms
        acronymsRoutes.get(use: getAllHandler) // GET all
        acronymsRoutes.get(":acronymID", use: getHandler) // get based on acronym
        
        
        
        // get a user from an acronym
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
        
        // get categories from an acronym
        acronymsRoutes.get(":acronymID", "categories", use: getCategoriesHandler)
        
        // add categories
        acronymsRoutes.post(":acronymID","categories", ":categoryID", use: addCategoriesHandler)
        
        // handle search
        acronymsRoutes.get("search", use: searchHandler)
        
        let tokenAuthMiddleWare = Token.authenticator() // converts token into authenticated user
        let guardAuthMiddleWare = User.guardMiddleware() // ensure authenticated user is present
        let tokenAuthGroup = acronymsRoutes.grouped(tokenAuthMiddleWare, guardAuthMiddleWare)
        
        
        // adding token protected routes.
        tokenAuthGroup.post(use: createHandler) // post request to create and acronym
        tokenAuthGroup.put(":acronymID", use: updateHandler) // PUT method to update based on ID
        tokenAuthGroup.delete(":acronymID", use: deleteHandler) // delete based on UUID
        
        
        
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self) // decode it
        let user = try req.auth.require(User.self)
        let acronym = try Acronym(short: data.short, long: data.long, userID: user.requireID())
        return acronym.save(on: req.db).map { acronym }
    }
    
    func getHandler(_ req : Request) throws -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)) // return 404 if you dont find acronym
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // flat map takes future, returns different future when execution completes
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap {acronym in
            acronym.delete(on: req.db).transform(to: .noContent)
        }
    }
    // updates acronym and return updated acronym
    func updateHandler (_ req : Request) throws -> EventLoopFuture<Acronym> {
        let updatedAcronym = try req.content.decode(CreateAcronymData.self)
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        return Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updatedAcronym.short
                acronym.long = updatedAcronym.long
                acronym.$user.id = userID
                return acronym.save(on: req.db).map { acronym }
            }
    }
    
    func getUserHandler(_ req : Request) throws -> EventLoopFuture<User.Public> {
        // get uses future.... use flatmap
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap{ acronym in
            acronym.$user.get(on: req.db).convertToPublic()
        }
    }
    
    func getCategoriesHandler(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { acronym in
            acronym.$categories.get(on: req.db)
        }
    }
    
    func addCategoriesHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
        
        let categoryQuery = Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound))
        
        return acronymQuery.and(categoryQuery).flatMap { acronym, category in
            // create a link between models
            acronym.$categories.attach(category, on: req.db).transform(to: .created)
        }
    }
    
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        // looking for term search param
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        print(searchTerm)
        // groups used for or terms?
       // importing fluent lets you use the syntactic sugar
        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$short == searchTerm)
            or.filter(\.$long == searchTerm)
        }.all()
    }
}

// domain transfer object (DTO) representation of data we want to send or receive
struct CreateAcronymData: Content {
    let short: String
    let long: String
}
