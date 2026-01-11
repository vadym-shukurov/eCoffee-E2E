//
//  ScreenProtocol.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Protocol-Oriented Page Object Model Implementation
//

import XCTest

// MARK: - Screen Protocol
/// Base protocol for all screen objects implementing the Page Object Model pattern.
/// Provides a consistent interface for screen interactions and validations.
protocol ScreenProtocol: AnyObject {
    
    /// Reference to the XCUIApplication instance
    var app: XCUIApplication { get }
    
    /// Unique identifier elements that confirm screen presence
    var screenIdentifier: XCUIElement { get }
    
    /// Validates that the screen is currently displayed
    /// - Parameter timeout: Maximum time to wait for screen to appear
    /// - Returns: Self for fluent interface chaining
    @discardableResult
    func validateScreenIsDisplayed(timeout: TimeInterval) -> Self
    
    /// Waits for the screen to be fully loaded
    /// - Parameter timeout: Maximum time to wait
    /// - Returns: Self for fluent interface chaining
    @discardableResult
    func waitForScreenToLoad(timeout: TimeInterval) -> Self
}

// MARK: - Default Implementation
extension ScreenProtocol {
    
    @discardableResult
    func validateScreenIsDisplayed(timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Self {
        let exists = screenIdentifier.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "Screen '\(type(of: self))' is not displayed. Expected element: \(screenIdentifier)")
        return self
    }
    
    @discardableResult
    func waitForScreenToLoad(timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Self {
        _ = screenIdentifier.waitForExistence(timeout: timeout)
        return self
    }
}

// MARK: - Tappable Protocol
/// Protocol for elements that can be tapped
protocol Tappable {
    associatedtype ReturnType
    
    /// Taps on the element
    /// - Returns: The expected screen/object after tap
    func tap() -> ReturnType
}

// MARK: - Scrollable Protocol
/// Protocol for elements/screens that support scrolling
protocol Scrollable {
    
    /// Scrolls up within the element
    func scrollUp()
    
    /// Scrolls down within the element
    func scrollDown()
    
    /// Scrolls to find a specific element
    /// - Parameter element: The element to find
    func scrollTo(element: XCUIElement)
}

// MARK: - Validatable Protocol
/// Protocol for screens/elements that can be validated
protocol Validatable {
    
    /// Validates the current state
    /// - Returns: Self for fluent interface
    @discardableResult
    func validate() -> Self
}

// MARK: - NavigableScreen Protocol
/// Protocol for screens that provide navigation capabilities
protocol NavigableScreen: ScreenProtocol {
    associatedtype PreviousScreen: ScreenProtocol
    
    /// Navigates back to the previous screen
    /// - Returns: The previous screen instance
    func navigateBack() -> PreviousScreen
}

// MARK: - InputScreen Protocol
/// Protocol for screens with input fields
protocol InputScreen: ScreenProtocol {
    
    /// Clears all input fields on the screen
    @discardableResult
    func clearAllInputs() -> Self
    
    /// Dismisses the keyboard if visible
    @discardableResult
    func dismissKeyboard() -> Self
}

extension InputScreen {
    
    @discardableResult
    func dismissKeyboard() -> Self {
        if app.keyboards.element.exists {
            app.toolbars.buttons["Done"].tap()
        }
        return self
    }
}

// MARK: - Alertable Protocol
/// Protocol for handling alerts
protocol Alertable {
    
    /// Accepts the currently displayed alert
    /// - Parameter buttonLabel: The label of the accept button
    func acceptAlert(buttonLabel: String)
    
    /// Dismisses the currently displayed alert
    /// - Parameter buttonLabel: The label of the dismiss button
    func dismissAlert(buttonLabel: String)
    
    /// Waits for an alert to appear
    /// - Parameter timeout: Maximum time to wait
    /// - Returns: Boolean indicating if alert appeared
    func waitForAlert(timeout: TimeInterval) -> Bool
}

extension Alertable where Self: ScreenProtocol {
    
    func acceptAlert(buttonLabel: String = "OK") {
        let alert = app.alerts.element
        _ = alert.waitForExistence(timeout: TestConfiguration.shared.defaultTimeout)
        alert.buttons[buttonLabel].tap()
    }
    
    func dismissAlert(buttonLabel: String = "Cancel") {
        let alert = app.alerts.element
        _ = alert.waitForExistence(timeout: TestConfiguration.shared.defaultTimeout)
        alert.buttons[buttonLabel].tap()
    }
    
    func waitForAlert(timeout: TimeInterval = TestConfiguration.shared.defaultTimeout) -> Bool {
        return app.alerts.element.waitForExistence(timeout: timeout)
    }
}
