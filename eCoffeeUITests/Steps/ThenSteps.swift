//
//  ThenSteps.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  BDD Steps - Then (Assertions/Validations)
//

import XCTest

// MARK: - Then Steps
/// BDD-style step definitions for assertions (Then).
/// All validations include detailed logging and screenshots on failure.
extension BaseTestCase {
    
    // MARK: - Screen Validations
    
    /// Then: User should see the home screen
    /// - Parameter screen: HomeScreen instance
    @discardableResult
    func then_UserSeesHomeScreen(_ screen: HomeScreen) -> HomeScreen {
        return activity(named: "Then: User sees Home screen") {
            logger.section("VERIFICATION")
            return screen.validateHomeScreen()
                .validateCatalogDisplayed()
        }
    }
    
    /// Then: User should see the login screen
    /// - Parameter screen: LoginScreen instance
    @discardableResult
    func then_UserSeesLoginScreen(_ screen: LoginScreen) -> LoginScreen {
        return activity(named: "Then: User sees Login screen") {
            return screen.validateLoginScreen()
        }
    }
    
    /// Then: User should see the basket screen
    /// - Parameter screen: BasketScreen instance
    @discardableResult
    func then_UserSeesBasketScreen(_ screen: BasketScreen) -> BasketScreen {
        return activity(named: "Then: User sees Basket screen") {
            return screen.validateBasketScreen()
        }
    }
    
    /// Then: User should see the checkout screen
    /// - Parameter screen: CheckoutScreen instance
    @discardableResult
    func then_UserSeesCheckoutScreen(_ screen: CheckoutScreen) -> CheckoutScreen {
        return activity(named: "Then: User sees Checkout screen") {
            return screen.validateCheckoutScreen()
        }
    }
    
    /// Then: User should see the drink detail screen
    /// - Parameter screen: DrinkDetailScreen instance
    @discardableResult
    func then_UserSeesDrinkDetail(_ screen: DrinkDetailScreen) -> DrinkDetailScreen {
        return activity(named: "Then: User sees Drink Detail screen") {
            return screen.validateDrinkDetailScreen()
        }
    }
    
    // MARK: - Authentication Validations
    
    /// Then: User should be logged in
    /// - Parameter screen: HomeScreen instance
    func then_UserIsLoggedIn(_ screen: HomeScreen) {
        activity(named: "Then: User is logged in") {
            screen.validateUserLoggedIn()
            captureScreenshot(named: "UserLoggedIn")
        }
    }
    
    /// Then: User should be logged out
    /// - Parameter screen: HomeScreen instance
    func then_UserIsLoggedOut(_ screen: HomeScreen) {
        activity(named: "Then: User is logged out") {
            screen.validateUserLoggedOut()
            captureScreenshot(named: "UserLoggedOut")
        }
    }
    
    /// Then: Login should fail with error
    /// - Parameters:
    ///   - screen: LoginScreen instance
    ///   - expectedError: Expected error message (optional)
    func then_LoginFails(_ screen: LoginScreen, withError expectedError: String? = nil) {
        activity(named: "Then: Login fails") {
            screen.validateLoginScreen() // Still on login screen
            
            if let error = expectedError {
                screen.validateErrorMessage(error)
            }
            
            captureScreenshot(named: "LoginFailed")
        }
    }
    
    // MARK: - Basket Validations
    
    /// Then: Basket should contain items
    /// - Parameter screen: BasketScreen instance
    func then_BasketHasItems(_ screen: BasketScreen) {
        activity(named: "Then: Basket has items") {
            screen.validateBasketHasItems()
            captureScreenshot(named: "BasketWithItems")
        }
    }
    
    /// Then: Basket should be empty
    /// - Parameter screen: BasketScreen instance
    func then_BasketIsEmpty(_ screen: BasketScreen) {
        activity(named: "Then: Basket is empty") {
            screen.validateBasketIsEmpty()
            captureScreenshot(named: "EmptyBasket")
        }
    }
    
    /// Then: Basket should contain specific item
    /// - Parameters:
    ///   - screen: BasketScreen instance
    ///   - itemName: Expected item name
    func then_BasketContainsItem(_ screen: BasketScreen, named itemName: String) {
        activity(named: "Then: Basket contains '\(itemName)'") {
            screen.validateItemInBasket(itemName)
        }
    }
    
    /// Then: Basket should contain expected count of items
    /// - Parameters:
    ///   - screen: BasketScreen instance
    ///   - expectedCount: Expected item count
    func then_BasketHasItemCount(_ screen: BasketScreen, count expectedCount: Int) {
        activity(named: "Then: Basket has \(expectedCount) item(s)") {
            let actualCount = screen.itemCount
            assertThat(actualCount == expectedCount, "Expected \(expectedCount) items but found \(actualCount)")
        }
    }
    
    // MARK: - Alert Validations
    
    /// Then: "Added to Basket" alert should be displayed
    /// - Parameter screen: DrinkDetailScreen instance
    func then_AddedToBasketAlertDisplayed(_ screen: DrinkDetailScreen) {
        activity(named: "Then: 'Added to Basket' alert is displayed") {
            screen.validateAddedToBasketAlert()
            captureScreenshot(named: "AddedToBasketAlert")
        }
    }
    
    /// Then: Order confirmation alert should be displayed
    /// - Parameter screen: CheckoutScreen instance
    func then_OrderConfirmedAlertDisplayed(_ screen: CheckoutScreen) {
        activity(named: "Then: Order confirmed alert is displayed") {
            screen.validateOrderConfirmed()
            captureScreenshot(named: "OrderConfirmedAlert")
        }
    }
    
    /// Then: Alert with title should be displayed
    /// - Parameter title: Expected alert title
    func then_AlertDisplayed(withTitle title: String) {
        activity(named: "Then: Alert '\(title)' is displayed") {
            AlertAssert.hasTitle(title, in: app)
            captureScreenshot(named: "Alert_\(title)")
        }
    }
    
    // MARK: - Order Validations
    
    /// Then: User should be able to place order
    /// - Parameter screen: BasketScreen instance
    func then_UserCanPlaceOrder(_ screen: BasketScreen) {
        activity(named: "Then: User can place order") {
            assertThat(screen.canPlaceOrder, "Place Order button should be available")
        }
    }
    
    /// Then: User should be able to confirm order
    /// - Parameter screen: CheckoutScreen instance
    func then_UserCanConfirmOrder(_ screen: CheckoutScreen) {
        activity(named: "Then: User can confirm order") {
            assertThat(screen.canConfirmOrder, "Confirm Order button should be enabled")
        }
    }
    
    /// Then: Order should be completed successfully
    func then_OrderCompletedSuccessfully() {
        activity(named: "Then: Order completed successfully") {
            // Verify we're back on home screen after order
            let homeScreen = HomeScreen(app: app)
            homeScreen.validateHomeScreen()
            captureScreenshot(named: "OrderCompleted")
            logger.info("Order completed successfully")
        }
    }
    
    // MARK: - Product Validations
    
    /// Then: Product name should match expected
    /// - Parameters:
    ///   - screen: DrinkDetailScreen instance
    ///   - expectedName: Expected product name
    func then_ProductNameIs(_ screen: DrinkDetailScreen, expectedName: String) {
        activity(named: "Then: Product name is '\(expectedName)'") {
            screen.validateProductName(expectedName)
        }
    }
    
    /// Then: Catalog should display products
    /// - Parameters:
    ///   - screen: HomeScreen instance
    ///   - minimumCount: Minimum expected products
    func then_CatalogDisplaysProducts(_ screen: HomeScreen, minimumCount: Int = 1) {
        activity(named: "Then: Catalog displays at least \(minimumCount) product(s)") {
            assertThat(screen.drinkCount >= minimumCount, "Expected at least \(minimumCount) products in catalog")
        }
    }
    
    // MARK: - Generic Element Validations
    
    /// Then: Element should exist
    /// - Parameter element: XCUIElement to check
    func then_ElementExists(_ element: XCUIElement) {
        activity(named: "Then: Element exists") {
            ElementAssert.exists(element)
        }
    }
    
    /// Then: Element should not exist
    /// - Parameter element: XCUIElement to check
    func then_ElementNotExists(_ element: XCUIElement) {
        activity(named: "Then: Element does not exist") {
            ElementAssert.notExists(element)
        }
    }
    
    /// Then: Element should be enabled
    /// - Parameter element: XCUIElement to check
    func then_ElementIsEnabled(_ element: XCUIElement) {
        activity(named: "Then: Element is enabled") {
            ElementAssert.isEnabled(element)
        }
    }
    
    /// Then: Element should have label
    /// - Parameters:
    ///   - element: XCUIElement to check
    ///   - expectedLabel: Expected label text
    func then_ElementHasLabel(_ element: XCUIElement, _ expectedLabel: String) {
        activity(named: "Then: Element has label '\(expectedLabel)'") {
            ElementAssert.hasLabel(element, expected: expectedLabel)
        }
    }
}

