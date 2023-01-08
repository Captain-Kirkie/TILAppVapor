import Vapor
struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("api", "users") // all users behind api/users
        userRoutes.get(use: getAllHAndler)
        userRoutes.get(":userID", use: getByID)
        // create user
        userRoutes.post(use: createHandler)
    }
    
    //MARK: GET
    func getAllHAndler(_ req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    
    func getByID(_ req: Request) throws -> EventLoopFuture<User> {
        User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    //MARK: POST
    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try  req.content.decode(User.self) // decode the user
        // save it to the db
        return user.save(on: req.db).map { user }
    }
    
}
