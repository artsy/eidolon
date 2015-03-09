source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/artsy/Specs.git'

plugin 'cocoapods-keys', {
  :project => "Eidolon",
  :target => "Kiosk",
  :keys => [
    "ArtsyAPIClientSecret",
    "ArtsyAPIClientKey",
    "HockeyProductionSecret",
    "HockeyBetaSecret",
    "MixpanelProductionAPIClientKey",
    "MixpanelStagingAPIClientKey",
    "CardflightAPIClientKey",
    "CardflightMerchantAccountToken",
    "CardflightMerchantAccountStagingToken",
    "BalancedMarketplaceToken",
    "BalancedMarketplaceStagingToken"
  ]
}

platform :ios, '8.0'
use_frameworks!

# Yep.
inhibit_all_warnings!

# Artsy stuff
pod 'Artsy+UIColors'
pod 'Artsy+UILabels'
pod 'Artsy-UIButtons'

if ENV['USER'] == "orta" || ENV['USER'] == "ash" || ENV['USER'] == "artsy" || ENV['USER'] == "Laura" || ENV['CI'] == "true"
    pod 'Artsy+UIFonts', '~> 1.1.0'
else
    pod 'Artsy+OSSUIFonts', '~> 1.1.0'
end

pod 'ORStackView'
pod 'FLKAutoLayout'
pod 'ISO8601DateFormatter', '0.7'
pod 'ARCollectionViewMasonryLayout', '~> 2.0.0'
pod 'SDWebImage', '~> 3.7'
pod 'SVProgressHUD', :git => 'https://github.com/ashfurrow/SVProgressHUD.git'

pod 'HockeySDK'
pod 'ARAnalytics/Mixpanel'
pod 'ARAnalytics/HockeyApp'

pod 'CardFlight'
pod 'ECPhoneNumberFormatter'
pod 'UIImageViewAligned', :git => "https://github.com/ashfurrow/UIImageViewAligned.git"
pod 'DZNWebViewController', :git => "https://github.com/orta/DZNWebViewController.git"
pod 'Reachability', :git => "https://github.com/ashfurrow/Reachability.git", :branch => "frameworks"

pod 'UIView+BooleanAnimations'
pod 'ARTiledImageView', :git => "https://github.com/ashfurrow/ARTiledImageView.git"
pod 'balanced-ios', :git => "https://github.com/orta/balanced-ios", :branch => "0_5_podspec"
pod 'XNGMarkdownParser'

# swift pods
pod 'SwiftyJSON'
pod 'Alamofire'
pod 'ReactiveCocoa', '3.0.0-alpha.1'
pod 'RACAlertAction'
pod 'Moya/Reactive'
pod 'Swift-RAC-Macros'

target "KioskTests" do

  pod 'FBSnapshotTestCase'
  pod 'Nimble-Snapshots'
  pod 'Quick'
  pod 'Nimble'

end
