# BugBattle iOS SDK

![BugBattle iOS SDK Intro](https://github.com/BugBattle/BugBattle-iOS-SDK.git/master/BugBattleInfo.png)

The BugBattle SDK for iOS is the easiest way to integrate BugBattle into your apps!

You have two ways to set up the BugBattle SDK for iOS. The easiest way ist to install and link the SDK with CocoaPods. If you haven't heard about [CocoaPods](https://cocoapods.org) yet, we strongly encourage you to check out their getting started here (it's super easy to get started & worth using 😍) 

## Installation with CocoaPods

Open a terminal window and navigate to the location of the Xcode project for your app.

**Create a Podfile if you don't have one:**

```
$ pod init
```

**Open your Podfile and add:**

```
pod 'BugBattle'
```

**Save the file and run:**

```
$ pod install
```

This creates an .xcworkspace file for your app. Use this file for all future development on your application.

The BugBattle SDK is almost installed successfully.
Let's carry on with the initialization 🎉

Open your XCode project (.xcworkspace) and open your App Delegate (AppDelegate.swift)


**Import the BugBattle SDK**

Import the BugBattle SDK by adding the following import below your other imports.

```
import BugBattle
```

**Initialize the SDK**

The last step is to initialize the BugBattle SDK by adding the following Code to the end of the applicationDidFinishLaunchingWithOptions delegate:

```
BugBattle.initialize(apiKey: "YOUR-API-KEY", activation: .Shake)
```

(Your API key can be found in the project settings within BugBattle)

## Installation without CocoaPods

