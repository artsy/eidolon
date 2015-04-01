### Building for Deployment

So, Xcode has some problems and will actually fail to compile the first time or two you try to build it (radars have been filed). To compensate for this, you need to run `fastlane build_for_deploy` until it works. 

### Deployment

We deploy using [Fastlane](https://github.com/KrauseFx/fastlane). You'll need the following environment variables set up. 

export HOCKEY_API_TOKEN='THE_SECRET_TOKEN_YOU_GOT_FROM_1PASSWORD'
export SLACK_URL='https://hooks.slack.com/services/REST_OF_THE_URL_FROM_1PASSWORD'

They're in the Artsy Engineering 1Password vault. Just add them to your `.zshenv` (or equivalent file). 

After setup, make sure the CHANGELOG is up to date. It needs to be formatted correctly, with the latest version at the top. 

```markdown
## X.Y.Z TITLE_OF_RELEASE
* The rest of the release notes in markdown format
```

Fastlane is going to extract the version number and release notes from this file. It'll also create a new git tag based on the version number, so you should be on a local `master` branch which is up-to-date with the remote. Then, it's as easy as this:

```sh
fastlane deploy
```

The first time you deploy, you'll be asked to sign in to the developer portal through Fastlane. The password is in 1Password, too. 
