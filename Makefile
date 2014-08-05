WORKSPACE = Kiosk.xcworkspace
SCHEME = Kiosk
CONFIGURATION = Beta


all: ci

build:
	set -o pipefail && xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -configuration '$(CONFIGURATION)' -sdk iphonesimulator -destination 'name=iPad Retina' build | xcpretty -c

clean:
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -configuration '$(CONFIGURATION)' clean

test:
	set -o pipefail && xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -configuration Debug test -sdk iphonesimulator -destination 'name=iPad Retina' | xcpretty -c --test

ci: CONFIGURATION = Debug
ci:	build
