Artsy Development
=================

Working for Artsy? Awesome. Setup instructions are a bit different from the README.

You'll need some tools first. Xcode 7 is required, as well as the command-line tools (you probably already have these installed). After installing Xcode, run the following command:

```sh
xcode-select --install
```

You'll also need `bundler`, which you likely already have installed. If you don't, run:

```sh
[sudo] gem install bundler
```

Right, next clone the repo as usual and `cd` into it. You'll need to install the dependencies. The first command installs the tools required to use the second command, which installs the dependencies.

```sh
bundle install
bundle exec pod install
```

When you run `pod install`, you'll be prompted for API keys. These are stored in the Engineering 1Password vault.

Finally, you can run the tests to verify everything is set up right:

```sh
bundle exec fastlane test
```

It's possible you'll run into the following error:

```
xcodebuild: error: Unable to find a destination matching the provided destination specifier:
		{ OS:8.1, name:iPad Air }
```

If that happens, it's because Xcode doesn't have the correct simulator installed. Open Xcode, then under the "Window" menu, select "Devices". Make sure to add an iPad Air with iOS 8.1. If you don't have iOS 8.1 installed, open Xcode preferences and install the iOS 8.1 simulator under the "Downloads" tab. After all that, re-run the tests to verify everything works. 
