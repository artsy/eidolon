### Deployment

**Note**: These docs omit `bundle exec` in front of the commands.

We deploy using [Fastlane](https://github.com/KrauseFx/fastlane). You'll need the following environment variables set up.

```
export HOCKEY_API_TOKEN='THE_SECRET_TOKEN_YOU_GOT_FROM_1PASSWORD'
export SLACK_URL='https://hooks.slack.com/services/REST_OF_THE_URL_FROM_1PASSWORD'
```

They're in the Artsy Engineering 1Password vault. Just add them to your `.zshenv` (or equivalent file).

Make sure Xcode Accounts has the it@ account in it.

The changelog needs to be valid YAML, with an array of changelog entries to deploy.

```yaml
upcoming:
- some fix [done by some dev]
```

Fastlane will take care of the rest. You can check out the specifics of what it does by executing `fastlane lanes`.

To make a deploy, run the following:

```sh
bundle exec fastlane deploy version:A.B.C
```

The first time you deploy, you'll be asked to sign in to the developer portal through Fastlane. The password is in 1Password, too.

Once the deploy is finished, a message with release notes will be posted to Slack.

If you get an SSL error, like this:

```rb
connect': SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (Faraday::SSLError)
```

Then it's most likely an RVM issue. Re-installing your ruby without binaries should fix the problem:

```sh
rvm reinstall ruby-2.1.2 --disable-binary
```
