# BookIt

BookIt is an iOS application that helps the user to keep track of the page they are on in each of the books they are reading, thus eliminating the necessity of a physical bookmark for each book they are reading. It also allows the user to keep a list of the books they have finished reading and a list of the books that they would like to read in the future.

This application is compatible with any iPhone running on iOS 10.2 or above and was build using Swift 3 as the primary programming language and XCode 8 as the main developing environment.

* The main project can be found [here](https://github.com/dletk/BookIt).
* For more information, please contact us at Duc Le (dle@macalester.edu), Spencer Grant (sgrant1@macalester.edu), or Kelli Mandel (kmandel@macalester.edu).

# Installation and development information

### Installing XCode

XCode 8 is provided for free by Apple for Mac users, and the application can be downloaded from the App Store on Mac. XCode has a built-in simulator to provide the user with a simulation of a real iPhone/iPad (with different models listed), so a real iPhone is not required for developing process.

### Installing Carthage and adding frameworks
    
Carthage is a dependency manager that assists developers in the management of frameworks and APIs used in their project. A full description of features and documentation for Carthage can be found [here](https://github.com/Carthage/Carthage).
    
BookIt uses Carthage as its dependency manager to keep an eye on its dependent frameworks and APIs. To install Carthage on your Mac, please follow [this](https://github.com/Carthage/Carthage#installing-carthage) official step-by-step process outlined by the Carthage team. Our team followed these steps using [HomeBrew](https://brew.sh/) in the Terminal:
    
 ```swift
 brew update
 brew install carthage
 ```
After installing Carthage, you may add the all the required frameworks into the project by following these [steps](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos). **Note: You only need to follow the all the steps to add the first framework. After that, repeat steps 2-4 and update the Cartfile for other frameworks.**
### Required frameworks and APIs
BookIt requires the following frameworks and APIs:

1. [Realm](https://realm.io/products/realm-mobile-database/): A mobile database that stores the app's data into local storage.
2. [PureLayout](https://github.com/PureLayout/PureLayout): This API allows for the development of Auto Layout for BookIt.
3. [MGSwipeTableCell](https://github.com/MortimerGoro/MGSwipeTableCell): This API allows for the implementation of extended swipe features for the UITableViewCell.

The project repo on Github already includes the updated [Cartfile](https://github.com/dletk/BookIt/blob/master/Cartfile). After having Carthage installed and cloned the project, please run `carthage update` in the Terminal to get all the frameworks and APIs needed, then follow the instruction above for adding frameworks to the project on your Mac.
