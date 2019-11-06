source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/artsy/Specs.git'

plugin 'cocoapods-keys', {
  :project => 'Eidolon',
  :keys => [
    'ArtsyAPIClientSecret',
    'ArtsyAPIClientKey',
    'SegmentWriteKey',
    'StripeProductionPublishableKey',
    'StripeStagingPublishableKey'
  ]
}

platform :ios, '10.0'
use_frameworks!

# Yep.
inhibit_all_warnings!

target 'Kiosk' do

  # Artsy stuff
  pod 'Artsy+UIColors'
  pod 'Artsy+UILabels'
  pod 'Artsy-UIButtons'

  pod 'Artsy+UIFonts'

  pod 'ORStackView', '2.0'
  pod 'FLKAutoLayout', '0.1.1'
  pod 'ARCollectionViewMasonryLayout', '~> 2.0.0'
  pod 'SDWebImage', '~> 3.7'
  pod 'SVProgressHUD'
  
  pod 'ARAnalytics/Segmentio'

  pod 'Stripe'
  pod 'ECPhoneNumberFormatter'
  pod 'libPhoneNumber-iOS'
  pod 'UIImageViewAligned', :git => 'https://github.com/ashfurrow/UIImageViewAligned.git'
  pod 'DZNWebViewController', :git => 'https://github.com/orta/DZNWebViewController.git'
  pod 'ReachabilitySwift'

  pod 'UIView+BooleanAnimations'
  pod 'ARTiledImageView'
  pod 'XNGMarkdownParser'
  pod 'ISO8601DateFormatter'

  # Swift pods
  pod 'SwiftyJSON'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxOptional'
  pod 'Moya/RxSwift'
  pod 'NSObject+Rx'
  pod 'Action'

  target 'KioskTests' do
    inherit! :search_paths

    pod 'FBSnapshotTestCase'
    pod 'Nimble-Snapshots'
    pod 'Quick'
    pod 'Nimble'
    pod 'RxNimble'
    pod 'Forgeries'
    pod 'RxBlocking'

  end
end

# Required for the Playground and Xcode 9.
# See: https://learnappmaking.com/cocoapods-playground-how-to/
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end

    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
        end
    end
end
