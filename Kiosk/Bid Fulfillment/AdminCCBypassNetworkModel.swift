import Foundation
import RxSwift
import Moya

enum BypassResult {
    case requireCC
    case skipCCRequirement
}

protocol AdminCCBypassNetworkModelType {

    func checkForAdminCCBypass(_ saleID: String, authorizedNetworking: AuthorizedNetworking) -> Observable<BypassResult>
}

class AdminCCBypassNetworkModel: AdminCCBypassNetworkModelType {

    /// Returns an Observable of (Bool, AuthorizedNetworking)
    /// The Bool represents if the Credit Card requirement should be waived.
    /// THe AuthorizedNetworking is the same instance that's passed in, which is a convenience for chaining observables.
    func checkForAdminCCBypass(saleID: String, authorizedNetworking: AuthorizedNetworking) -> Observable<BypassResult> {

        return authorizedNetworking
            .request(ArtsyAuthenticatedAPI.FindMyBidderRegistration(auctionID: saleID))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObjectArray(Bidder)
            .map { bidders in
                return bidders.first
            }
            .map { bidder -> BypassResult in
                guard let bidder = bidder else { return .RequireCC }

                switch bidder.createdByAdmin {
                case true: return .SkipCCRequirement
                case false: return .RequireCC
                }
            }
            .logError()
    }
}
