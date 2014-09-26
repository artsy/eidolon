//    import Foundation
//
//    extension RACSignal {
//
//        /// Get given JSONified data, pass back
//
//        func mapToObject(classType: JSONAble.Type) -> RACSignal {
//            return tryMap({ (object, error) -> AnyObject! in
//                if let json = object as? [String: AnyObject] {
//                    let result = classType.fromJSON(json)
//                    return result
//                }
//
//                if error != nil {
//                    error.memory = NSError(domain: MoyaErrorDomain, code: MoyaErrorCode.Data.toRaw(), userInfo: ["data": object])
//                }
//
//                return nil
//            })
//        }
//    }