//
//  HomeScreen.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Page Object Model - Home Screen
//

import XCTest

// MARK: - Home Screen
/// Page Object for the main Home/Catalog screen
final class HomeScreen: ScreenProtocol, Alertable {
    
    // MARK: - Properties
    let app: XCUIApplication
    
    // MARK: - Screen Identifier
    var screenIdentifier: XCUIElement {
        return Elements.screenTitle
    }
    
    // MARK: - Initializer
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Elements
    private enum Elements {
        static var app: XCUIApplication { XCUIApplication() }
        
        // Navigation
        static var screenTitle: XCUIElement { app.staticTexts["iCoffee"] }
        static var basketButton: XCUIElement { app.buttons["Basket"] }
        static var logOutButton: XCUIElement { app.buttons["LogOut"] }
        
        // Catalog
        static var drinksList: XCUIElementQuery { app.cells }
        static func drinkCell(at index: Int) -> XCUIElement { app.cells.element(boundBy: index) }
        static func drinkCell(named name: String) -> XCUIElement { app.cells.staticTexts[name].firstMatch }
    }
    
    // MARK: - Navigation Actions
    
    /// Navigates to the basket/login screen
    /// - Returns: BasketScreen instance
    @discardableResult
    func tapBasket() -> BasketScreen {
        TestLogger.shared.action("Tapping Basket button")
        ElementAssert.exists(Elements.basketButton)
        Elements.basketButton.tap()
        return BasketScreen(app: app)
    }
    
    /// Logs out the current user
    /// - Returns: HomeScreen instance (logged out state)
    @discardableResult
    func tapLogOut() -> HomeScreen {
        TestLogger.shared.action("Tapping LogOut button")
        ElementAssert.exists(Elements.logOutButton)
        Elements.logOutButton.tap()
        return self
    }
    
    // MARK: - Catalog Actions
    
    /// Selects a drink by index
    /// - Parameter index: Index of the drink in the list
    /// - Returns: DrinkDetailScreen instance
    @discardableResult
    func selectDrink(at index: Int) -> DrinkDetailScreen {
        TestLogger.shared.action("Selecting drink at index \(index)")
        let cell = Elements.drinkCell(at: index)
        _ = Waiter.waitForElement(cell)
        cell.tap()
        return DrinkDetailScreen(app: app)
    }
    
    /// Selects a drink by name
    /// - Parameter name: Name of the drink
    /// - Returns: DrinkDetailScreen instance
    @discardableResult
    func selectDrink(named name: String) -> DrinkDetailScreen {
        TestLogger.shared.action("Selecting drink: \(name)")
        let cell = Elements.drinkCell(named: name)
        _ = Waiter.waitForElement(cell)
        cell.tap()
        return DrinkDetailScreen(app: app)
    }
    
    /// Scrolls to find a drink by name
    /// - Parameter name: Name of the drink to find
    /// - Returns: Self for chaining
    @discardableResult
    func scrollToDrink(named name: String) -> HomeScreen {
        TestLogger.shared.action("Scrolling to drink: \(name)")
        let cell = Elements.drinkCell(named: name)
        
        var attempts = 0
        while !cell.exists && attempts < 10 {
            app.swipeUp()
            attempts += 1
        }
        
        return self
    }
    
    // MARK: - Validations
    
    /// Validates the home screen is properly displayed
    @discardableResult
    func validateHomeScreen() -> HomeScreen {
        TestLogger.shared.validatingScreen("HomeScreen")
        ElementAssert.exists(Elements.screenTitle, message: "Home screen title not visible")
        ElementAssert.exists(Elements.basketButton, message: "Basket button not visible")
        return self
    }
    
    /// Validates drink catalog is displayed
    @discardableResult
    func validateCatalogDisplayed() -> HomeScreen {
        TestLogger.shared.verify("Drink catalog is displayed")
        ElementAssert.countAtLeast(Elements.drinksList, minimum: 1, message: "No drinks displayed in catalog")
        return self
    }
    
    /// Validates logout button is visible (user is logged in)
    @discardableResult
    func validateUserLoggedIn() -> HomeScreen {
        TestLogger.shared.verify("User is logged in")
        ElementAssert.exists(Elements.logOutButton, message: "LogOut button not visible - user may not be logged in")
        return self
    }
    
    /// Validates logout button is not visible (user is logged out)
    @discardableResult
    func validateUserLoggedOut() -> HomeScreen {
        TestLogger.shared.verify("User is logged out")
        ElementAssert.notExists(Elements.logOutButton, message: "LogOut button still visible - user may still be logged in")
        return self
    }
    
    // MARK: - Queries
    
    /// Returns the count of drinks in the catalog
    var drinkCount: Int {
        return Elements.drinksList.count
    }
    
    /// Checks if logout button is displayed
    var isLogOutButtonDisplayed: Bool {
        return Elements.logOutButton.exists
    }
}
