import Vapor

/** JSON Formatting
 {
     "short": "omg",
     "long": "Oh My God",
     "user": {
         "id": "USER-ID"
     }
 }
 */


struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("api", "users") // all users behind api/users
        userRoutes.get(use: getAllHAndler)
        userRoutes.get(":userID", use: getByID)
        // create user
        userRoutes.post(use: createHandler)
        
        // update a user
        userRoutes.put(":userID", use: updateHandler)
        
        // get the acronyms of a specific user
        userRoutes.get(":userID", "acronyms", use: getAcronyms)
    }
    
    //MARK: GET
    func getAllHAndler(_ req: Request) throws -> EventLoopFuture<[User.Public]> {
        User.query(on: req.db).all().convertToPublic()
    }
    
    func getByID(_ req: Request) throws -> EventLoopFuture<User.Public> {
        User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).convertToPublic()
    }
    
    //MARK: POST
    func createHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
        let user = try  req.content.decode(User.self) // decode the user
        user.password = try Bcrypt.hash(user.password) // hash the user password
        // save it to the db
        return user.save(on: req.db).map { user.convertToPublic() }
    }
    
    //MARK: PUT
    func updateHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
        let updatedUser = try req.content.decode(User.self)
        return User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
            user.name = updatedUser.name
            user.userName = updatedUser.userName
            return user.save(on: req.db).map { user.convertToPublic() }
        }
    }
    
    func getAcronyms(_ req: Request) throws -> EventLoopFuture<[Acronym]>{
        User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap{ user in
            user.$acronyms.get(on: req.db) // get Acronym array
        }
    }
    
}
