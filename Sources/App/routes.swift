import Fluent
import Vapor

func routes(_ app: Application) throws {

   // register your acronym controller
    let acronymsController = AcronymsController()
    try app.register(collection: acronymsController)
    
}
