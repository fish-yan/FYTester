# FYTester

[![Version](https://img.shields.io/cocoapods/v/FYTester.svg?style=flat)](https://cocoapods.org/pods/FYTester)
[![License](https://img.shields.io/cocoapods/l/FYTester.svg?style=flat)](https://cocoapods.org/pods/FYTester)
[![Platform](https://img.shields.io/cocoapods/p/FYTester.svg?style=flat)](https://cocoapods.org/pods/FYTester)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## SceneDelegate integration

For apps using the scene lifecycle on iOS 13 and later, call `start(in:)` on the main thread after configuring the scene's main window:

```swift
import FYTester

func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
           options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }

    // Configure your app's window and rootViewController first.
    window?.makeKeyAndVisible()
    FYTester.share.start(in: windowScene)
}
```

You can also pass an existing main window's `windowScene`. The floating window and the tool window opened by double-tapping it use that same scene. FYTester shows the floating window without making it the key window.

Repeated calls reuse the floating window and its refresh loop. Passing a different scene moves FYTester to that scene and closes any open tool panel; FYTester remains a single shared overlay, not one overlay per scene.

`FYTester.share.start()` remains available for apps using the AppDelegate lifecycle. On iOS 13 and later it uses an available foreground scene when possible. In scene-based apps, calling it before a foreground scene is connected does nothing; call `start(in:)` from `SceneDelegate` once the main window is ready.

## Requirements

## Installation

FYTester is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FYTester'
```

## License

FYTester is available under the MIT license. See the LICENSE file for more info.
