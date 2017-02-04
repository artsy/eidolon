## App Structure

The App is a Swift based RAC app. That means a reliance on functional programming. If any of this is new to you then it's recommended that you consult the books below. This means trying to wrap existing imperative patterns in terms of streams and signals.

Unlike previous apps, this app aims to use Apples visual programming tools to reduce the actual code written as much as possible. If you are new to using Interface Builder and Storyboards I would recommend running though [this tutorial](http://www.raywenderlich.com/50308/storyboards-tutorial-in-ios-7-part-1) by Ray Wenderlich.

We've tried to separate out chunks of functionality into separate Storyboards. For examples all of the bid view controllers are kept inside a single storyboard. When creating a new View Controller you need to give it a new Storyboard ID, and any required Segues. Then run `make storyboard_ids` to generate constants for usage in code.

## Recommended Reads 

In order of accessibility / good learning order.

* The [Swift iBooks](https://itunes.apple.com/us/book/swift-programming-language/id881256329?mt=11)
* Ash's book on [Functional Reactive Programming in iOS](https://leanpub.com/iosfrp)
* objc.io's [Functional Programming in Swift](http://www.objc.io/books/)

## Testing

We're using [Quick / Nimble](https://github.com/Quick/), as they seem to be in the lead for BDD testing on Swift. The test target can be ran with `⌘ + u` on the Kiosk Target. Due to Swift's rather awkward class privacy settings make sure the target membership for classes being tested is in both Kiosk & KioskTests.
