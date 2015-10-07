Eidolon
=======

[![Build Status](https://travis-ci.org/artsy/eidolon.svg?branch=master)](https://travis-ci.org/artsy/eidolon)

The [Artsy](https://artsy.net) Auction Kiosk App.

Project Status
----------------

<img src ="https://raw.githubusercontent.com/artsy/eidolon/master/docs/eidolon_preview.jpg">
Featured [in Vogue](http://www.vogue.com/slideshow/13261562/choice-works-auction-at-sothebys-acria-unframed-party/#5)


Downloading the Code
----------------

(Note: if you're an Artsy employee, you'll need to follow [these directions](docs/artsy_dev.md) instead.)

You'll need a few things before we get started. Make sure you have Xcode installed from 
the App Store or wherever. Then run the following two commands to install Xcode's
command line tools and `bundler`, if you don't have that yet.

```sh
[sudo] gem install bundler
xcode-select --install
```

The following commands will set up Eidolon with the expectation that you don't 
have API access and will use blanks for API keys. 

```sh
git clone https://github.com/artsy/eidolon.git
cd eidolon
bundle install
bundle exec fastlane oss
```

Alrighty! We're ready to go!

Getting Started
---------------

Now that we have the code [downloaded](#downloading-the-code), we can run the
app using [Xcode 7](https://developer.apple.com/xcode/downloads/). Make sure to
open the `Kiosk.xcworkspace` workspace, and not the `Kiosk.xcodeproj` project.
Currently, the project is compatible with Xcode 7 only, as it's Swift 2.

Artsy has licensed fonts for use in this app, but due to the terms of that
license, they are not available for open source distribution. This has [required](http://artsy.github.io/blog/2014/06/20/artsys-first-closed-source-pod/)
us to use [private pods](http://guides.cocoapods.org/making/private-cocoapods.html).
The `Podfile` deals with the differences transparently.

The Artsy API is private, making it difficult for open source developers to run
the app. If you don't have access to the private Artsy fonts pod, then Eidolon
infers that it should use stubbed data instead of hitting the live API. 

Questions
---------

If you have questions about any aspect of this project, please feel free to
[open an issue](https://github.com/artsy/eidolon/issues/new). We'd love to hear
from you!

Contributing
------------

This project is being developed by Artsy primarily for its use as Artsy's
auction kiosk app, and we are not expecting to have significant community
contributions back to it. We are developing this project in the open because
it is not part of our core IP, and open source is [part of our job](http://code.dblock.org/open-source-is-simply-part-of-my-teams-job-description). However, if you notice something that is wrong or could be
improved, don't hesitate to send us a pull request.
