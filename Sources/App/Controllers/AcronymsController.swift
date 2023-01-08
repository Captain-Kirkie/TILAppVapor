import Vapor

struct AcronymsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws { // boot comes from RouteCollection, configures routes
        let acronymsRoutes = routes.grouped("api", "acronyms") // everything behind /api/acronyms
        acronymsRoutes.get(use: getAllHandler) // GET all
        acronymsRoutes.post(use: createHandler) // post request to create and acronym
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let acronym = try req.content.decode(Acronym.self) // decode it
        return acronym.save(on: req.db).map { acronym }
    }
}
