fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
### test
```
fastlane test
```
Run all iOS tests on an iPad
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

Generate this documentation by running `fastlane docs`
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/KrauseFx/fastlane)