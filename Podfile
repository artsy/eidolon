source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/artsy/Specs.git'

platform :ios, '7.0'

# Yep.
inhibit_all_warnings!

# Artsy stuff
pod 'Artsy+UIColors'
pod 'Artsy+UILabels'
pod 'Artsy-UIButtons', :git => 'https://github.com/artsy/Artsy-UIButtons.git', :commit => '232d5ed9a761a1a18cdd0f2d07b7ae423ffa3978'

# We'll need to include travis some time.
if ENV['USER'] == "orta" || ENV['USER'] == "ash" || ENV['USER'] == "artsy"
    pod 'Artsy+UIFonts'
else
    pod 'Artsy+OSSUIFonts'
end

pod 'Artsy+UILabels'
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

target "KioskTests", :exclusive => true do
    pod 'FBSnapshotTestCase', :git => 'https://github.com/AshFurrow/ios-snapshot-test-case.git', :branch => 'renderAsLayer'
end

pod 'Reveal-iOS-SDK', :configurations => ['Debug']
