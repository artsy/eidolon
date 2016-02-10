import Foundation
import RxSwift
import Moya

typealias BypassResults = (bypassCCRequirement: Bool, authorizedNetworking: AuthorizedNetworking)

protocol AdminCCBypassNetworkModelType {

    func checkForAdminCCBypass(saleID: String, authorizedNetworking: AuthorizedNetworking) -> Observable<BypassResults>
}

class AdminCCBypassNetworkModel: AdminCCBypassNetworkModelType {

    /// Returns an Observable of (Bool, AuthorizedNetworking)
    /// The Bool represents if a the Credit Card requirement should be waived. 
    /// THe AuthorizedNetworking is the same instance that's passed in, which is a convenience for chaining observables.
    func checkForAdminCCBypass(saleID: String, authorizedNetworking: AuthorizedNetworking) -> Observable<BypassResults> {

        return authorizedNetworking
            .request(ArtsyAuthenticatedAPI.FindMyBidderRegistration(auctionID: saleID))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObjectArray(Bidder)
            .map { bidders in
                return bidders.first
            }
            .map { bidder -> Bool in
                guard let bidder = bidder else { return false }

                return bidder.createdByAdmin
            }
            .map { bypass in
                return (bypassCCRequirement: bypass, authorizedNetworking: authorizedNetworking)
            }
            .logError()
    }
}