WORKSPACE = Kiosk.xcworkspace
SCHEME = Kiosk
CONFIGURATION = Debug
APP_NAME = Kiosk

APP_PLIST = Kiosk/Info.plist
PLIST_BUDDY = /usr/libexec/PlistBuddy
BUNDLE_VERSION = $(shell $(PLIST_BUDDY) -c "Print CFBundleVersion" $(APP_PLIST))
GIT_COMMIT = $(shell git log -n1 --format='%h')
DATE_VERSION = $(shell date "+%Y.%m.%d")
DEVICE_HOST = "OS=8.1,name=iPad Air"

# Default for `make`
all: ci

oss: 
	bundle install
	make stub_keys
	bundle exec pod install

bundle: 
	if [ ! -d ~/.cocoapods/repos/artsy ]; then \
		bundle exec pod repo add artsy https://github.com/artsy/Specs.git; \
	fi
	
	bundle exec pod install

storyboard_ids:
	bundle exec sbconstants Kiosk/Storyboards/StoryboardIdentifiers.swift --source-dir Kiosk/Storyboards --swift

build:
	set -o pipefail && xcodebuild -workspace '$(WORKSPACE)' -scheme '$(SCHEME)' -configuration '$(CONFIGURATION)' -sdk iphonesimulator -destination $(DEVICE_HOST) build | xcpretty -c

clean:
	xcodebuild -workspace '$(WORKSPACE)' -scheme '$(SCHEME)' -configuration '$(CONFIGURATION)' clean

test:
	xcodebuild -workspace '$(WORKSPACE)' -scheme '$(SCHEME)' -configuration Debug build test -sdk iphonesimulator -destination $(DEVICE_HOST) | xcpretty -ct

ipa:
	$(PLIST_BUDDY) -c "Set CFBundleDisplayName $(BUNDLE_NAME)" $(APP_PLIST)
	$(PLIST_BUDDY) -c "Set CFBundleVersion $(DATE_VERSION)" $(APP_PLIST)
	ipa build --scheme $(SCHEME) --configuration $(CONFIGURATION) -t
	$(PLIST_BUDDY) -c "Set CFBundleDisplayName $(APP_NAME)" $(APP_PLIST)

distribute:
	ipa distribute:hockeyapp

prepare_ci: CONFIGURATION = Debug
prepare_ci: stub_keys

stub_keys:
	bundle exec pod keys set ArtsyAPIClientSecret "-" Eidolon
	bundle exec pod keys set ArtsyAPIClientKey "-"
	bundle exec pod keys set HockeyProductionSecret "-"
	bundle exec pod keys set HockeyBetaSecret "-"
	bundle exec pod keys set MixpanelProductionAPIClientKey "-"
	bundle exec pod keys set MixpanelStagingAPIClientKey "-"
	bundle exec pod keys set CardflightAPIClientKey "-"
	bundle exec pod keys set CardflightAPIStagingClientKey "-"
	bundle exec pod keys set CardflightMerchantAccountToken "-"
	bundle exec pod keys set CardflightMerchantAccountStagingToken "-"
	bundle exec pod keys set BalancedMarketplaceToken "-"
	bundle exec pod keys set BalancedMarketplaceStagingToken "-"
	
ci: build

beta: BUNDLE_NAME = '$(APP_NAME) β'
beta: clean build ipa distribute
