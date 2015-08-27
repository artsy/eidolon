import Foundation
import Moya
import ReactiveCocoa

extension RACSignal {

    /// Get given JSONified data, pass back objects
    func mapToObject(classType: JSONAble.Type) -> RACSignal {
        func resultFromJSON(object:[String: AnyObject], classType: JSONAble.Type) -> AnyObject {
            return classType.fromJSON(object)
        }

        return tryMap({ (object, error) -> AnyObject! in
            if let dict = object as? [String:AnyObject] {
                return resultFromJSON(dict, classType: classType)
            }

            if error != nil {
                error.memory = NSError(domain: MoyaErrorDomain, code: MoyaErrorCode.Data.rawValue, userInfo: ["data": object])
            }

            return nil
        })
    }

    /// Get given JSONified data, pass back objects as an array
    func mapToObjectArray(classType: JSONAble.Type) -> RACSignal {

        func resultFromJSON(object:[String: AnyObject], classType: JSONAble.Type) -> AnyObject {
            return classType.fromJSON(object)
        }

        return tryMap({ (object, error) -> AnyObject! in

            if let dicts = object as? Array<Dictionary<String, AnyObject>> {
                let jsonables:[JSONAble] =  dicts.map({ return classType.fromJSON($0) })
                return jsonables
            }

            if error != nil {
                error.memory = NSError(domain: MoyaErrorDomain, code: MoyaErrorCode.Data.rawValue, userInfo: ["data": object])
            }

            return nil
        })
    }
}
