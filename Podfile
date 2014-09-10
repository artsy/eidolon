platform :ios, '7.0'

# Yep.
inhibit_all_warnings!

# Artsy stuff
pod 'Artsy+UIColors'
pod 'Artsy+UILabels'

# We'll need to include travis some time.
if ENV['USER'] == "orta" || ENV['USER'] == "ash" || ENV['USER'] == "artsy"
    pod 'Artsy+UIFonts'
else
    pod 'Artsy+OSSUIFonts'
end

pod 'Artsy+UILabels'
pod 'ORStackView'
pod 'FLKAutoLayout'

pod 'HockeySDK', '3.5.4'
pod 'ARAnalytics/Mixpanel'
pod 'ARAnalytics/HockeyApp'

pod 'CardFlight'

target "KioskTests", :exclusive => true do
   pod 'FBSnapshotTestCase'
end
