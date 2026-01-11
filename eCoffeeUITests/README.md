# eCoffee UI Test Automation Framework

[![iOS UI Tests](https://github.com/vadym-shukurov/eCoffee/actions/workflows/ios-tests.yml/badge.svg)](https://github.com/vadym-shukurov/eCoffee/actions/workflows/ios-tests.yml)
[![PR Checks](https://github.com/vadym-shukurov/eCoffee/actions/workflows/pr-checks.yml/badge.svg)](https://github.com/vadym-shukurov/eCoffee/actions/workflows/pr-checks.yml)
[![Nightly Regression](https://github.com/vadym-shukurov/eCoffee/actions/workflows/nightly-regression.yml/badge.svg)](https://github.com/vadym-shukurov/eCoffee/actions/workflows/nightly-regression.yml)

> Enterprise-Grade iOS Mobile Test Automation Framework  
> **Author:** Vadym Shukurov

---

## Framework Overview

This framework represents **best-in-class mobile test automation** practices, designed for scalability, maintainability, and reliability. Built with Swift and XCTest, it showcases advanced patterns used by leading tech companies.

### Key Features

| Feature | Description |
|---------|-------------|
| **Page Object Model (POM)** | Protocol-oriented screen objects for clean separation |
| **BDD-Style Steps** | Given/When/Then step definitions for readable tests |
| **Fluent Interface** | Chainable actions for expressive test writing |
| **Smart Waiting** | Intelligent wait strategies - NO hardcoded `sleep()` |
| **Custom Assertions** | Rich failure messages with automatic screenshots |
| **Data-Driven Testing** | Parameterized tests with test data providers |
| **Comprehensive Logging** | Detailed execution logs with step tracking |
| **Screenshot on Failure** | Automatic visual debugging artifacts |
| **Configuration Management** | Environment-aware test execution |
| **Test Categorization** | Tags and priorities for test organization |

---

## Framework Architecture

```
eCoffeeUITests/
|-- Core/                          # Framework Foundation
|   |-- Base/
|   |   +-- BaseTestCase.swift     # Base class for all tests
|   |-- Configuration/
|   |   +-- TestConfiguration.swift # Centralized configuration
|   |-- Protocols/
|   |   +-- ScreenProtocol.swift   # Protocol definitions
|   +-- Utilities/
|       |-- Waiter.swift           # Smart waiting strategies
|       |-- TestLogger.swift       # Logging system
|       |-- CustomAssertions.swift # Rich assertions
|       |-- ScreenshotCapture.swift # Visual debugging
|       +-- TestPlanSupport.swift  # Xcode Test Plan support
|
|-- Screens/                       # Page Objects
|   |-- HomeScreen.swift           # Home/Catalog screen
|   |-- LoginScreen.swift          # Authentication screen
|   |-- DrinkDetailScreen.swift    # Product detail screen
|   |-- BasketScreen.swift         # Shopping cart screen
|   +-- CheckoutScreen.swift       # Payment/checkout screen
|
|-- Steps/                         # BDD Step Definitions
|   |-- GivenSteps.swift           # Preconditions (Given)
|   |-- WhenSteps.swift            # Actions (When)
|   +-- ThenSteps.swift            # Assertions (Then)
|
|-- TestData/                      # Test Data Management
|   |-- TestUser.swift             # User credentials & profiles
|   +-- TestData.swift             # Products, orders, fixtures
|
|-- Tests/                         # Test Suites
|   |-- Features/
|   |   |-- AuthenticationTests.swift
|   |   |-- CatalogTests.swift
|   |   |-- BasketTests.swift
|   |   |-- CheckoutTests.swift
|   |   +-- E2ETests.swift
|   +-- eCoffeeUITestsLaunchTests.swift
|
+-- README.md                      # This file
```

---

## Design Patterns Implemented

### 1. Page Object Model (POM)
Each screen is represented by a dedicated class with:
- **Elements**: Encapsulated UI element locators
- **Actions**: User interaction methods
- **Validations**: Screen-specific assertions

```swift
let homeScreen = HomeScreen(app: app)
    .validateHomeScreen()
    .selectDrink(at: 1)
```

### 2. Fluent Interface Pattern
Methods return `Self` enabling chainable, readable test code:

```swift
checkoutScreen
    .tapHowToPay()
    .selectPaymentMethod(.creditCard)
    .selectTip(.ten)
    .tapConfirmOrder()
    .dismissOrderConfirmation()
```

### 3. BDD-Style Step Definitions
Tests read like natural language specifications:

```swift
func test_Login_WithValidCredentials_ShouldSucceed() {
    // Given
    let loginScreen = given_UserIsOnLoginScreen()
    
    // When
    let basketScreen = when_UserLogsIn(on: loginScreen, with: .validUser)
    
    // Then
    then_LoginSuccessful()
}
```

### 4. Protocol-Oriented Design
Screens conform to protocols for consistent behavior:

```swift
protocol ScreenProtocol {
    var app: XCUIApplication { get }
    var screenIdentifier: XCUIElement { get }
    func validateScreenIsDisplayed(timeout: TimeInterval) -> Self
}
```

---

## Getting Started

### Prerequisites
- Xcode 14.0+
- iOS 15.0+ (Simulator or Device)
- Swift 5.7+

### Running Tests

**All Tests:**
```bash
xcodebuild test -workspace eCoffee.xcworkspace -scheme eCoffeeUITests -destination 'platform=iOS Simulator,name=iPhone 14'
```

**Smoke Tests Only:**
```bash
xcodebuild test -workspace eCoffee.xcworkspace -scheme eCoffeeUITests -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:eCoffeeUITests/SmokeTestSuite
```

**Feature-Specific Tests:**
```bash
xcodebuild test -workspace eCoffee.xcworkspace -scheme eCoffeeUITests -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:eCoffeeUITests/AuthenticationTests
```

---

## Writing New Tests

### Step 1: Extend Base Test Case
```swift
final class MyFeatureTests: BaseTestCase {
    
    func test_MyFeature_WhenAction_ShouldResult() {
        // Given - Setup preconditions
        let screen = given_AppIsLaunched()
        
        // When - Perform actions
        let result = when_UserPerformsAction(on: screen)
        
        // Then - Verify results
        then_ExpectedOutcomeOccurs(result)
    }
}
```

### Step 2: Create New Screen Objects
```swift
final class NewScreen: ScreenProtocol {
    let app: XCUIApplication
    
    var screenIdentifier: XCUIElement {
        return Elements.uniqueElement
    }
    
    private enum Elements {
        static var uniqueElement: XCUIElement { /* ... */ }
    }
    
    // Actions & Validations
}
```

### Step 3: Add Test Data
```swift
extension TestUser {
    static let newTestUser = TestUser(
        email: "new@ecoffee.com",
        password: "Password123!"
    )
}
```

---

## Smart Waiting (No Sleep!)

Instead of `sleep()`, use intelligent waits:

```swift
// Bad - Hardcoded delay
sleep(2)

// Good - Wait for element
Waiter.waitForElement(element, timeout: 10)

// Good - Wait for condition
Waiter.waitForCondition(timeout: 10) {
    return element.exists && element.isEnabled
}

// Good - Wait and tap
element.waitAndTap(timeout: 5)
```

---

## Custom Assertions

Rich assertions with detailed failure messages:

```swift
// Element assertions
ElementAssert.exists(element, message: "Custom failure message")
ElementAssert.isVisible(element)
ElementAssert.isEnabled(button)
ElementAssert.hasLabel(label, expected: "Expected Text")
ElementAssert.count(query, equals: 5)

// Alert assertions
AlertAssert.isDisplayed(in: app)
AlertAssert.hasTitle("Order confirmed", in: app)

// Screen assertions
ScreenAssert.isDisplayed(homeScreen)
```

---

## Test Data Management

### Predefined Test Users
```swift
TestUser.validUser      // For happy path tests
TestUser.invalidEmailUser   // For negative tests
TestUser.wrongPasswordUser  // For error handling tests
```

### Custom Test Users
```swift
let customUser = TestUserBuilder()
    .withEmail("custom@ecoffee.com")
    .withPassword("CustomPass123!")
    .withUserType(.premium)
    .build()
```

### Data-Driven Tests
```swift
let testCases = [
    (.validUser, true),
    (.invalidUser, false)
]

for (user, shouldSucceed) in testCases {
    // Test with each data set
}
```

---

## Test Tagging & Prioritization

### Test Priorities
| Priority | Description | Run Frequency |
|----------|-------------|---------------|
| P0 | Critical path - Must pass | Every build |
| P1 | High priority | Daily |
| P2 | Medium priority | Weekly |
| P3 | Low priority | On demand |

### Test Tags
- `Smoke` - Quick sanity check
- `Regression` - Full regression suite
- `E2E` - End-to-end journeys
- `Authentication` - Login/logout tests
- `Checkout` - Payment flow tests

---

## Screenshot & Reporting

### Automatic Screenshots
- Captured on test failure
- Captured at key verification points
- Named with timestamp and context

### Test Reports
- XCTest native reporting
- Allure-compatible annotations
- Custom execution summary

---

## CI/CD with GitHub Actions

This framework includes enterprise-grade CI/CD pipelines using GitHub Actions.

### Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **iOS UI Tests** | Push to main/develop | Full test suite with parallel execution |
| **PR Checks** | Pull requests | Quick build verification + linting |
| **Nightly Regression** | Daily at 2 AM UTC | Full regression + multi-version testing |

### Pipeline Features

- **Parallel Test Execution**: Tests run in parallel by test class for faster feedback
- **CocoaPods Caching**: Dependencies cached between runs for speed
- **Multi-iOS Version Testing**: Nightly runs test on iOS 16.4 and 17.0
- **Artifact Retention**: Test results and screenshots stored for 30 days
- **Automatic Issue Creation**: Failed nightly runs create GitHub issues
- **JUnit Reports**: Test results published as check annotations

### Running Tests via GitHub Actions

**Manual Trigger:**
Navigate to Actions > iOS UI Tests > Run workflow

Select test suite:
- `all` - Run entire test suite
- `smoke` - Quick sanity tests only
- `e2e` - End-to-end journeys
- `authentication` - Auth tests only
- `basket` - Basket tests only
- `checkout` - Checkout tests only
- `catalog` - Catalog tests only

### Workflow Files

```
.github/workflows/
|-- ios-tests.yml           # Main CI pipeline
|-- pr-checks.yml           # PR validation
+-- nightly-regression.yml  # Scheduled full regression
```

---

## Configuration

### Environment Variables
```bash
TEST_ENVIRONMENT=STAGING      # DEV, STAGING, PROD
DEFAULT_TIMEOUT=10            # Seconds
VERBOSE_LOGGING=true          # Enable detailed logs
CI=true                       # CI environment flag
```

### Runtime Configuration
```swift
TestConfiguration.shared.configure(
    timeout: 15,
    environment: .staging
)
```

---

## Best Practices

1. **Keep tests independent** - No test should depend on another
2. **Use explicit waits** - Never use `sleep()`
3. **Single assertion focus** - One logical assertion per test
4. **Descriptive naming** - `test_Feature_WhenAction_ShouldResult`
5. **Clean test data** - Reset state between tests
6. **Capture evidence** - Screenshots on failures
7. **Log meaningfully** - Track test execution flow

---

## Metrics & KPIs

This framework supports tracking:
- Test execution time
- Pass/fail rates
- Flaky test identification
- Coverage by feature area

---

## Maintenance Guide

### Adding New Screens
1. Create `NewScreen.swift` in `/Screens`
2. Implement `ScreenProtocol`
3. Add corresponding step definitions

### Updating Locators
1. Update only the `Elements` enum in screen class
2. All tests using that screen auto-update

### Adding New Test Data
1. Extend `TestUser` or `TestProduct`
2. Use builder pattern for complex data

---

## Author

**Vadym Shukurov**

---

*Built using Swift, XCTest, and industry best practices.*
