//
//  E2ETests.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  End-to-End Test Scenarios
//  Critical user journeys covering complete flows
//

import XCTest

// MARK: - E2E Tests
/// End-to-end test scenarios covering complete user journeys.
/// These tests verify critical business flows work correctly.
final class E2ETests: BaseTestCase {
    
    // MARK: - Properties
    private let metrics = TestMetricsCollector.shared
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        logger.resetStepCounter()
        metrics.recordStart(testName: currentTestName)
    }
    
    override func tearDownWithError() throws {
        // Record test completion with pass/fail status
        let passed = testRun?.failureCount == 0
        metrics.recordCompletion(testName: currentTestName, passed: passed)
        try super.tearDownWithError()
    }
    
    // MARK: - Complete Order Journey (P0 - Critical)
    
    /// Full user journey: Browse -> Login -> Add to Cart -> Checkout -> Order Complete
    /// This is the most critical test - the primary revenue path.
    ///
    /// Allure Annotations:
    /// - Feature: Order Management
    /// - Story: Complete Purchase Flow
    /// - Severity: Critical
    func test_E2E_CompleteOrderJourney() throws {
        // Log Allure-compatible annotations for reporting integration
        addTextAttachment(AllureAnnotations.feature("Order Management"), named: "Feature")
        addTextAttachment(AllureAnnotations.story("Complete Purchase Flow"), named: "Story")
        addTextAttachment(AllureAnnotations.severity("Critical"), named: "Severity")
        addTextAttachment(AllureAnnotations.testCaseId("E2E-001"), named: "TestCaseId")
        // Step 1: Launch and verify catalog
        let homeScreen = launchApp()
        XCTAssertTrue(app.staticTexts["iCoffee"].exists, "App should launch to catalog")
        XCTAssertGreaterThan(app.cells.count, 0, "Products should be visible")
        
        // Step 2: Select a product and add to basket
        let detailScreen = homeScreen.selectDrink(at: 1)
        let addButton = app.scrollViews.otherElements.buttons["AddToBasket"]
        XCTAssertTrue(addButton.waitForExistence(timeout: config.defaultTimeout),
                      "Add to basket button should be visible")
        
        _ = detailScreen.tapAddToBasket()
        let addedAlert = app.alerts["Added to  Basket!"]
        XCTAssertTrue(addedAlert.waitForExistence(timeout: config.defaultTimeout),
                      "Added confirmation should appear")
        addedAlert.buttons["OK"].tap()
        
        // Step 3: Navigate to basket (triggers login flow if needed)
        _ = homeScreen.tapBasket()
        
        // Handle login if required
        let emailField = app.textFields["EnterEmail"]
        if emailField.waitForExistence(timeout: config.shortTimeout) {
            let loginScreen = LoginScreen(app: app)
            _ = loginScreen.login(with: .validUser)
        }
        
        // Step 4: Verify basket has item and place order
        let placeOrderButton = app.buttons["PlaceOrder"]
        XCTAssertTrue(placeOrderButton.waitForExistence(timeout: config.defaultTimeout),
                      "Place Order should be accessible")
        placeOrderButton.tap()
        
        // Step 5: Complete checkout
        let howToPayButton = app.tables.buttons["HowToPay"]
        XCTAssertTrue(howToPayButton.waitForExistence(timeout: config.defaultTimeout),
                      "Should be on checkout screen")
        
        howToPayButton.tap()
        app.tables.switches["Credit Card"].tap()
        app.buttons["ConfirmOrder"].tap()
        
        // Step 6: Verify order confirmation
        let confirmationAlert = app.alerts["Order confirmed"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: config.defaultTimeout),
                      "Order confirmation should appear")
        
        confirmationAlert.buttons["OK"].tap()
        logger.info("E2E order journey completed successfully")
    }
    
    /// User journey: Login -> Add multiple items -> Complete order
    func test_E2E_MultipleItemsOrder() throws {
        // Login first
        _ = given_UserIsLoggedIn()
        let homeScreen = HomeScreen(app: app)
        
        // Add 2 different items
        for index in 1...2 {
            let detailScreen = homeScreen.selectDrink(at: index)
            _ = detailScreen.addToBasketAndConfirm()
        }
        
        // Verify basket count
        let basketScreen = homeScreen.tapBasket()
        let cellCount = app.tables.cells.count - 1 // Minus Place Order
        XCTAssertEqual(cellCount, 2, "Basket should have 2 items")
        
        // Complete order
        _ = basketScreen.tapPlaceOrder()
        app.tables.buttons["HowToPay"].tap()
        app.tables.switches["Credit Card"].tap()
        app.buttons["ConfirmOrder"].tap()
        
        // Verify
        let confirmationAlert = app.alerts["Order confirmed"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: config.defaultTimeout),
                      "Multi-item order should complete")
    }
    
    // MARK: - Session Persistence (P1 - High)
    
    /// Verifies basket contents survive app termination and relaunch.
    func test_E2E_BasketPersistsAfterAppRelaunch() throws {
        // Given - Add item to basket
        _ = given_UserIsLoggedIn()
        let homeScreen = HomeScreen(app: app)
        let detailScreen = homeScreen.selectDrink(at: 1)
        _ = detailScreen.addToBasketAndConfirm()
        
        // Verify item in basket
        var basketScreen = homeScreen.tapBasket()
        let initialCount = app.tables.cells.count - 1
        XCTAssertGreaterThan(initialCount, 0, "Precondition: Basket should have items")
        _ = basketScreen.navigateBack()
        
        // When - Terminate and relaunch
        app.terminate()
        app.launch()
        
        // Then - Basket should still have items
        let relaunchedHome = HomeScreen(app: app)
        basketScreen = relaunchedHome.tapBasket()
        let finalCount = app.tables.cells.count - 1
        XCTAssertEqual(finalCount, initialCount,
                       "Basket items should persist after app relaunch")
    }
    
    // MARK: - Error Recovery (P1 - High)
    
    /// Verifies user can recover from cancelled checkout.
    func test_E2E_CancelCheckoutAndContinue() throws {
        // Given - On checkout screen
        let checkoutScreen = given_UserIsOnCheckoutScreen()
        
        // When - Cancel (navigate back)
        let basketScreen = checkoutScreen.navigateBack()
        
        // Then - Should be back on basket with items intact
        XCTAssertGreaterThan(app.tables.cells.count, 1,
                             "Basket should still have items after cancelling checkout")
        
        // Can proceed to checkout again
        _ = basketScreen.tapPlaceOrder()
        XCTAssertTrue(app.tables.buttons["HowToPay"].waitForExistence(timeout: config.defaultTimeout),
                      "Should be able to return to checkout")
    }
}

// MARK: - Smoke Test Suite
/// Quick verification tests for deployment sanity checks.
/// Run these before every deployment to verify critical paths work.
final class SmokeTests: BaseTestCase {
    
    /// Smoke: App launches and shows catalog.
    func test_Smoke_AppLaunchesSuccessfully() throws {
        _ = launchApp()
        XCTAssertTrue(app.staticTexts["iCoffee"].waitForExistence(timeout: config.defaultTimeout),
                      "App should launch and display catalog")
    }
    
    /// Smoke: Can login with valid credentials.
    func test_Smoke_LoginWorks() throws {
        let homeScreen = launchApp()
        _ = homeScreen.tapBasket()
        
        let loginScreen = LoginScreen(app: app)
        _ = loginScreen.login(with: .validUser)
        
        // Verify login succeeded by checking for authenticated state
        let logoutButton = app.buttons["LogOut"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: config.defaultTimeout),
                      "Login should succeed - logout button should appear")
    }
    
    /// Smoke: Can add item to basket.
    func test_Smoke_AddToBasketWorks() throws {
        _ = launchApp()
        app.cells.element(boundBy: 1).tap()
        app.scrollViews.otherElements.buttons["AddToBasket"].tap()
        
        let alert = app.alerts["Added to  Basket!"]
        XCTAssertTrue(alert.waitForExistence(timeout: config.defaultTimeout),
                      "Should be able to add items to basket")
    }
    
    /// Smoke: Can complete an order.
    func test_Smoke_OrderCompletionWorks() throws {
        let checkoutScreen = given_UserIsOnCheckoutScreen()
        _ = checkoutScreen.completeCheckout(paymentMethod: .creditCard, tip: .ten)
        
        let confirmationAlert = app.alerts["Order confirmed"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: config.defaultTimeout),
                      "Should be able to complete orders")
    }
}
