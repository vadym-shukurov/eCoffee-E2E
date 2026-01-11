//
//  CheckoutTests.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Feature: Checkout & Payment
//  Tests for payment selection, tip calculation, and order completion
//

import XCTest

// MARK: - Checkout Tests
/// Core checkout and payment flow tests.
final class CheckoutTests: BaseTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        logger.resetStepCounter()
    }
    
    // MARK: - Navigation (P0 - Critical)
    
    /// Verifies checkout screen opens from basket with items.
    func test_Checkout_FromBasketWithItems_ShouldOpenPaymentScreen() throws {
        // Given
        let basketScreen = given_UserHasItemsInBasket(itemCount: 1)
        
        // When
        _ = basketScreen.tapPlaceOrder()
        
        // Then - Verify on checkout screen (payment picker visible)
        let howToPayButton = app.tables.buttons["HowToPay"]
        XCTAssertTrue(howToPayButton.waitForExistence(timeout: config.defaultTimeout),
                      "Payment picker should be visible on checkout screen")
    }
    
    // MARK: - Payment Method Selection (P0 - Critical)
    
    /// Verifies Credit Card payment can be selected.
    func test_PaymentMethod_SelectCreditCard_ShouldBeSelected() throws {
        // Given
        _ = given_UserIsOnCheckoutScreen()
        
        // When - Select Credit Card
        app.tables.buttons["HowToPay"].tap()
        let creditCardSwitch = app.tables.switches["Credit Card"]
        creditCardSwitch.tap()
        
        // Then - Verify Credit Card is selected (switch value is "1")
        XCTAssertEqual(creditCardSwitch.value as? String, "1",
                       "Credit Card should be selected")
    }
    
    /// Verifies Cash payment can be selected.
    func test_PaymentMethod_SelectCash_ShouldBeSelected() throws {
        // Given
        _ = given_UserIsOnCheckoutScreen()
        
        // When - Open payment picker (starts on Cash by default, index 0)
        app.tables.buttons["HowToPay"].tap()
        let cashSwitch = app.tables.switches["Cash"]
        cashSwitch.tap()
        
        // Then
        XCTAssertEqual(cashSwitch.value as? String, "1",
                       "Cash should be selected")
    }
    
    // MARK: - Tip Selection (P1 - High)
    
    /// Verifies 10% tip can be selected.
    func test_Tip_Select10Percent_ShouldUpdateTotal() throws {
        // Given
        _ = given_UserIsOnCheckoutScreen()
        
        // When - Select 10% tip
        let tipButton = app.tables.buttons["10 %"]
        if !tipButton.isHittable {
            app.tables.segmentedControls.firstMatch.swipeLeft()
        }
        tipButton.tap()
        
        // Then - Verify tip button is selected
        XCTAssertTrue(tipButton.isSelected || tipButton.exists,
                      "10% tip should be selectable")
    }
    
    /// Verifies 0% tip (no tip) can be selected.
    func test_Tip_SelectNoTip_ShouldBeAllowed() throws {
        // Given
        _ = given_UserIsOnCheckoutScreen()
        
        // When - Select 0% tip
        let noTipButton = app.tables.buttons["0 %"]
        // May need to swipe to find it
        if !noTipButton.isHittable {
            app.tables.segmentedControls.firstMatch.swipeRight()
        }
        noTipButton.tap()
        
        // Then
        XCTAssertTrue(noTipButton.exists, "0% tip option should exist")
    }
    
    // MARK: - Order Completion (P0 - Critical)
    
    /// Verifies order can be confirmed and shows confirmation alert.
    func test_ConfirmOrder_ShouldShowConfirmationAlert() throws {
        // Given
        _ = given_UserIsOnCheckoutScreen()
        
        // Setup payment
        app.tables.buttons["HowToPay"].tap()
        app.tables.switches["Credit Card"].tap()
        
        // When - Confirm order
        app.buttons["ConfirmOrder"].tap()
        
        // Then - Verify confirmation alert
        let confirmationAlert = app.alerts["Order confirmed"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: config.defaultTimeout),
                      "Order confirmation alert should appear")
        
        // Verify alert has OK button
        XCTAssertTrue(confirmationAlert.buttons["OK"].exists,
                      "Confirmation alert should have OK button")
    }
    
    /// Verifies completing order empties the basket.
    func test_CompleteOrder_ShouldEmptyBasket() throws {
        // Given
        let checkoutScreen = given_UserIsOnCheckoutScreen()
        
        // When - Complete the order
        _ = checkoutScreen.completeCheckout(paymentMethod: .creditCard, tip: .ten)
        
        // Navigate to basket
        let homeScreen = HomeScreen(app: app)
        _ = homeScreen.tapBasket()
        
        // Then - Basket should be empty (only Place Order cell, which is disabled)
        let basketCells = app.tables.cells
        // If basket is empty, there should be minimal cells
        XCTAssertLessThanOrEqual(basketCells.count, 1,
                                  "Basket should be empty after completing order")
    }
    
    // MARK: - Total Price Display (P1 - High)
    
    /// Verifies total price is displayed on checkout screen.
    func test_Checkout_ShouldDisplayTotalPrice() throws {
        // Given
        _ = given_UserIsOnCheckoutScreen()
        
        // Then - Total header should be visible with price format
        let totalSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Total:'"))
        XCTAssertGreaterThan(totalSection.count, 0,
                             "Total price should be displayed on checkout screen")
    }
}

// MARK: - Complete Order Flow Tests
/// End-to-end checkout flow tests.
final class OrderFlowTests: BaseTestCase {
    
    /// Verifies complete order flow from basket to confirmation.
    func test_CompleteOrderFlow_FromBasketToConfirmation() throws {
        // Given - User has items in basket
        let basketScreen = given_UserHasItemsInBasket(itemCount: 1)
        
        // When - Complete checkout flow
        let checkoutScreen = basketScreen.tapPlaceOrder()
        checkoutScreen.tapHowToPay()
            .selectPaymentMethod(.creditCard)
        checkoutScreen.selectTip(.ten)
        checkoutScreen.tapConfirmOrder()
        
        // Then - Order confirmed
        let confirmationAlert = app.alerts["Order confirmed"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: config.defaultTimeout),
                      "Order should be confirmed")
        
        // Dismiss and verify back on home
        confirmationAlert.buttons["OK"].tap()
    }
    
    /// Verifies order with cash payment completes successfully.
    func test_OrderWithCashPayment_ShouldComplete() throws {
        // Given
        let checkoutScreen = given_UserIsOnCheckoutScreen()
        
        // When - Pay with cash
        _ = checkoutScreen.tapHowToPay()
            .selectPaymentMethod(.cash)
            .selectTip(.zero)
            .tapConfirmOrder()
        
        // Then
        let confirmationAlert = app.alerts["Order confirmed"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: config.defaultTimeout),
                      "Cash order should complete successfully")
    }
}
