import Vapor

public func routes(_ router: Router) throws {
    router.get("lua_sample") {
        req -> String in

        let L = LuaState()
        let answer = L.eval(script: "return math.random(os.date '%S') + 23")
        return "Lua says '\(answer)'\n"
    }

    router.get("api", "endpoints") {
        req -> String in

        let routeData: [(String, String)] = router.routes.map { route in
            let method = String([route.path.first!].readable.dropFirst())
            let path = Array(route.path.dropFirst()).readable
            return (method, path)
        }.sorted { a, b in (a.0 == b.0) ? a.1 < b.1 : a.0 < b.0 }

        return routeData.reduce("") {  accumulator, current in accumulator + "\(current.0): \(current.1)\n" } 
    }

    router.post(Endpoint.self, at: "api/register") {
        req, endpoint -> String in

        let logger = try req.make(Logger.self)
        
        let method: HTTPMethod
        if let endpointMethod =  endpoint.method, endpointMethod == .post {
            method = .POST
        } else {
            method = .GET
        }
        let pathString = "\(method)/" + endpoint.path
        let path = pathString.convertToPathComponents()

        let responder: Responder
        let message: String
        if let response = endpoint.response {
            message = "Registering response: '\(response)'"

            responder = BasicResponder {
                req in

                let  res = req.response()
                try res.content.encode(response, as: .plainText)
                return req.eventLoop.newSucceededFuture(result: res)
            }
        } else if let script = endpoint.script {
            message = "Registering script: '\(script)'"

            responder = BasicResponder {
                req in

                let  res = req.response()
                let L = LuaState()                         
                try res.content.encode("\(L.eval(script: script))\n", as: .plainText)
                return req.eventLoop.newSucceededFuture(result: res)
            }
        } else {
            message = "Invalid registration\n"
            return "Invalid registration"
        }

        logger.info("Registering new endpoint:")
        logger.info("\tpath: \(path)")
        logger.info("\t\(message)")

        let route = Route<Responder>(path: path, output: responder)
        router.register(route: route)
        
        return "Registering endpoint for '\(path)'\n"
    }
}
