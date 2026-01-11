//
//  CatalogTests.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Feature: Product Catalog
//  Tests for catalog display and product navigation
//

import XCTest

// MARK: - Catalog Tests
/// Core catalog functionality tests.
final class CatalogTests: BaseTestCase {
    
    // MARK: - Properties
    private var dataProvider: TestDataProvider {
        return TestDataProvider.shared
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        logger.resetStepCounter()
    }
    
    // MARK: - Catalog Display (P0 - Critical)
    
    /// Verifies catalog loads and displays products on app launch.
    func test_Catalog_OnAppLaunch_ShouldDisplayProducts() throws {
        // Given & When
        _ = launchApp()
        
        // Then - Verify products are displayed (cells exist)
        let catalogCells = app.cells
        XCTAssertTrue(catalogCells.firstMatch.waitForExistence(timeout: config.defaultTimeout),
                      "Catalog should display products on launch")
        XCTAssertGreaterThan(catalogCells.count, 0,
                             "Catalog should have at least one product")
    }
    
    /// Verifies app title is displayed correctly.
    func test_Catalog_ShouldDisplayAppTitle() throws {
        // Given & When
        _ = launchApp()
        
        // Then
        let title = app.staticTexts["iCoffee"]
        XCTAssertTrue(title.waitForExistence(timeout: config.defaultTimeout),
                      "App title 'iCoffee' should be visible")
    }
    
    // MARK: - Product Selection (P0 - Critical)
    
    /// Verifies tapping product opens detail view with Add to Basket button.
    func test_ProductSelection_ShouldOpenDetailWithAddButton() throws {
        // Given - Use TestDataProvider to get default product
        let product = dataProvider.defaultProduct
        logger.testData("Testing with product: \(product.name)")
        
        // When - Select product using BDD step
        let detailScreen = given_ProductIsSelected(product)
        
        // Then - Add to Basket button should be visible
        let addToBasketButton = app.scrollViews.otherElements.buttons["AddToBasket"]
        XCTAssertTrue(addToBasketButton.waitForExistence(timeout: config.defaultTimeout),
                      "Add to Basket button should be visible on product detail")
    }
    
    /// Verifies navigating back from detail returns to catalog.
    func test_ProductDetail_NavigateBack_ShouldReturnToCatalog() throws {
        // Given - On product detail using step definition
        let detailScreen = given_UserIsOnDrinkDetail(productIndex: 1)
        
        // When - Navigate back
        _ = detailScreen.navigateBack()
        
        // Then - Should see catalog
        let title = app.staticTexts["iCoffee"]
        XCTAssertTrue(title.waitForExistence(timeout: config.defaultTimeout),
                      "Should return to catalog after navigating back")
    }
    
    // MARK: - Navigation Elements (P1 - High)
    
    /// Verifies basket button is accessible from catalog.
    func test_Catalog_ShouldHaveBasketButton() throws {
        // Given & When
        _ = launchApp()
        
        // Then
        let basketButton = app.buttons["Basket"]
        XCTAssertTrue(basketButton.exists, "Basket button should be visible on catalog screen")
        XCTAssertTrue(basketButton.isHittable, "Basket button should be tappable")
    }
    
    /// Verifies multiple products can be browsed using random product selection.
    func test_BrowseMultipleProducts_ShouldNavigateCorrectly() throws {
        // Given - Get random products from data provider
        let productsToTest = dataProvider.randomProducts(count: 3)
        _ = launchApp()
        
        // When & Then - Browse products
        for (index, product) in productsToTest.enumerated() {
            logger.testData("Browsing product \(index + 1): \(product.name)")
            
            // Select product by index (since we can't search by name in current UI)
            let cell = app.cells.element(boundBy: index + 1)
            guard cell.waitForExistence(timeout: config.shortTimeout) else {
                continue
            }
            cell.tap()
            
            // Verify detail screen
            let addButton = app.scrollViews.otherElements.buttons["AddToBasket"]
            XCTAssertTrue(addButton.waitForExistence(timeout: config.defaultTimeout),
                          "Product \(index + 1) should show detail screen")
            
            // Go back
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        
        // Final verification - back on catalog
        XCTAssertTrue(app.staticTexts["iCoffee"].exists,
                      "Should be back on catalog after browsing")
    }
}

// MARK: - GivenBuilder Demo Tests
/// Demonstrates usage of GivenBuilder for complex precondition setup.
final class CatalogBuilderTests: BaseTestCase {
    
    /// Verifies catalog browsing with pre-configured user state using GivenBuilder.
    func test_Catalog_WithLoggedInUserAndBasketItems_ShouldShowLogout() throws {
        // Given - Use fluent GivenBuilder for complex setup
        _ = given
            .userLoggedIn(as: .validUser)
            .withItemsInBasket(count: 1)
            .setup()
        
        // Then - Logout button should be visible
        let logoutButton = app.buttons["LogOut"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: config.defaultTimeout),
                      "Logout button should be visible for logged in user")
    }
}
