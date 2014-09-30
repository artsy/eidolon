### Deployment

We are currently deploying via Product > Archive, and then pushing this manually to Hockey using the HockeyApp app.

If you'd like to deploy, you must be able to sign with 'Artsy Wildcard Enterprise Distribution'. By default this will not just work, you will need to ensure that ReactiveCocoa, LLamaKit and AlamoFire are all signing with distribution profiles.

If you have problems signing still, you will need to ensure that the librarys are falling into the artsy bundle prefix, so change the bundle identifiers in your submodules' targets' to be `net.artsy.` instead of `com.github.`.