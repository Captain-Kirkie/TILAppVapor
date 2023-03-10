import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    // register your acronym controller
    let acronymsController = AcronymsController()
    try app.register(collection: acronymsController)
    
    
    // register your user controller
    let userController = UserController()
    try app.register(collection: userController)
    
    
    // register your category controller
    let categoryController = CategoryController()
    try app.register(collection: categoryController)
    
    // website controller
    let websiteController = WebsiteController()
    try app.register(collection: websiteController)
    
}
