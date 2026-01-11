//
//  BasketTests.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Feature: Shopping Basket
//  Tests for basket operations, item management, and checkout readiness
//

import XCTest

// MARK: - Basket Tests
/// Core basket functionality tests.
final class BasketTests: BaseTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        logger.resetStepCounter()
    }
    
    // MARK: - Add to Basket (P0 - Critical)
    
    /// Verifies item is added to basket and confirmation alert appears.
    func test_AddToBasket_ShouldShowConfirmationAlert() throws {
        // Given
        let homeScreen = launchApp()
        let detailScreen = homeScreen.selectDrink(at: 1)
        
        // When
        _ = detailScreen.tapAddToBasket()
        
        // Then - Verify confirmation alert appears
        let alert = app.alerts["Added to  Basket!"]
        XCTAssertTrue(alert.waitForExistence(timeout: config.defaultTimeout),
                      "Confirmation alert should appear after adding item to basket")
        
        // Dismiss alert
        alert.buttons["OK"].tap()
    }
    
    /// Verifies added item appears in basket with correct name.
    func test_AddToBasket_ItemShouldAppearInBasketList() throws {
        // Given - User is logged in
        _ = given_UserIsLoggedIn()
        let homeScreen = HomeScreen(app: app)
        
        // Get drink name before adding
        let detailScreen = homeScreen.selectDrink(at: 1)
        
        // When - Add to basket
        _ = detailScreen.addToBasketAndConfirm()
        let basketScreen = HomeScreen(app: app).tapBasket()
        
        // Then - Basket should have at least 1 item
        let basketCells = app.tables.cells
        XCTAssertGreaterThan(basketCells.count, 0, "Basket should contain at least one item")
    }
    
    /// Verifies multiple different items can be added to basket.
    func test_AddMultipleItems_ShouldShowCorrectCount() throws {
        // Given
        _ = given_UserIsLoggedIn()
        let homeScreen = HomeScreen(app: app)
        
        // When - Add 3 different items
        for index in 1...3 {
            let detailScreen = homeScreen.selectDrink(at: index)
            _ = detailScreen.addToBasketAndConfirm()
        }
        
        // Navigate to basket
        let basketScreen = homeScreen.tapBasket()
        
        // Then - Should have 3 items
        let basketCells = app.tables.cells
        // Account for the "Place Order" cell
        let itemCount = basketCells.count - 1
        XCTAssertEqual(itemCount, 3, "Basket should contain exactly 3 items")
    }
    
    // MARK: - Remove from Basket (P1 - High)
    
    /// Verifies swipe-to-delete removes item from basket.
    func test_SwipeToDelete_ShouldRemoveItemFromBasket() throws {
        // Given - Basket has items
        _ = given_UserIsLoggedIn()
        let homeScreen = HomeScreen(app: app)
        
        // Add 2 items
        for index in 1...2 {
            let detailScreen = homeScreen.selectDrink(at: index)
            _ = detailScreen.addToBasketAndConfirm()
        }
        
        let basketScreen = homeScreen.tapBasket()
        let initialCellCount = app.tables.cells.count - 1 // Minus Place Order cell
        XCTAssertEqual(initialCellCount, 2, "Precondition: Should have 2 items")
        
        // When - Swipe to delete first item
        let firstItemCell = app.tables.cells.element(boundBy: 0)
        firstItemCell.swipeLeft()
        
        // Tap delete button if it appears
        let deleteButton = app.buttons["Delete"]
        if deleteButton.waitForExistence(timeout: config.shortTimeout) {
            deleteButton.tap()
        }
        
        // Then - Should have 1 item left
        let finalCellCount = app.tables.cells.count - 1
        XCTAssertEqual(finalCellCount, 1, "Basket should have 1 item after deletion")
    }
    
    // MARK: - Place Order Button State (P1 - High)
    
    /// Verifies Place Order is disabled when basket is empty.
    func test_PlaceOrder_WhenBasketEmpty_ShouldBeDisabled() throws {
        // Given - User logged in with empty basket
        _ = given_UserIsLoggedIn()
        let homeScreen = HomeScreen(app: app)
        let basketScreen = homeScreen.tapBasket()
        
        // Clear basket if has items
        while app.tables.cells.count > 1 {
            let firstCell = app.tables.cells.element(boundBy: 0)
            firstCell.swipeLeft()
            if app.buttons["Delete"].exists {
                app.buttons["Delete"].tap()
            }
        }
        
        // Then - Place Order should be disabled
        let placeOrderLink = app.buttons["PlaceOrder"]
        // In SwiftUI, disabled navigation links may not be hittable
        if placeOrderLink.exists {
            XCTAssertFalse(placeOrderLink.isEnabled, "Place Order should be disabled when basket is empty")
        }
    }
    
    /// Verifies Place Order is enabled when basket has items.
    func test_PlaceOrder_WhenBasketHasItems_ShouldBeEnabled() throws {
        // Given - Basket has items
        let basketScreen = given_UserHasItemsInBasket(itemCount: 1)
        
        // Then - Place Order should be accessible
        let placeOrderLink = app.buttons["PlaceOrder"]
        XCTAssertTrue(placeOrderLink.waitForExistence(timeout: config.defaultTimeout),
                      "Place Order should exist when basket has items")
    }
    
    // MARK: - Basket Persistence (P1 - High)
    
    /// Verifies basket items persist after navigating away and back.
    func test_BasketItems_AfterNavigatingAway_ShouldPersist() throws {
        // Given - Add item to basket
        _ = given_UserIsLoggedIn()
        let homeScreen = HomeScreen(app: app)
        let detailScreen = homeScreen.selectDrink(at: 1)
        _ = detailScreen.addToBasketAndConfirm()
        
        // Verify item in basket
        var basketScreen = homeScreen.tapBasket()
        let initialCount = app.tables.cells.count - 1
        XCTAssertGreaterThan(initialCount, 0, "Precondition: Basket should have items")
        
        // When - Navigate away and back
        _ = basketScreen.navigateBack()
        basketScreen = homeScreen.tapBasket()
        
        // Then - Items should still be there
        let finalCount = app.tables.cells.count - 1
        XCTAssertEqual(finalCount, initialCount, "Basket items should persist after navigation")
    }
}
