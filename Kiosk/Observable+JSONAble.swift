import Foundation
import Moya
import RxSwift

enum EidolonError: ErrorType {
    case CouldNotParseJSON
}

extension Observable {

    /// Get given JSONified data, pass back objects
    func mapToObject<B: JSONAbleType>(classType: B.Type) -> Observable<B> {
        return self.map { json in
            guard let dict = json as? [String:AnyObject] else {
                throw EidolonError.CouldNotParseJSON
            }

            return B.fromJSON(dict)
        }
    }

    /// Get given JSONified data, pass back objects as an array
    func mapToObjectArray<B: JSONAbleType>(classType: B.Type) -> Observable<[B]> {
        return self.map { json in
            guard let dicts = json as? [[String: AnyObject]] else {
                throw EidolonError.CouldNotParseJSON
            }

            return dicts.map { B.fromJSON($0) }
        }
    }

}
