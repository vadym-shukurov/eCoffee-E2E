# eCoffee

![iOS UI Tests](https://github.com/{owner}/{repo}/actions/workflows/ios-tests.yml/badge.svg)
![PR Checks](https://github.com/{owner}/{repo}/actions/workflows/pr-checks.yml/badge.svg)

eCoffee is an iOS application for ordering coffee with a comprehensive, enterprise-grade UI test automation framework.

> **Author:** Vadym Shukurov

## Features

- Browse coffee catalog
- Add items to basket
- Complete checkout with multiple payment methods
- User authentication

## Requirements

- Xcode 15.0+
- iOS 16.0+ (Simulator or Device)
- Swift 5.9+
- CocoaPods

## Installation

1. Clone the repository:
```bash
git clone https://github.com/{owner}/{repo}.git
cd eCoffee
```

2. Install dependencies:
```bash
pod install
```

3. Open the workspace:
```bash
open eCoffee.xcworkspace
```

## Running the App

1. Open `eCoffee.xcworkspace` in Xcode
2. Select a simulator or device
3. Press `Cmd + R` to build and run

## Running Tests

### From Xcode

1. Open `eCoffee.xcworkspace`
2. Press `Cmd + U` to run all tests
3. Or navigate to the Test Navigator (`Cmd + 6`) and run specific test classes

### From Command Line

**Run all UI tests:**
```bash
xcodebuild test \
  -workspace eCoffee.xcworkspace \
  -scheme eCoffeeUITests \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Run specific test class:**
```bash
xcodebuild test \
  -workspace eCoffee.xcworkspace \
  -scheme eCoffeeUITests \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:eCoffeeUITests/AuthenticationTests
```

**Run smoke tests:**
```bash
xcodebuild test \
  -workspace eCoffee.xcworkspace \
  -scheme eCoffeeUITests \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:eCoffeeUITests/SmokeTests
```

## Test Framework

The test suite features an enterprise-grade automation framework with:

- **Page Object Model (POM)** - Clean separation of UI elements and test logic
- **BDD-Style Steps** - Given/When/Then for readable tests
- **Fluent Interface** - Chainable actions for expressive tests
- **Smart Waiting** - No hardcoded `sleep()` calls
- **Custom Assertions** - Detailed failure messages with screenshots
- **Comprehensive Logging** - Full execution tracking

See [eCoffeeUITests/README.md](eCoffeeUITests/README.md) for detailed framework documentation.

## CI/CD

This project uses GitHub Actions for continuous integration:

- **iOS UI Tests** - Runs on push to main/develop branches
- **PR Checks** - Validates builds and code quality on pull requests
- **Nightly Regression** - Full regression suite runs daily at 2 AM UTC

## Project Structure

```
eCoffee/
├── eCoffee/                    # Main application
├── eCoffeeUITests/             # UI Test Framework
│   ├── Core/                   # Framework foundation
│   ├── Screens/                # Page Objects
│   ├── Steps/                  # BDD step definitions
│   ├── TestData/               # Test data management
│   └── Tests/                  # Test suites
├── .github/workflows/          # CI/CD pipelines
├── Podfile                     # CocoaPods dependencies
└── README.md                   # This file
```

## License

This project is proprietary.
