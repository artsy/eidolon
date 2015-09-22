source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/artsy/Specs.git'

plugin 'cocoapods-keys', {
  :project => 'Eidolon',
  :keys => [
    'ArtsyAPIClientSecret',
    'ArtsyAPIClientKey',
    'HockeyProductionSecret',
    'HockeyBetaSecret',
    'MixpanelProductionAPIClientKey',
    'MixpanelStagingAPIClientKey',
    'CardflightProductionAPIClientKey',
    'CardflightProductionMerchantAccountToken',
    'StripeProductionPublishableKey',
    'CardflightStagingAPIClientKey',
    'CardflightStagingMerchantAccountToken',
    'StripeStagingPublishableKey'
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

if ['orta', 'ash', 'artsy', 'Laura', 'CI', 'distiller', 'travis'].include?(ENV['USER'])
    pod 'Artsy+UIFonts', '~> 1.1.0'
else
    pod 'Artsy+OSSUIFonts', '~> 1.1.0'
end

pod 'ORStackView'
pod 'FLKAutoLayout'
pod 'ISO8601DateFormatter', '0.7'
pod 'ARCollectionViewMasonryLayout', '~> 2.0.0'
pod 'SDWebImage', '~> 3.7'
pod 'SVProgressHUD'

pod 'ARAnalytics/Mixpanel'
pod 'ARAnalytics/HockeyApp'

pod 'CardFlight'
pod 'Stripe'
pod 'ECPhoneNumberFormatter'
pod 'UIImageViewAligned', :git => 'https://github.com/ashfurrow/UIImageViewAligned.git'
pod 'DZNWebViewController', :git => 'https://github.com/orta/DZNWebViewController.git'
pod 'Reachability', :git => 'https://github.com/ashfurrow/Reachability.git', :branch => 'frameworks'

pod 'UIView+BooleanAnimations'
pod 'ARTiledImageView', :git => 'https://github.com/ashfurrow/ARTiledImageView.git'
pod 'XNGMarkdownParser'

# Swift pods
pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git', :branch => 'xcode7'
pod 'ReactiveCocoa', '~> 4.0.1-alpha-2'
pod 'Moya/ReactiveCocoa'
pod 'Swift-RAC-Macros'

target 'KioskTests' do

  pod 'FBSnapshotTestCase'
  pod 'Nimble-Snapshots'
  pod 'Quick'
  pod 'Nimble', '= 2.0.0-rc.3'
  pod 'Forgeries'

end
