//    import Foundation
//
//    extension RACSignal {
//
//        /// Get given JSONified data, pass back
//
//        func mapToObject(classType: JSONAble.Type) -> RACSignal {
//
//            func resultFromJSON(object:[String: AnyObject], classType: JSONAble.Type) -> AnyObject {
//                return classType.fromJSON(object)
//            }
//
//            return tryMap({ (object, error) -> AnyObject! in
//
//                if let dict = object as? [String:AnyObject] {
//                    return resultFromJSON(dict, classType)
//                }
//
//                if error != nil {
//                    error.memory = NSError(domain: MoyaErrorDomain, code: MoyaErrorCode.JSONORM.toRaw(), userInfo: ["data": object])
//                }
//
//                return nil
//            })
//        }
//    }