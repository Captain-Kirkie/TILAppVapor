
import Vapor
struct CategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categoryRoutes = routes.grouped("api", "categories") // all categories behind api/categories
        categoryRoutes.get(use: getAllHAndler)
        categoryRoutes.get(":categoryID", use: getByID)
        // create category
        categoryRoutes.post(use: createHandler)
        categoryRoutes.put(":categoryID", use: updateHandler)
    }
    
    //MARK: GET
    func getAllHAndler(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Category.query(on: req.db).all()
    }
    
    func getByID(_ req: Request) throws -> EventLoopFuture<Category> {
        Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    //MARK: POST
    func createHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self) // decode the category
        // save it to the db
        return category.save(on: req.db).map { category }
    }
    
    //MARK: PUT
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        let updatedCat = try req.content.decode(Category.self)
        return Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { cat in
            cat.name = updatedCat.name
            return cat.save(on: req.db).map { cat }
        }
    }
    
}
