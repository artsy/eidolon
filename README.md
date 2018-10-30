Eidolon
=======

The [Artsy](https://www.artsy.net/) Auction Kiosk App.

**Note**: Current development is done on the [`xcode-9` branch](https://github.com/artsy/eidolon/tree/xcode-9) using Xcode 9 (available for download [on Apple's developer portal](https://developer.apple.com/download/more/)). You can [see this issue](https://github.com/artsy/eidolon/pull/695) for more details.

Project Status
----------------

<img src ="https://raw.githubusercontent.com/artsy/eidolon/master/docs/eidolon_preview.jpg">

Featured [in Vogue](http://www.vogue.com/slideshow/13261562/choice-works-auction-at-sothebys-acria-unframed-party/#5). Physical enclosure made by [Visibility](http://vsby.co/work/auction-kiosk).

### Meta

* __State:__ production
* __Point People:__ [@ashfurrow](https://github.com/ashfurrow), [@orta](https://github.com/orta)
* __CI :__ [![CircleCI](https://circleci.com/gh/artsy/eidolon.svg?style=svg)](https://circleci.com/gh/artsy/eidolon)

This is a core [Artsy Mobile](https://github.com/artsy/mobile) OSS project, along with [Eigen](https://github.com/artsy/eigen), [Energy](https://github.com/artsy/energy), [Emission](https://github.com/artsy/emission) and [Emergence](https://github.com/artsy/emergence).

Don't know what Artsy is? [Check this](https://github.com/artsy/mobile/blob/master/what_is_artsy.md) overview, or read our objc.io on [team culture](https://www.objc.io/issues/22-scale/artsy/).

Want to know more about Eigen? Read the [mobile](http://artsy.github.io/blog/categories/mobile/) blog posts, or [eidolon's](http://artsy.github.io/blog/categories/eidolon/) specifically.


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
app using [Xcode 9](https://developer.apple.com/xcode/download/). Make sure to
open the `Kiosk.xcworkspace` workspace, and not the `Kiosk.xcodeproj` project.

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
it is not part of our core IP, and open source is [part of our job](http://code.dblock.org/2011/07/15/open-source-is-simply-part-of-my-teams-job-description.html). However, if you notice something that is wrong or could be
improved, don't hesitate to send us a pull request.

License
-------

MIT License. See [LICENSE](LICENSE).
