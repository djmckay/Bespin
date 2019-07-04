import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try router.register(collection: EmailTemplateController())
    try router.register(collection: UsersController())
    try router.register(collection: TokensController())
    try router.register(collection: MessagesController())
    try router.register(collection: EmailTemplateAttachmentsController())
}
