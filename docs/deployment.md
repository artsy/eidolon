### Deployment

We deploy using [Fastlane](https://github.com/KrauseFx/fastlane). You'll need the following environment variables set up. 

```
export HOCKEY_API_TOKEN='THE_SECRET_TOKEN_YOU_GOT_FROM_1PASSWORD'
export SLACK_URL='https://hooks.slack.com/services/REST_OF_THE_URL_FROM_1PASSWORD'
```

They're in the Artsy Engineering 1Password vault. Just add them to your `.zshenv` (or equivalent file). 

The changelog needs to have a `version` in its `upcoming` dictionary. 

```yaml
upcoming:
  version: whatever
  notes:
  - some fix [done by some dev]
```

Fastlane is going to extract the version number and release notes from this file. It'll also create a new git tag based on the version number, so you should be on a local `master` branch which is up-to-date with the remote. Then, it's as easy as this:

```sh
fastlane deploy
```

The first time you deploy, you'll be asked to sign in to the developer portal through Fastlane. The password is in 1Password, too. 

If you get an SSL error, like this:

```rb
connect': SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (Faraday::SSLError)
```

Then it's most likely an RVM issue. Re-installing your ruby without binaries should fix the problem:

```sh
rvm reinstall ruby-2.1.2 --disable-binary
```
