
import Vapor
struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: indexHandler)
        routes.get("acronyms", ":acronymID", use: acronymHandler)
        routes.get("users", ":userID", use: userHandler)
        routes.get("users", use: allUserHandler)
        routes.get("categories", ":categoryID", use: categoryHandler)
        routes.get("categories", use: allCategoryHandler)
    }
    
    func indexHandler(_ req: Request) throws -> EventLoopFuture<View> {
        Acronym.query(on: req.db).all().flatMap{ acronyms in
            let context = IndexContext(title: "Homepage", acronyms: acronyms)
            return req.view.render("index", context)
        }
    }
    
    func acronymHandler(_ req: Request) throws -> EventLoopFuture<View> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap{ acronym in
            acronym.$user.get(on: req.db).flatMap{ user in
                let context = AcronymContext(title: acronym.long, acronym: acronym, user: user)
                return req.view.render("acronym", context)
            }
        }
    }
    
    func userHandler(_ req: Request) throws -> EventLoopFuture<View> {
        User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
            user.$acronyms.get(on: req.db).flatMap { acronyms in
                let context = UserContext(title: user.name, user: user, acronyms: acronyms)
                return req.view.render("user", context)
            }
        }
    }
    
    func allUserHandler(_ req: Request) throws -> EventLoopFuture<View> {
        User.query(on: req.db).all().flatMap{ users in
            let context = AllUsersContext(title: "All Users", users: users)
            return req.view.render("allUsers", context)
        }
    }
    
    func categoryHandler(_ req: Request) throws -> EventLoopFuture<View> {
        Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { category in
            category.$acronyms.get(on: req.db).flatMap { acronyms in
                let context = CategoryContext( title: category.name, category: category, acronyms: acronyms)
                return req.view.render("category", context)
            }
        }
    }
    
    func allCategoryHandler(_ req: Request) throws -> EventLoopFuture<View> {
        Category.query(on: req.db).all().flatMap { categories in
            let context = AllCategorysContext(title: "All Categories", categories: categories)
            return req.view.render("allCategories", context)
        }
    }
}



struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: [Acronym]
}

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]
}

struct AllCategorysContext: Encodable {
    let title: String
    let categories: [Category]
}


struct CategoryContext: Encodable {
    let title: String
    let category: Category
    let acronyms: [Acronym]
}
