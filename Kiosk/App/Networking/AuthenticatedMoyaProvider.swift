//    import Foundation
//
//    let authEndpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
//       return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)
//    }
//
//    class AuthenticatedMoyaProvider<T where T: MoyaTarget>: ReactiveMoyaProvider<T> {
//        let credentials:UserCredentials
//
//        init(credentials:UserCredentials, stubResponses:Bool) {
//            self.credentials = credentials
//            let closure = authEndpointsClosure
//            super.init(closure, stubResponses: stubResponses)
//        }
//
//        override func endpoint(token: T, method: Moya.Method, parameters: [String : AnyObject]) -> Endpoint<T> {
//            let endPoint = super.endpoint(token, method: method, parameters: parameters)
//            return endPoint.endpointByAddingHTTPHeaderFields(["X-Access-Token": self.credentials.accessToken])
//        }
//    }