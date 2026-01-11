//
//  LoginScreen.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Page Object Model - Login Screen
//

import XCTest

// MARK: - Login Screen
/// Page Object for the Login/Authentication screen
final class LoginScreen: ScreenProtocol, InputScreen {
    
    // MARK: - Properties
    let app: XCUIApplication
    
    // MARK: - Screen Identifier
    var screenIdentifier: XCUIElement {
        return Elements.emailField
    }
    
    // MARK: - Initializer
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Elements
    private enum Elements {
        static var app: XCUIApplication { XCUIApplication() }
        
        // Form Fields
        static var emailPrompt: XCUIElement { app.staticTexts["Enter your email"] }
        static var emailField: XCUIElement { app.textFields["EnterEmail"] }
        static var passwordField: XCUIElement { app.secureTextFields["Password"] }
        
        // Buttons
        static var signInButton: XCUIElement { app.buttons["Sign"] }
        static var registerButton: XCUIElement { app.buttons["Register"] }
        static var forgotPasswordButton: XCUIElement { app.buttons["Forgot Password"] }
    }
    
    // MARK: - Input Actions
    
    /// Enters email address
    /// - Parameter email: Email to enter
    /// - Returns: Self for chaining
    @discardableResult
    func enterEmail(_ email: String) -> LoginScreen {
        TestLogger.shared.action("Entering email: \(email)")
        ElementAssert.exists(Elements.emailField)
        Elements.emailField.tap()
        Elements.emailField.typeText(email)
        return self
    }
    
    /// Enters password
    /// - Parameter password: Password to enter (not logged for security)
    /// - Returns: Self for chaining
    @discardableResult
    func enterPassword(_ password: String) -> LoginScreen {
        TestLogger.shared.action("Entering password: ********")
        ElementAssert.exists(Elements.passwordField)
        Elements.passwordField.tap()
        Elements.passwordField.typeText(password)
        return self
    }
    
    /// Clears all input fields
    @discardableResult
    func clearAllInputs() -> LoginScreen {
        TestLogger.shared.action("Clearing all input fields")
        if let value = Elements.emailField.value as? String, !value.isEmpty {
            Elements.emailField.tap()
            Elements.emailField.clearAndType("")
        }
        return self
    }
    
    // MARK: - Submit Actions
    
    /// Taps the Sign In button expecting success
    /// - Returns: BasketScreen on successful login
    @discardableResult
    func tapSignIn() -> BasketScreen {
        TestLogger.shared.action("Tapping Sign In button")
        ElementAssert.exists(Elements.signInButton)
        Elements.signInButton.tap()
        
        // Wait for transition
        _ = Waiter.waitForElementToDisappear(Elements.signInButton)
        
        return BasketScreen(app: app)
    }
    
    /// Taps the Sign In button expecting failure (stays on login screen)
    /// - Returns: LoginScreen instance
    @discardableResult
    func tapSignInExpectingFailure() -> LoginScreen {
        TestLogger.shared.action("Tapping Sign In expecting failure")
        ElementAssert.exists(Elements.signInButton)
        Elements.signInButton.tap()
        return self
    }
    
    /// Taps Register button
    /// - Returns: RegistrationScreen instance
    @discardableResult
    func tapRegister() -> RegistrationScreen {
        TestLogger.shared.action("Tapping Register button")
        ElementAssert.exists(Elements.registerButton)
        Elements.registerButton.tap()
        return RegistrationScreen(app: app)
    }
    
    // MARK: - Complete Login Flow
    
    /// Performs complete login with provided credentials
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    /// - Returns: BasketScreen on success
    @discardableResult
    func login(email: String, password: String) -> BasketScreen {
        TestLogger.shared.section("Login Flow")
        return enterEmail(email)
            .enterPassword(password)
            .tapSignIn()
    }
    
    /// Performs complete login with test user credentials
    /// - Parameter user: TestUser instance containing credentials
    /// - Returns: BasketScreen on success
    @discardableResult
    func login(with user: TestUser) -> BasketScreen {
        return login(email: user.email, password: user.password)
    }
    
    // MARK: - Validations
    
    /// Validates login screen is displayed
    @discardableResult
    func validateLoginScreen() -> LoginScreen {
        TestLogger.shared.validatingScreen("LoginScreen")
        ElementAssert.exists(Elements.emailPrompt, message: "Email prompt not visible")
        ElementAssert.exists(Elements.emailField, message: "Email field not visible")
        ElementAssert.exists(Elements.passwordField, message: "Password field not visible")
        ElementAssert.exists(Elements.signInButton, message: "Sign In button not visible")
        return self
    }
    
    /// Validates error message is displayed
    /// - Parameter message: Expected error message
    @discardableResult
    func validateErrorMessage(_ message: String) -> LoginScreen {
        TestLogger.shared.verify("Error message: \(message)")
        let errorLabel = app.staticTexts[message]
        ElementAssert.exists(errorLabel, timeout: TestConfiguration.shared.shortTimeout)
        return self
    }
    
    /// Validates Sign In button is enabled/disabled
    /// - Parameter enabled: Expected enabled state
    @discardableResult
    func validateSignInButton(enabled: Bool) -> LoginScreen {
        if enabled {
            ElementAssert.isEnabled(Elements.signInButton)
        } else {
            ElementAssert.isDisabled(Elements.signInButton)
        }
        return self
    }
}

// MARK: - Registration Screen
/// Page Object for the Registration screen
final class RegistrationScreen: ScreenProtocol {
    
    let app: XCUIApplication
    
    var screenIdentifier: XCUIElement {
        return app.staticTexts["Create Account"]
    }
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    /// Validates registration screen is displayed
    @discardableResult
    func validateRegistrationScreen() -> RegistrationScreen {
        TestLogger.shared.validatingScreen("RegistrationScreen")
        _ = screenIdentifier.waitForExistence(timeout: TestConfiguration.shared.defaultTimeout)
        return self
    }
}
