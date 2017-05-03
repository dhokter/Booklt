# BookIt

BookIt is an iOS application that helps the user to keep track on the current page they are reading on their books without any spending on the physical bookmarks, as well as risking their books to be damaged because of the side effect of a bookmark. It also serves as a tracker for the wishlist of users and provides a quick summary of the user's reading history.

This application is built for on iPhone with iOS 10.2 or above using Swift 3 as the primary programming language and XCode 8 as the main developing environment.

* The main project can be found [here](https://github.com/dletk/BookIt).
* For more information, please contact us at Duc Le (dle@macalester.edu), Spencer Grant (sgrant1@macalester.edu), Kelli Mandel (kmandel@macalester.edu).

# Installation and development information

### Installing XCode

XCode is provided freely by Apple for Mac users, and the application can be downloaded from the Mac App Store. XCode has a built-in simulator to provide the user with a simulation of a real iPhone/iPad (with different models listed), so a real iPhone is not required for developing process.

### Installing Carthage and adding frameworks
    
Carthage is a dependency manager that assist developers in the management of frameworks and APIs used in their project. The full details of features and documentation for Carthage can be found [here](https://github.com/Carthage/Carthage).
    
BookIt uses Carthage as its dependency manager to keep an eye on its dependent frameworks and APIs. To install Carthage on your Mac, please follow [this](https://github.com/Carthage/Carthage#installing-carthage) official instruction from Carthage team. In the case of our team, we have followed these steps using [HomeBrew](https://brew.sh/) in the Terminal:
    
 ```swift
 brew update
 brew install carthage
 ```
After having Carthage installed, you can add the all the required frameworks into the project by following these [steps](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos). **Note: You only need to follow the all the steps to add the first framework. After that, repeat step 2-4 and update the Cartfile for other frameworks.**
### Required frameworks and APIs
BookIt requires the following frameworks and APIs:

1. [Realm](https://realm.io/products/realm-mobile-database/): The mobile database that helps store user data into local storage.
2. [PureLayout](https://github.com/PureLayout/PureLayout): The API to assist the process of developing Auto Layout for the project.
3. [MGSwipeTableCell](https://github.com/MortimerGoro/MGSwipeTableCell): The API to implement extended swipe features for the UITableViewCell.

The project repo on Github already included the updated [Cartfile](https://github.com/dletk/BookIt/blob/master/Cartfile). After having Carthage installed and cloned the project, please run `carthage update` in the Terminal to get all the frameworks and APIs needed, then follow the instruction above for adding frameworks to the project on your Mac.