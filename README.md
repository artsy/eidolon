Eidolon
================

The upcoming [Artsy](https://artsy.net) Auction Kiosk App.

Project Status
----------------

This project is in the *very* early stages. Its goal is to provide a seamless
experience for browsing and bidding on artworks in an auction.

Downloading the Code
----------------

Git repositories can be fickle things. Since CocoaPods' support of Swift-based pods
is still [under construction](https://github.com/CocoaPods/CocoaPods/pull/2222),
we are choosing to – well, forced, really – to use git submodules.

![Git Submodules](http://cloud.ashfurrow.com/image/0E1e2G2J1f1P/git-submodules.png)

That means that clicking the "Download ZIP" button isn't going to download all
of the code you'll need to run the app. Instead, [clone](http://git-scm.com/book/en/Git-Basics-Getting-a-Git-Repository#Cloning-an-Existing-Repository)
the repository from GitHub by typing the following command.

```sh
git clone https://github.com/artsy/eidolon.git
cd eidolon
make bootstrap
```

Notice that we're doing a `git submodule update` and `init`, and *not* using the
`--recursive` option of the `clone` command. If we were to clone recursively,
some of the submodules we use would fetch their own submodules, which would lead
to incorrect behaviour.

A lot of iOS code still exists as Objective-C, and we use a lot of it as
CocoaPods. So after cloning the repo, shown above, you'll need to do a `pod
install`. You'll need to have [CocoaPods](http://guides.cocoapods.org/using/getting-started.html)
already installed.

Alrighty! We're ready to go!

Getting Started
----------------

Now that we have the code [downloaded](#downloading-the-code), we can run the
app using [Xcode 6](https://developer.apple.com/xcode/downloads/). Make sure to
open the `Kiosk.xcworkspace` workspace, and not the `Kiosk.xcodeproj` project.
Currently, the project is compatible with Xcode 6 beta 5.

The Artsy API is private, making it difficult for open source developers to run
the app. Once we integrate networking support, we'll figure out a way to stub
network requests so that the app can run with sample data.

Artsy has licensed fonts for use in this app, but due to the terms of that
license, they are not available for open source distribution. This has [required](http://artsy.github.io/blog/2014/06/20/artsys-first-closed-source-pod/)
us to use [private pods](http://guides.cocoapods.org/making/private-cocoapods.html).
Once we integrate these pods in, we'll provide substitutes for the open-source
distribution. You shouldn't notice a difference.

Contributing
----------------

This project is being developed by Artsy primarily for its use as Artsy's
auction kiosk app, and we are not expecting to have significant community
contributions back to it. We are developing this project in the open because
it is not part of our core IP, and open source is [part of our job](http://code.dblock.org/open-source-is-simply-part-of-my-teams-job-description). However, if you notice something that is wrong or could be
improved, don't hesitate to send us a pull request.
