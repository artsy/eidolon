import Foundation
import Moya
import RxSwift

enum EidolonError: String {
    case CouldNotParseJSON
    case NotLoggedIn
    case MissingData
}

extension EidolonError: ErrorType { }

extension Observable {

    typealias Dictionary = [String: AnyObject]

    /// Get given JSONified data, pass back objects
    func mapToObject<B: JSONAbleType>(classType: B.Type) -> Observable<B> {
        return self.map { json in
            guard let dict = json as? Dictionary else {
                throw EidolonError.CouldNotParseJSON
            }

            return B.fromJSON(dict)
        }
    }

    /// Get given JSONified data, pass back objects as an array
    func mapToObjectArray<B: JSONAbleType>(classType: B.Type) -> Observable<[B]> {
        return self.map { json in
            guard let array = json as? [AnyObject] else {
                throw EidolonError.CouldNotParseJSON
            }

            guard let dicts = array as? [Dictionary] else {
                throw EidolonError.CouldNotParseJSON
            }

            return dicts.map { B.fromJSON($0) }
        }
    }

}
