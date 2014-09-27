    import Foundation

    extension RACSignal {

        /// Get given JSONified data, pass back

        func mapToObject(classType: JSONAble.Type) -> RACSignal {

            func resultFromJSON(object:[String: AnyObject], classType: JSONAble.Type) -> AnyObject {
                return classType.fromJSON(object)
            }

            return tryMap({ (object, error) -> AnyObject! in

                if let dict = object as? [String:AnyObject] {
                    return resultFromJSON(dict, classType)
                }

                if error != nil {
                    error.memory = NSError(domain: MoyaErrorDomain, code: MoyaErrorCode.Data.toRaw(), userInfo: ["data": object])
                }

                return nil
            })
        }

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
                    error.memory = NSError(domain: MoyaErrorDomain, code: MoyaErrorCode.Data.toRaw(), userInfo: ["data": object])
                }

                return nil
            })
        }

    }