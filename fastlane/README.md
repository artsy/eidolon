fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### test
```
fastlane test
```
Run all iOS tests on an iPad
### oss_keys
```
fastlane oss_keys
```

### oss
```
fastlane oss
```
Set all the API keys required for distribution
### deploy
```
fastlane deploy
```
Release a new beta version on Hockey

This action does the following:



- Verifies API keys are non-empty

- Ensures a clean git status

- Increment the build number

- Build and sign the app

- Upload the ipa file to hockey

- Post a message to slack containing the download link

- Commit and push the version bump
### storyboard_ids
```
fastlane storyboard_ids
```
Updates the storyboard identifier Swift values.

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
