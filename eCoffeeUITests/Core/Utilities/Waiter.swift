//
//  Waiter.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Smart waiting strategies - NO MORE sleep()!
//

import XCTest

// MARK: - Waiter
/// Provides intelligent waiting strategies for UI elements.
/// Replaces hardcoded sleep() calls with smart, condition-based waits.
final class Waiter {
    
    // MARK: - Element Existence
    
    /// Waits for an element to exist
    /// - Parameters:
    ///   - element: The element to wait for
    ///   - timeout: Maximum wait time
    /// - Returns: True if element exists within timeout
    @discardableResult
    static func waitForElement(_ element: XCUIElement, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    /// Waits for an element to disappear
    /// - Parameters:
    ///   - element: The element to wait for disappearance
    ///   - timeout: Maximum wait time
    /// - Returns: True if element disappeared within timeout
    @discardableResult
    static func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    // MARK: - Element States
    
    /// Waits for an element to become hittable (tappable)
    /// - Parameters:
    ///   - element: The element to wait for
    ///   - timeout: Maximum wait time
    /// - Returns: True if element became hittable within timeout
    @discardableResult
    static func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Waits for an element to be enabled
    /// - Parameters:
    ///   - element: The element to wait for
    ///   - timeout: Maximum wait time
    /// - Returns: True if element became enabled within timeout
    @discardableResult
    static func waitForElementToBeEnabled(_ element: XCUIElement, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Waits for an element to have specific value
    /// - Parameters:
    ///   - element: The element to check
    ///   - value: Expected value
    ///   - timeout: Maximum wait time
    /// - Returns: True if element has expected value within timeout
    @discardableResult
    static func waitForElementValue(_ element: XCUIElement, value: String, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        let predicate = NSPredicate(format: "value == %@", value)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Waits for an element to contain specific text in its label
    /// - Parameters:
    ///   - element: The element to check
    ///   - text: Text to find in label
    ///   - timeout: Maximum wait time
    /// - Returns: True if element label contains text within timeout
    @discardableResult
    static func waitForElementLabel(_ element: XCUIElement, contains text: String, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    // MARK: - Element Count
    
    /// Waits for a query to have specific element count
    /// - Parameters:
    ///   - query: The element query
    ///   - count: Expected count
    ///   - timeout: Maximum wait time
    /// - Returns: True if count matches within timeout
    @discardableResult
    static func waitForElementCount(_ query: XCUIElementQuery, count: Int, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        let endTime = Date().addingTimeInterval(timeout)
        
        while Date() < endTime {
            if query.count == count {
                return true
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        return query.count == count
    }
    
    /// Waits for a query to have at least specified number of elements
    /// - Parameters:
    ///   - query: The element query
    ///   - minimumCount: Minimum expected count
    ///   - timeout: Maximum wait time
    /// - Returns: True if count is at least minimum within timeout
    @discardableResult
    static func waitForMinimumElementCount(_ query: XCUIElementQuery, minimumCount: Int, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        let endTime = Date().addingTimeInterval(timeout)
        
        while Date() < endTime {
            if query.count >= minimumCount {
                return true
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        return query.count >= minimumCount
    }
    
    // MARK: - Custom Conditions
    
    /// Waits for a custom condition to be met
    /// - Parameters:
    ///   - timeout: Maximum wait time
    ///   - pollInterval: Interval between condition checks
    ///   - condition: The condition closure to evaluate
    /// - Returns: True if condition met within timeout
    @discardableResult
    static func waitForCondition(
        timeout: TimeInterval = TestConfiguration.shared.defaultTimeout,
        pollInterval: TimeInterval = 0.1,
        condition: () -> Bool
    ) -> Bool {
        let endTime = Date().addingTimeInterval(timeout)
        
        while Date() < endTime {
            if condition() {
                return true
            }
            Thread.sleep(forTimeInterval: pollInterval)
        }
        
        return condition()
    }
    
    /// Waits with retry for flaky conditions
    /// - Parameters:
    ///   - maxAttempts: Maximum retry attempts
    ///   - delay: Delay between attempts
    ///   - action: The action to perform
    /// - Returns: True if action succeeded within attempts
    @discardableResult
    static func waitWithRetry(
        maxAttempts: Int = 3,
        delay: TimeInterval = 1.0,
        action: () throws -> Bool
    ) rethrows -> Bool {
        var attempt = 0
        
        while attempt < maxAttempts {
            do {
                if try action() {
                    return true
                }
            } catch {
                TestLogger.shared.warning("Retry attempt \(attempt + 1) failed: \(error.localizedDescription)")
            }
            
            attempt += 1
            if attempt < maxAttempts {
                Thread.sleep(forTimeInterval: delay)
            }
        }
        
        return false
    }
    
    // MARK: - Alert Handling
    
    /// Waits for an alert to appear
    /// - Parameters:
    ///   - app: The application instance
    ///   - timeout: Maximum wait time
    /// - Returns: True if alert appeared within timeout
    @discardableResult
    static func waitForAlert(in app: XCUIApplication, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        return app.alerts.element.waitForExistence(timeout: timeout)
    }
    
    /// Waits for an alert with specific title
    /// - Parameters:
    ///   - app: The application instance
    ///   - title: Expected alert title
    ///   - timeout: Maximum wait time
    /// - Returns: True if alert with title appeared within timeout
    @discardableResult
    static func waitForAlert(in app: XCUIApplication, withTitle title: String, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        return app.alerts[title].waitForExistence(timeout: timeout)
    }
    
    // MARK: - Keyboard
    
    /// Waits for keyboard to appear
    /// - Parameters:
    ///   - app: The application instance
    ///   - timeout: Maximum wait time
    /// - Returns: True if keyboard appeared within timeout
    @discardableResult
    static func waitForKeyboard(in app: XCUIApplication, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        return app.keyboards.element.waitForExistence(timeout: timeout)
    }
    
    /// Waits for keyboard to disappear
    /// - Parameters:
    ///   - app: The application instance
    ///   - timeout: Maximum wait time
    /// - Returns: True if keyboard disappeared within timeout
    @discardableResult
    static func waitForKeyboardToDisappear(in app: XCUIApplication, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        return waitForElementToDisappear(app.keyboards.element, timeout: timeout)
    }
    
    // MARK: - Activity Indicator
    
    /// Waits for loading indicator to disappear
    /// - Parameters:
    ///   - app: The application instance
    ///   - timeout: Maximum wait time
    /// - Returns: True if indicator disappeared within timeout
    @discardableResult
    static func waitForLoadingToComplete(in app: XCUIApplication, timeout: TimeInterval = TestConfiguration.shared.longTimeout) -> Bool {
        let activityIndicators = app.activityIndicators.element
        
        // First check if it exists
        if activityIndicators.exists {
            return waitForElementToDisappear(activityIndicators, timeout: timeout)
        }
        
        return true
    }
}

// MARK: - XCUIElement Waiting Extensions
extension XCUIElement {
    
    /// Waits for element and taps it
    /// - Parameter timeout: Maximum wait time
    /// - Returns: True if element was tapped successfully
    @discardableResult
    func waitAndTap(timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        guard waitForExistence(timeout: timeout) else {
            return false
        }
        tap()
        return true
    }
    
    /// Waits for element to be hittable and taps it
    /// - Parameter timeout: Maximum wait time
    /// - Returns: True if element was tapped successfully
    @discardableResult
    func waitUntilHittableAndTap(timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        guard Waiter.waitForElementToBeHittable(self, timeout: timeout) else {
            return false
        }
        tap()
        return true
    }
    
    /// Waits for element and types text
    /// - Parameters:
    ///   - text: Text to type
    ///   - timeout: Maximum wait time
    /// - Returns: True if text was typed successfully
    @discardableResult
    func waitAndType(_ text: String, timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        guard waitForExistence(timeout: timeout) else {
            return false
        }
        tap()
        typeText(text)
        return true
    }
    
    /// Clears existing text and types new text
    /// - Parameter text: Text to type
    func clearAndType(_ text: String) {
        guard let stringValue = self.value as? String else {
            tap()
            typeText(text)
            return
        }
        
        tap()
        
        // Select all and delete
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
        typeText(text)
    }
    
    /// Checks if element is visible in viewport
    var isVisibleInViewport: Bool {
        guard exists && !frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
}
