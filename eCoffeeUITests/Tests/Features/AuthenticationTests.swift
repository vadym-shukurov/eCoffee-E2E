//
//  AuthenticationTests.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Feature: User Authentication
//  Tests for login, logout, and session management
//

import XCTest

// MARK: - Authentication Tests
/// Core authentication test suite covering critical user flows.
final class AuthenticationTests: BaseTestCase {
    
    // MARK: - Properties
    private var credentialsProvider: UserCredentialsProvider {
        return UserCredentialsProvider.shared
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        logger.resetStepCounter()
    }
    
    // MARK: - Login Tests (P0 - Critical)
    
    /// Verifies user can login with valid credentials and gains access to authenticated features.
    func test_Login_WithValidCredentials_ShouldGrantAccess() throws {
        // Given
        let user = credentialsProvider.getUser(for: .happyPath)
        let homeScreen = launchApp()
        _ = homeScreen.tapBasket()
        let loginScreen = LoginScreen(app: app)
        
        // When
        _ = loginScreen.login(with: user)
        
        // Then - Verify authenticated state by checking logout button visibility
        let logoutButton = app.buttons["LogOut"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: config.defaultTimeout),
                      "Logout button should be visible after successful login")
    }
    
    /// Verifies login fails with incorrect password and user remains on login screen.
    func test_Login_WithWrongPassword_ShouldRemainOnLoginScreen() throws {
        // Given
        let homeScreen = launchApp()
        _ = homeScreen.tapBasket()
        let loginScreen = LoginScreen(app: app)
        
        // When
        _ = loginScreen.enterEmail(TestUser.validUser.email)
            .enterPassword("WrongPassword123!")
            .tapSignInExpectingFailure()
        
        // Then - Verify still on login screen (email field still visible)
        let emailField = app.textFields["EnterEmail"]
        XCTAssertTrue(emailField.exists, "Email field should still be visible - user should remain on login screen")
    }
    
    /// Verifies login fails with invalid email format.
    func test_Login_WithInvalidEmailFormat_ShouldNotProceed() throws {
        // Given
        let homeScreen = launchApp()
        _ = homeScreen.tapBasket()
        let loginScreen = LoginScreen(app: app)
        
        // When
        _ = loginScreen.enterEmail("invalid-email-format")
            .enterPassword("Password123!")
            .tapSignInExpectingFailure()
        
        // Then
        let emailField = app.textFields["EnterEmail"]
        XCTAssertTrue(emailField.exists, "Should remain on login screen with invalid email")
    }
    
    // MARK: - Logout Tests (P0 - Critical)
    
    /// Verifies user can logout and loses access to authenticated features.
    func test_Logout_ShouldRemoveAuthenticatedAccess() throws {
        // Given - User is logged in
        _ = given_UserIsLoggedIn()
        let homeScreen = HomeScreen(app: app)
        
        // Verify logged in state
        XCTAssertTrue(app.buttons["LogOut"].exists, "Precondition: User should be logged in")
        
        // When
        _ = homeScreen.tapLogOut()
        
        // Then - Verify logged out (logout button should disappear or change)
        let logoutButton = app.buttons["LogOut"]
        // After logout, tapping basket should show login screen
        homeScreen.tapBasket()
        let loginScreen = app.textFields["EnterEmail"]
        XCTAssertTrue(loginScreen.waitForExistence(timeout: config.defaultTimeout),
                      "Login screen should appear after logout when accessing basket")
    }
    
    // MARK: - Session Management (P1 - High)
    
    /// Verifies user session persists after app relaunch.
    func test_Session_AfterAppRelaunch_ShouldRemainLoggedIn() throws {
        // Given - User logs in
        _ = given_UserIsLoggedIn()
        XCTAssertTrue(app.buttons["LogOut"].exists, "Precondition: User should be logged in")
        
        // When - Relaunch app
        app.terminate()
        app.launch()
        
        // Then - Should still be logged in
        let logoutButton = app.buttons["LogOut"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: config.defaultTimeout),
                      "User should remain logged in after app relaunch")
    }
    
    /// Verifies unauthenticated user is redirected to login when accessing basket.
    func test_Basket_WhenNotLoggedIn_ShouldShowLoginScreen() throws {
        // Given - Fresh app launch (not logged in)
        let homeScreen = launchApp()
        
        // Logout if already logged in
        if app.buttons["LogOut"].exists {
            _ = homeScreen.tapLogOut()
        }
        
        // When - Try to access basket
        _ = homeScreen.tapBasket()
        
        // Then - Should show login screen
        let emailField = app.textFields["EnterEmail"]
        XCTAssertTrue(emailField.waitForExistence(timeout: config.defaultTimeout),
                      "Login screen should appear when unauthenticated user tries to access basket")
    }
}

// MARK: - Data-Driven Authentication Tests
/// Demonstrates data-driven testing using parameterized test cases.
/// Uses the TestCase<Input, Expected> pattern for systematic test coverage.
final class DataDrivenAuthenticationTests: BaseTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        logger.resetStepCounter()
    }
    
    /// Data-driven test: Validates login behavior with multiple credential combinations.
    /// Uses predefined test cases from TestData for comprehensive coverage.
    func test_Login_DataDriven_ShouldMatchExpectedOutcome() throws {
        // Get all login test cases from centralized test data
        let testCases = TestCase<TestUser, Bool>.loginTestCases
        
        for testCase in testCases {
            // Log test case execution
            logger.section("Data-Driven Test: \(testCase.name)")
            logger.testData("Tags: \(testCase.tags.joined(separator: ", "))")
            
            // Given - Fresh app state for each iteration
            app.terminate()
            app.launch()
            
            let homeScreen = HomeScreen(app: app)
            
            // Logout if logged in from previous iteration
            if app.buttons["LogOut"].exists {
                _ = homeScreen.tapLogOut()
            }
            
            _ = homeScreen.tapBasket()
            let loginScreen = LoginScreen(app: app)
            
            // When - Attempt login with test case credentials
            if testCase.expected {
                // Expected success - use normal login flow
                _ = loginScreen.login(with: testCase.input)
            } else {
                // Expected failure - use failure-aware login
                _ = loginScreen.enterEmail(testCase.input.email)
                    .enterPassword(testCase.input.password)
                    .tapSignInExpectingFailure()
            }
            
            // Then - Verify outcome matches expectation
            if testCase.expected {
                let logoutButton = app.buttons["LogOut"]
                XCTAssertTrue(
                    logoutButton.waitForExistence(timeout: config.defaultTimeout),
                    "[\(testCase.name)] Login should succeed for valid credentials"
                )
            } else {
                let emailField = app.textFields["EnterEmail"]
                XCTAssertTrue(
                    emailField.waitForExistence(timeout: config.shortTimeout),
                    "[\(testCase.name)] Should remain on login screen for invalid credentials"
                )
            }
            
            logger.info("Test case '\(testCase.name)' completed")
        }
    }
}
