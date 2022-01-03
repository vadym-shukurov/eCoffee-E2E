# eCoffee

eCoffee is an application for easy ordering different types of coffee

Test suite for eCoffee app contains E2E tests that covers happy flow for creating new order and copleating existing order

## Installation

Install latest version of XCode from appstore

Install fastlane by running command:

```gem install fastlane```

## Usage

```
To run tests from XCode perform next actions:
1. Clone project from github, (or dowload .zip file with project)
2. Open "eCoffee.xcworkspace" file from project folder
3. Open "Tests" group
4. Open eCoffeeBDDTests file
5. Run class BDDTest: eCoffeeUITestsBase by clicking on rhombus next to the class
```

```
To run tests from command line:
1. Open terminal
2. Run tests with fastlane by entring command: fastlane scan --scheme eCoffee --device "iPhone 13 Pro"
```
