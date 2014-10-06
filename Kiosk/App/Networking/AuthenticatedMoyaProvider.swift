//    import Foundation
//
//    class AuthenticatedMoyaProvider<T where T: MoyaTarget>: ReactiveMoyaProvider<T> {
//        var credentials:UserCredentials?
//
//        init(credentials:UserCredentials, endpointsClosure: MoyaEndpointsClosure, endpointResolver: MoyaEndpointResolution = MoyaProvider.DefaultEnpointResolution(), stubResponses: Bool = false) {
//
//            let authEndpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
//               return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)
//            }
//
//            super.init(endpointsClosure: authEndpointsClosure, endpointResolver: endpointResolver, stubResponses: stubResponses)
//
//    //        self.credentials = credentials
//
//        }
//
//        override func endpoint(token: T, method: Moya.Method, parameters: [String : AnyObject]) -> Endpoint<T> {
//            let endPoint = super.endpoint(token, method: method, parameters: parameters)
//            return endPoint.endpointByAddingHTTPHeaderFields(["X-Access-Token": self.credentials?.accessToken])
//        }
//    }