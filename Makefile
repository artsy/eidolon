WORKSPACE = Kiosk.xcworkspace
SCHEME = Kiosk
CONFIGURATION = Debug
APP_NAME = Kiosk

APP_PLIST = Kiosk/Info.plist
PLIST_BUDDY = /usr/libexec/PlistBuddy
BUNDLE_VERSION = $(shell $(PLIST_BUDDY) -c "Print CFBundleVersion" $(APP_PLIST))
GIT_COMMIT = $(shell git log -n1 --format='%h')
DATE_VERSION = $(shell date "+%Y.%m.%d")

# Default for `make`
all: ci

bootstrap:
	git submodule init
	git submodule update
	./submodules/ReactiveCocoa/script/bootstrap
	pod install

storyboard_ids:
	bundle exec sbconstants Kiosk/Storyboards/StoryboardIdentifiers.swift --source-dir Kiosk/Storyboards --swift

build:
	set -o pipefail && xcodebuild -workspace '$(WORKSPACE)' -scheme '$(SCHEME)' -configuration '$(CONFIGURATION)' -sdk iphonesimulator -destination 'name=iPad Retina' build | xcpretty -c

clean:
	xcodebuild -workspace '$(WORKSPACE)' -scheme '$(SCHEME)' -configuration '$(CONFIGURATION)' clean

test:
	set -o pipefail && xcodebuild -workspace '$(WORKSPACE)' -scheme '$(SCHEME)' -configuration Debug test -sdk iphonesimulator -destination 'name=iPad Retina' | xcpretty -c --test

ipa:
	$(PLIST_BUDDY) -c "Set CFBundleDisplayName $(BUNDLE_NAME)" $(APP_PLIST)
	$(PLIST_BUDDY) -c "Set CFBundleVersion $(DATE_VERSION)" $(APP_PLIST)
	ipa build --scheme $(SCHEME) --configuration $(CONFIGURATION) -t
	$(PLIST_BUDDY) -c "Set CFBundleDisplayName $(APP_NAME)" $(APP_PLIST)

distribute:
	ipa distribute:hockeyapp

before_ci:
	sudo xcode-select -s /Applications/Xcode6-Beta7.app/Contents/Developer
	pod repo add artsy https://github.com/artsy/Specs.git

after_ci:
	sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

setup:
	bundle install
	pod install

prepare_ci: CONFIGURATION = Debug
prepare_ci:	before_ci setup build

ci: test after_ci

beta: BUNDLE_NAME = '$(APP_NAME) β'
beta: clean build ipa distribute
