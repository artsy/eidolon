WORKSPACE = Kiosk.xcworkspace
SCHEME = Kiosk
CONFIGURATION = Beta

# Default for `make`
all: ci

bootstrap:
	git submodule init
	git submodule update
	pod install


build:
	set -o pipefail && xcodebuild -workspace '$(WORKSPACE)' -scheme '$(SCHEME)' -configuration '$(CONFIGURATION)' -sdk iphonesimulator -destination 'name=iPad Retina' build | xcpretty -c

clean:
	xcodebuild -workspace '$(WORKSPACE)' -scheme '$(SCHEME)' -configuration '$(CONFIGURATION)' clean

test:
	set -o pipefail && xcodebuild -workspace '$(WORKSPACE)' -scheme '$(SCHEME)' -configuration Debug test -sdk iphonesimulator -destination 'name=iPad Retina' | xcpretty -c --test

before_ci:
	sudo xcode-select -s /Applications/Xcode6-Beta5.app/Contents/Developer
	pod repo add artsy https://github.com/artsy/Specs.git

after_ci:
	sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

setup:
	bundle install
	pod install

prepare_ci: CONFIGURATION = Debug
prepare_ci:	before_ci setup build

ci: test after_ci
