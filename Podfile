source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/artsy/Specs.git'

# This API format doesn't work in cocoapods-keys yet. So don't get too excited.

plugin 'cocoapods-keys', {
  :project => "Eidolon",
  :keys => [
    "ArtsyAPIClientSecret",
    "ArtsyAPIClientKey",
    "HockeyProductionSecret",
    "HockeyBetaSecret",
    "MixpanelProductionAPIClientKey",
    "MixpanelStagingAPIClientKey",
    "CardflightAPIClientKey",
    "CardflightAPIStagingClientKey",
    "CardflightMerchantAccountToken",
    "CardflightMerchantAccountStagingToken",
    "BalancedMarketplaceToken",
    "BalancedMarketplaceStagingToken"
  ]}

platform :ios, '8.0'

# Yep.
inhibit_all_warnings!

# Artsy stuff
pod 'Artsy+UIColors'
pod 'Artsy+UILabels'
pod 'Artsy-UIButtons'

# We'll need to include travis some time.
if ENV['USER'] == "orta" || ENV['USER'] == "ash" || ENV['USER'] == "artsy" || ENV['USER'] == "Laura"
    pod 'Artsy+UIFonts', :git => 'https://github.com/artsy/Artsy-UIFonts.git', :branch => 'new-tracking'
else
    pod 'Artsy+OSSUIFonts'
end

pod 'ORStackView'
pod 'FLKAutoLayout'
pod 'ISO8601DateFormatter', '0.7'
pod 'ARCollectionViewMasonryLayout', '~> 2.0.0'
pod 'SDWebImage', '~> 3.7'

pod 'HockeySDK', '3.5.4'
pod 'ARAnalytics/Mixpanel'
pod 'ARAnalytics/HockeyApp'

pod 'CardFlight'
pod 'ECPhoneNumberFormatter'
pod 'UIImageViewAligned', :git => "https://github.com/orta/UIImageViewAligned.git"
pod 'DZNWebViewController', :git => "https://github.com/orta/DZNWebViewController.git"
pod 'Reachability', :git => "https://github.com/ashfurrow/Reachability.git", :branch => "frameworks"

pod 'UIView+BooleanAnimations'
pod 'ARTiledImageView', :git => "https://github.com/dblock/ARTiledImageView.git"
pod 'balanced-ios', :git => "https://github.com/orta/balanced-ios", :branch => "0_5_podspec"
pod 'XNGMarkdownParser'

# swift pods
pod 'XCGLogger', :git => "https://github.com/ashfurrow/XCGLogger.git", :branch => "podspec"
pod 'SwiftyJSON', :git => "https://github.com/orta/SwiftyJSON", :branch => "podspec"
pod 'Alamofire', :git => "https://github.com/mrackwitz/Alamofire.git", :branch => "podspec"
pod 'LlamaKit', :git => "https://github.com/AshFurrow/LlamaKit", :branch => "rac_podspec"
pod 'ReactiveCocoa', :git => "https://github.com/AshFurrow/ReactiveCocoa", :branch => "podspec"
pod 'Moya/Reactive', :git => "https://github.com/AshFurrow/Moya"

target "KioskTests" do

  pod 'FBSnapshotTestCase', :head
  pod 'Nimble-Snapshots', :git => "https://github.com/ashfurrow/Nimble-Snapshots.git"
  pod 'Quick', :git => "https://github.com/Quick/Quick"
  pod 'Nimble', :git => "https://github.com/Quick/Nimble"

end

unoptimized_pod_names = ['XCGLogger']

post_install do |installer_representation|
  targets = installer_representation.project.targets.select { |target|
    unoptimized_pod_names.select { |name|
      target.display_name.end_with? name
    }.count > 0
  }
  targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
    end
  end
end
