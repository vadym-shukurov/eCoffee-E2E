//
//  BasketScreen.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Page Object Model - Basket/Cart Screen
//

import XCTest

// MARK: - Basket Screen
/// Page Object for the Basket/Cart screen
final class BasketScreen: ScreenProtocol, Alertable {
    
    // MARK: - Properties
    let app: XCUIApplication
    
    // MARK: - Screen Identifier
    var screenIdentifier: XCUIElement {
        return Elements.placeOrderButton
    }
    
    // MARK: - Initializer
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Elements
    private enum Elements {
        static var app: XCUIApplication { XCUIApplication() }
        
        // Screen Elements
        static var basketTitle: XCUIElement { app.staticTexts["Basket"] }
        static var emptyBasketLabel: XCUIElement { app.staticTexts["Your basket is empty"] }
        
        // Items
        static var basketItems: XCUIElementQuery { app.tables.cells }
        static func basketItem(named name: String) -> XCUIElement { app.cells.staticTexts[name].firstMatch }
        
        // Actions
        static var placeOrderButton: XCUIElement { app.buttons["PlaceOrder"] }
        static var clearBasketButton: XCUIElement { app.buttons["Clear Basket"] }
        
        // Navigation
        static var backButton: XCUIElement { app.navigationBars.buttons.element(boundBy: 0) }
    }
    
    // MARK: - Actions
    
    /// Taps Place Order button to proceed to checkout
    /// - Returns: CheckoutScreen instance
    @discardableResult
    func tapPlaceOrder() -> CheckoutScreen {
        TestLogger.shared.action("Tapping Place Order")
        ElementAssert.exists(Elements.placeOrderButton)
        Elements.placeOrderButton.tap()
        return CheckoutScreen(app: app)
    }
    
    /// Clears all items from basket
    /// - Returns: Self for chaining
    @discardableResult
    func tapClearBasket() -> BasketScreen {
        TestLogger.shared.action("Clearing basket")
        if Elements.clearBasketButton.exists {
            Elements.clearBasketButton.tap()
        }
        return self
    }
    
    /// Navigates back to home screen
    /// - Returns: HomeScreen instance
    @discardableResult
    func navigateBack() -> HomeScreen {
        TestLogger.shared.action("Navigating back from Basket")
        Elements.backButton.tap()
        return HomeScreen(app: app)
    }
    
    /// Removes a specific item from basket
    /// - Parameter name: Name of item to remove
    /// - Returns: Self for chaining
    @discardableResult
    func removeItem(named name: String) -> BasketScreen {
        TestLogger.shared.action("Removing item: \(name)")
        let item = Elements.basketItem(named: name)
        if item.exists {
            item.swipeLeft()
            app.buttons["Delete"].tap()
        }
        return self
    }
    
    // MARK: - Validations
    
    /// Validates basket screen is displayed
    @discardableResult
    func validateBasketScreen() -> BasketScreen {
        TestLogger.shared.validatingScreen("BasketScreen")
        // Either Place Order button exists (has items) or empty basket label
        let hasItems = Elements.placeOrderButton.waitForExistence(timeout: TestConfiguration.shared.shortTimeout)
        let isEmpty = Elements.emptyBasketLabel.exists
        
        XCTAssertTrue(hasItems || isEmpty, "Basket screen not properly displayed")
        return self
    }
    
    /// Validates basket contains items
    @discardableResult
    func validateBasketHasItems() -> BasketScreen {
        TestLogger.shared.verify("Basket contains items")
        ElementAssert.exists(Elements.placeOrderButton, message: "Place Order button not visible - basket may be empty")
        ElementAssert.countAtLeast(Elements.basketItems, minimum: 1, message: "No items in basket")
        return self
    }
    
    /// Validates basket is empty
    @discardableResult
    func validateBasketIsEmpty() -> BasketScreen {
        TestLogger.shared.verify("Basket is empty")
        ElementAssert.exists(Elements.emptyBasketLabel, message: "Empty basket message not displayed")
        return self
    }
    
    /// Validates specific item is in basket
    /// - Parameter name: Name of expected item
    @discardableResult
    func validateItemInBasket(_ name: String) -> BasketScreen {
        TestLogger.shared.verify("Item '\(name)' is in basket")
        let item = Elements.basketItem(named: name)
        ElementAssert.exists(item, message: "Item '\(name)' not found in basket")
        return self
    }
    
    // MARK: - Queries
    
    /// Returns count of items in basket
    var itemCount: Int {
        return Elements.basketItems.count
    }
    
    /// Checks if basket is empty
    var isEmpty: Bool {
        return Elements.emptyBasketLabel.exists || Elements.basketItems.count == 0
    }
    
    /// Checks if Place Order is available
    var canPlaceOrder: Bool {
        return Elements.placeOrderButton.exists && Elements.placeOrderButton.isEnabled
    }
}

// MARK: - Basket Flow Helper
extension BasketScreen {
    
    /// Complete flow: Place order and proceed to checkout
    /// - Returns: CheckoutScreen instance
    @discardableResult
    func proceedToCheckout() -> CheckoutScreen {
        TestLogger.shared.section("Proceed to Checkout")
        validateBasketHasItems()
        return tapPlaceOrder()
    }
}
