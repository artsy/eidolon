Eidolon
=======

[![Build Status](https://travis-ci.org/artsy/eidolon.svg?branch=master)](https://travis-ci.org/artsy/eidolon)

The [Artsy](https://artsy.net) Auction Kiosk App.

Project Status
----------------

<img src ="https://raw.githubusercontent.com/artsy/eidolon/master/docs/eidolon_preview.jpg">

Downloading the Code
----------------

The following commands will ask for keys to get the app set up, you can just put 
gibberish in there if you don't work for Artsy. (Note that you'll need Xcode's
command line tools installed first.)

```sh
git clone https://github.com/artsy/eidolon.git
cd eidolon
bundle install
make bootstrap
```

Alrighty! We're ready to go!

Getting Started
---------------

Now that we have the code [downloaded](#downloading-the-code), we can run the
app using [Xcode 6.1+](https://developer.apple.com/xcode/downloads/). Make sure to
open the `Kiosk.xcworkspace` workspace, and not the `Kiosk.xcodeproj` project.
Currently, the project is compatible with Xcode 6 only, as it's swift.

The Artsy API is private, making it difficult for open source developers to run
the app. We have a toggle in the `AppDelegate` that flips the app to use only stubbbed networking.

Artsy has licensed fonts for use in this app, but due to the terms of that
license, they are not available for open source distribution. This has [required](http://artsy.github.io/blog/2014/06/20/artsys-first-closed-source-pod/)
us to use [private pods](http://guides.cocoapods.org/making/private-cocoapods.html).
The `Podfile` deals with the differences.

Contributing
------------

This project is being developed by Artsy primarily for its use as Artsy's
auction kiosk app, and we are not expecting to have significant community
contributions back to it. We are developing this project in the open because
it is not part of our core IP, and open source is [part of our job](http://code.dblock.org/open-source-is-simply-part-of-my-teams-job-description). However, if you notice something that is wrong or could be
improved, don't hesitate to send us a pull request.
