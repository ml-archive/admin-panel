import Routing
import HTTP

// Just a copy from vapor since its private
extension Collection where Iterator.Element == Middleware {
    func chain(to responder: Responder) -> Responder {
        return reversed().reduce(responder) { nextResponder, nextMiddleware in
            return Request.Handler { request in
                return try nextMiddleware.respond(to: request, chainingTo: nextResponder)
            }
        }
    }
}

// TODO, this should be moved to vapor
extension RouteBuilder where Value == Responder {
    public func group(_ middlewares: [Middleware], closure: (RouteGroup<Value, Self>) ->()) {
        group(prefix: [nil, nil], path: [], map: { handler in
            return Request.Handler { request in
                return try middlewares.chain(to: handler).respond(to: request)
            }
        }, closure: closure)
    }
    
    public func grouped(_ middlewares: [Middleware]) -> RouteGroup<Value, Self> {
        return grouped(prefix: [nil, nil], path: [], map: { handler in
            return Request.Handler { request in
                return try middlewares.chain(to: handler).respond(to: request)
            }
        })
    }
}
