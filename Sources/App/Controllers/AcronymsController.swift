import Vapor

struct AcronymsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws { // boot comes from RouteCollection, configures routes
        let acronymsRoutes = routes.grouped("api", "acronyms") // everything behind /api/acronyms
        acronymsRoutes.get(use: getAllHandler) // GET all
        acronymsRoutes.post(use: createHandler) // post request to create and acronym
        acronymsRoutes.get(":acronymID", use: getHandler) // get based on acronym
        acronymsRoutes.delete(":acronymID", use: deleteHandler) // delete based on UUID
        acronymsRoutes.put(":acronymID", use: updateHandler) // PUT method to update based on ID
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let acronym = try req.content.decode(Acronym.self) // decode it
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
        let updatedAcronym = try req.content.decode(Acronym.self)
        return Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { acronym in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: req.db).map { acronym }
        }
    }
}
