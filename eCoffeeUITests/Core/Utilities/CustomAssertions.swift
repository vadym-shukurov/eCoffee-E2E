//
//  CustomAssertions.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Rich custom assertions with detailed failure messages
//

import XCTest

// MARK: - Element Assertions
/// Custom assertions for XCUIElement with detailed failure messages
struct ElementAssert {
    
    private static var logger: TestLogger { TestLogger.shared }
    
    // MARK: - Existence
    
    /// Asserts element exists within timeout
    static func exists(
        _ element: XCUIElement,
        timeout: TimeInterval = TestConfiguration.shared.defaultTimeout,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exists = element.waitForExistence(timeout: timeout)
        let failureMessage = message ?? "Element '\(element.identifier)' does not exist after \(timeout)s. Element type: \(element.elementType.rawValue)"
        
        if !exists {
            logger.error("Assertion Failed: \(failureMessage)")
            captureFailureScreenshot(context: "element_not_exists")
        }
        
        XCTAssertTrue(exists, failureMessage, file: file, line: line)
        logger.verify("Element exists: \(element.identifier)")
    }
    
    /// Asserts element does not exist
    static func notExists(
        _ element: XCUIElement,
        timeout: TimeInterval = TestConfiguration.shared.shortTimeout,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let disappeared = Waiter.waitForElementToDisappear(element, timeout: timeout)
        let failureMessage = message ?? "Element '\(element.identifier)' still exists after \(timeout)s"
        
        if !disappeared {
            logger.error("Assertion Failed: \(failureMessage)")
            captureFailureScreenshot(context: "element_still_exists")
        }
        
        XCTAssertTrue(disappeared, failureMessage, file: file, line: line)
        logger.verify("Element does not exist: \(element.identifier)")
    }
    
    // MARK: - Visibility
    
    /// Asserts element is visible
    static func isVisible(
        _ element: XCUIElement,
        timeout: TimeInterval = TestConfiguration.shared.defaultTimeout,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        _ = element.waitForExistence(timeout: timeout)
        let isVisible = element.exists && element.isHittable
        let failureMessage = message ?? "Element '\(element.identifier)' is not visible. Exists: \(element.exists), Hittable: \(element.isHittable)"
        
        if !isVisible {
            logger.error("Assertion Failed: \(failureMessage)")
            captureFailureScreenshot(context: "element_not_visible")
        }
        
        XCTAssertTrue(isVisible, failureMessage, file: file, line: line)
        logger.verify("Element is visible: \(element.identifier)")
    }
    
    // MARK: - State
    
    /// Asserts element is enabled
    static func isEnabled(
        _ element: XCUIElement,
        timeout: TimeInterval = TestConfiguration.shared.defaultTimeout,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        _ = Waiter.waitForElementToBeEnabled(element, timeout: timeout)
        let failureMessage = message ?? "Element '\(element.identifier)' is not enabled"
        
        if !element.isEnabled {
            logger.error("Assertion Failed: \(failureMessage)")
            captureFailureScreenshot(context: "element_not_enabled")
        }
        
        XCTAssertTrue(element.isEnabled, failureMessage, file: file, line: line)
        logger.verify("Element is enabled: \(element.identifier)")
    }
    
    /// Asserts element is disabled
    static func isDisabled(
        _ element: XCUIElement,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let failureMessage = message ?? "Element '\(element.identifier)' is not disabled"
        
        if element.isEnabled {
            logger.error("Assertion Failed: \(failureMessage)")
        }
        
        XCTAssertFalse(element.isEnabled, failureMessage, file: file, line: line)
        logger.verify("Element is disabled: \(element.identifier)")
    }
    
    /// Asserts element is selected
    static func isSelected(
        _ element: XCUIElement,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let failureMessage = message ?? "Element '\(element.identifier)' is not selected"
        XCTAssertTrue(element.isSelected, failureMessage, file: file, line: line)
        logger.verify("Element is selected: \(element.identifier)")
    }
    
    // MARK: - Text/Value
    
    /// Asserts element has expected label
    static func hasLabel(
        _ element: XCUIElement,
        expected: String,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let actual = element.label
        let failureMessage = message ?? "Element label mismatch. Expected: '\(expected)', Actual: '\(actual)'"
        
        if actual != expected {
            logger.error("Assertion Failed: \(failureMessage)")
        }
        
        XCTAssertEqual(actual, expected, failureMessage, file: file, line: line)
        logger.verify("Element has label '\(expected)'")
    }
    
    /// Asserts element label contains text
    static func labelContains(
        _ element: XCUIElement,
        substring: String,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let actual = element.label
        let contains = actual.contains(substring)
        let failureMessage = message ?? "Element label '\(actual)' does not contain '\(substring)'"
        
        if !contains {
            logger.error("Assertion Failed: \(failureMessage)")
        }
        
        XCTAssertTrue(contains, failureMessage, file: file, line: line)
        logger.verify("Element label contains '\(substring)'")
    }
    
    /// Asserts element has expected value
    static func hasValue(
        _ element: XCUIElement,
        expected: String,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let actual = element.value as? String ?? ""
        let failureMessage = message ?? "Element value mismatch. Expected: '\(expected)', Actual: '\(actual)'"
        
        if actual != expected {
            logger.error("Assertion Failed: \(failureMessage)")
        }
        
        XCTAssertEqual(actual, expected, failureMessage, file: file, line: line)
        logger.verify("Element has value '\(expected)'")
    }
    
    /// Asserts text field is empty
    static func isEmpty(
        _ element: XCUIElement,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let value = element.value as? String ?? ""
        let failureMessage = message ?? "Element '\(element.identifier)' is not empty. Current value: '\(value)'"
        
        XCTAssertTrue(value.isEmpty, failureMessage, file: file, line: line)
        logger.verify("Element is empty")
    }
    
    /// Asserts text field is not empty
    static func isNotEmpty(
        _ element: XCUIElement,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let value = element.value as? String ?? ""
        let failureMessage = message ?? "Element '\(element.identifier)' is empty"
        
        XCTAssertFalse(value.isEmpty, failureMessage, file: file, line: line)
        logger.verify("Element is not empty")
    }
    
    // MARK: - Count
    
    /// Asserts element count matches expected
    static func count(
        _ query: XCUIElementQuery,
        equals expected: Int,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let actual = query.count
        let failureMessage = message ?? "Element count mismatch. Expected: \(expected), Actual: \(actual)"
        
        if actual != expected {
            logger.error("Assertion Failed: \(failureMessage)")
        }
        
        XCTAssertEqual(actual, expected, failureMessage, file: file, line: line)
        logger.verify("Element count equals \(expected)")
    }
    
    /// Asserts element count is at least minimum
    static func countAtLeast(
        _ query: XCUIElementQuery,
        minimum: Int,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let actual = query.count
        let failureMessage = message ?? "Element count \(actual) is less than minimum \(minimum)"
        
        XCTAssertGreaterThanOrEqual(actual, minimum, failureMessage, file: file, line: line)
        logger.verify("Element count (\(actual)) is at least \(minimum)")
    }
    
    // MARK: - Helper
    
    private static func captureFailureScreenshot(context: String) {
        let app = XCUIApplication()
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "assertion_failure_\(context)_\(Date().timeIntervalSince1970)"
        screenshot.lifetime = .keepAlways
        // Note: We can't directly add attachment here, but it's logged for debugging
    }
}

// MARK: - Alert Assertions
/// Custom assertions for alerts
struct AlertAssert {
    
    private static var logger: TestLogger { TestLogger.shared }
    
    /// Asserts alert is displayed
    static func isDisplayed(
        in app: XCUIApplication,
        timeout: TimeInterval = TestConfiguration.shared.defaultTimeout,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let alertExists = app.alerts.element.waitForExistence(timeout: timeout)
        let failureMessage = message ?? "No alert is displayed"
        
        XCTAssertTrue(alertExists, failureMessage, file: file, line: line)
        logger.verify("Alert is displayed")
    }
    
    /// Asserts alert has expected title
    static func hasTitle(
        _ title: String,
        in app: XCUIApplication,
        timeout: TimeInterval = TestConfiguration.shared.defaultTimeout,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let alertExists = app.alerts[title].waitForExistence(timeout: timeout)
        let failureMessage = message ?? "Alert with title '\(title)' not found"
        
        XCTAssertTrue(alertExists, failureMessage, file: file, line: line)
        logger.verify("Alert has title '\(title)'")
    }
    
    /// Asserts alert has expected button
    static func hasButton(
        _ buttonLabel: String,
        in app: XCUIApplication,
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let buttonExists = app.alerts.buttons[buttonLabel].exists
        let failureMessage = message ?? "Alert button '\(buttonLabel)' not found"
        
        XCTAssertTrue(buttonExists, failureMessage, file: file, line: line)
        logger.verify("Alert has button '\(buttonLabel)'")
    }
}

// MARK: - Screen Assertions
/// Custom assertions for screens
struct ScreenAssert {
    
    private static var logger: TestLogger { TestLogger.shared }
    
    /// Asserts screen is displayed
    static func isDisplayed<T: ScreenProtocol>(
        _ screen: T,
        timeout: TimeInterval = TestConfiguration.shared.defaultTimeout,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let screenName = String(describing: type(of: screen))
        let exists = screen.screenIdentifier.waitForExistence(timeout: timeout)
        let failureMessage = "\(screenName) is not displayed"
        
        if !exists {
            logger.error("Assertion Failed: \(failureMessage)")
        }
        
        XCTAssertTrue(exists, failureMessage, file: file, line: line)
        logger.validatingScreen(screenName)
    }
}
