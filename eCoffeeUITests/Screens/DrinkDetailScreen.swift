//
//  DrinkDetailScreen.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Page Object Model - Drink Detail Screen
//

import XCTest

// MARK: - Drink Detail Screen
/// Page Object for the Drink Detail/Product screen
final class DrinkDetailScreen: ScreenProtocol, Alertable {
    
    // MARK: - Properties
    let app: XCUIApplication
    
    // MARK: - Screen Identifier
    var screenIdentifier: XCUIElement {
        return Elements.addToBasketButton
    }
    
    // MARK: - Initializer
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Elements
    private enum Elements {
        static var app: XCUIApplication { XCUIApplication() }
        
        // Product Info
        static var productImage: XCUIElement { app.images.firstMatch }
        static var productName: XCUIElement { app.staticTexts.element(boundBy: 0) }
        static var productDescription: XCUIElement { app.staticTexts.element(boundBy: 1) }
        static var productPrice: XCUIElement { app.staticTexts.matching(identifier: "price").firstMatch }
        
        // Actions
        static var addToBasketButton: XCUIElement { app.scrollViews.otherElements.buttons["AddToBasket"] }
        static var backButton: XCUIElement { app.navigationBars.buttons.element(boundBy: 0) }
        
        // Quantity
        static var quantityStepper: XCUIElement { app.steppers.firstMatch }
        static var quantityIncrease: XCUIElement { app.steppers.buttons.element(boundBy: 1) }
        static var quantityDecrease: XCUIElement { app.steppers.buttons.element(boundBy: 0) }
        
        // Alerts
        static var addedToBasketAlert: XCUIElement { app.alerts["Added to  Basket!"] }
        static var alertOKButton: XCUIElement { app.alerts.buttons["OK"] }
    }
    
    // MARK: - Actions
    
    /// Adds current item to basket
    /// - Returns: Self for chaining
    @discardableResult
    func tapAddToBasket() -> DrinkDetailScreen {
        TestLogger.shared.action("Tapping Add to Basket")
        ElementAssert.exists(Elements.addToBasketButton)
        Elements.addToBasketButton.tap()
        return self
    }
    
    /// Handles the "Added to Basket" confirmation alert
    /// - Returns: HomeScreen after dismissing alert
    @discardableResult
    func confirmAddedToBasket() -> HomeScreen {
        TestLogger.shared.action("Confirming Added to Basket alert")
        _ = Waiter.waitForAlert(in: app, timeout: TestConfiguration.shared.shortTimeout)
        Elements.alertOKButton.tap()
        return HomeScreen(app: app)
    }
    
    /// Adds item to basket and confirms the alert
    /// - Returns: HomeScreen instance
    @discardableResult
    func addToBasketAndConfirm() -> HomeScreen {
        TestLogger.shared.section("Add to Basket Flow")
        return tapAddToBasket()
            .confirmAddedToBasket()
    }
    
    /// Navigates back to home screen
    /// - Returns: HomeScreen instance
    @discardableResult
    func navigateBack() -> HomeScreen {
        TestLogger.shared.action("Navigating back to Home")
        Elements.backButton.tap()
        return HomeScreen(app: app)
    }
    
    // MARK: - Quantity Actions
    
    /// Increases quantity by specified amount
    /// - Parameter times: Number of times to tap increase
    /// - Returns: Self for chaining
    @discardableResult
    func increaseQuantity(times: Int = 1) -> DrinkDetailScreen {
        TestLogger.shared.action("Increasing quantity by \(times)")
        for _ in 0..<times {
            Elements.quantityIncrease.tap()
        }
        return self
    }
    
    /// Decreases quantity by specified amount
    /// - Parameter times: Number of times to tap decrease
    /// - Returns: Self for chaining
    @discardableResult
    func decreaseQuantity(times: Int = 1) -> DrinkDetailScreen {
        TestLogger.shared.action("Decreasing quantity by \(times)")
        for _ in 0..<times {
            Elements.quantityDecrease.tap()
        }
        return self
    }
    
    /// Sets quantity to specific value
    /// - Parameter quantity: Desired quantity
    /// - Returns: Self for chaining
    @discardableResult
    func setQuantity(_ quantity: Int) -> DrinkDetailScreen {
        TestLogger.shared.action("Setting quantity to \(quantity)")
        // Reset to 1 first, then increase
        // Implementation depends on stepper behavior
        return increaseQuantity(times: quantity - 1)
    }
    
    // MARK: - Validations
    
    /// Validates drink detail screen is displayed
    @discardableResult
    func validateDrinkDetailScreen() -> DrinkDetailScreen {
        TestLogger.shared.validatingScreen("DrinkDetailScreen")
        ElementAssert.exists(Elements.addToBasketButton, message: "Add to Basket button not visible")
        return self
    }
    
    /// Validates the "Added to Basket" alert is displayed
    @discardableResult
    func validateAddedToBasketAlert() -> DrinkDetailScreen {
        TestLogger.shared.verify("Added to Basket alert is displayed")
        AlertAssert.hasTitle("Added to  Basket!", in: app)
        return self
    }
    
    /// Validates product name matches expected
    /// - Parameter expectedName: Expected product name
    @discardableResult
    func validateProductName(_ expectedName: String) -> DrinkDetailScreen {
        TestLogger.shared.verify("Product name is \(expectedName)")
        let productNameElement = app.staticTexts[expectedName]
        ElementAssert.exists(productNameElement)
        return self
    }
    
    // MARK: - Queries
    
    /// Gets the current product name
    var productName: String {
        return Elements.productName.label
    }
}

// MARK: - Drink Selection Helper
extension DrinkDetailScreen {
    
    /// Drink selection options
    enum DrinkType: String, CaseIterable {
        case americano = "Americano"
        case cappuccino = "Cappuccino"
        case latte = "Latte"
        case espresso = "Espresso"
        case coldBrew = "Cold Brew"
        case frappe = "Frappe"
        case freddoEspresso = "Freddo Espresso"
        case freddoCappuccino = "Freddo Cappuccino"
        case icedAmericano = "Ice Americano"
        case icedLatte = "Iced Latte"
        case filterCoffee = "Filter Coffee"
        case brewLatte = "Brew Latte"
        case decaf = "Decaf"
    }
}
