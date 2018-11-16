import Vapor

struct Endpoint: Content {
    enum Method: String, Codable {
        case get = "GET"
        case post = "POST"
    }
    
    let path: String
    let method: Method?
    let response: String?
    let script: String?
}
