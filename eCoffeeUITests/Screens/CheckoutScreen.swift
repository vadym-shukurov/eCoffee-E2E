//
//  CheckoutScreen.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Page Object Model - Checkout/Payment Screen
//

import XCTest

// MARK: - Payment Method
/// Available payment methods
enum PaymentMethod: String {
    case creditCard = "Credit Card"
    case cash = "Cash"
    case applePay = "Apple Pay"
}

// MARK: - Tip Percentage
/// Available tip percentages
enum TipPercentage: String {
    case zero = "0 %"
    case ten = "10 %"
    case fifteen = "15 %"
    case twenty = "20 %"
}

// MARK: - Checkout Screen
/// Page Object for the Checkout/Payment screen
final class CheckoutScreen: ScreenProtocol, Alertable {
    
    // MARK: - Properties
    let app: XCUIApplication
    
    // MARK: - Screen Identifier
    var screenIdentifier: XCUIElement {
        return Elements.confirmOrderButton
    }
    
    // MARK: - Initializer
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Elements
    private enum Elements {
        static var app: XCUIApplication { XCUIApplication() }
        
        // Payment Section
        static var howToPayButton: XCUIElement { app.tables.buttons["HowToPay"] }
        static func paymentSwitch(_ method: PaymentMethod) -> XCUIElement {
            app.tables.switches[method.rawValue]
        }
        
        // Tip Section
        static var tipSegmentedControl: XCUIElement { app.tables.segmentedControls.firstMatch }
        static func tipButton(_ tip: TipPercentage) -> XCUIElement {
            app.tables.buttons[tip.rawValue]
        }
        
        // Order Summary
        static var subtotalLabel: XCUIElement { app.staticTexts.matching(identifier: "subtotal").firstMatch }
        static var tipLabel: XCUIElement { app.staticTexts.matching(identifier: "tipAmount").firstMatch }
        static var totalLabel: XCUIElement { app.staticTexts.matching(identifier: "total").firstMatch }
        
        // Actions
        static var confirmOrderButton: XCUIElement { app.buttons["ConfirmOrder"] }
        static var cancelButton: XCUIElement { app.buttons["Cancel"] }
        static var backButton: XCUIElement { app.navigationBars.buttons.element(boundBy: 0) }
        
        // Confirmation Alert
        static var orderConfirmedAlert: XCUIElement { app.alerts["Order confirmed"] }
        static var alertOKButton: XCUIElement { app.alerts.buttons["OK"] }
    }
    
    // MARK: - Payment Actions
    
    /// Opens payment method selection
    /// - Returns: Self for chaining
    @discardableResult
    func tapHowToPay() -> CheckoutScreen {
        TestLogger.shared.action("Opening payment method selection")
        ElementAssert.exists(Elements.howToPayButton)
        Elements.howToPayButton.tap()
        return self
    }
    
    /// Selects a payment method
    /// - Parameter method: Payment method to select
    /// - Returns: Self for chaining
    @discardableResult
    func selectPaymentMethod(_ method: PaymentMethod) -> CheckoutScreen {
        TestLogger.shared.action("Selecting payment method: \(method.rawValue)")
        let paymentSwitch = Elements.paymentSwitch(method)
        _ = Waiter.waitForElement(paymentSwitch)
        paymentSwitch.tap()
        return self
    }
    
    // MARK: - Tip Actions
    
    /// Selects tip percentage
    /// - Parameter tip: Tip percentage to select
    /// - Returns: Self for chaining
    @discardableResult
    func selectTip(_ tip: TipPercentage) -> CheckoutScreen {
        TestLogger.shared.action("Selecting tip: \(tip.rawValue)")
        let tipButton = Elements.tipButton(tip)
        
        // May need to scroll/swipe to find the tip option
        if !tipButton.isHittable {
            Elements.tipSegmentedControl.swipeRight()
        }
        
        _ = Waiter.waitForElementToBeHittable(tipButton)
        tipButton.tap()
        return self
    }
    
    // MARK: - Order Actions
    
    /// Confirms the order
    /// - Returns: Self for chaining
    @discardableResult
    func tapConfirmOrder() -> CheckoutScreen {
        TestLogger.shared.action("Confirming order")
        ElementAssert.exists(Elements.confirmOrderButton)
        Elements.confirmOrderButton.tap()
        return self
    }
    
    /// Dismisses the order confirmation alert
    /// - Returns: HomeScreen instance
    @discardableResult
    func dismissOrderConfirmation() -> HomeScreen {
        TestLogger.shared.action("Dismissing order confirmation")
        _ = Waiter.waitForAlert(in: app, withTitle: "Order confirmed")
        Elements.alertOKButton.tap()
        return HomeScreen(app: app)
    }
    
    /// Cancels checkout and returns to basket
    /// - Returns: BasketScreen instance
    @discardableResult
    func cancelCheckout() -> BasketScreen {
        TestLogger.shared.action("Cancelling checkout")
        Elements.cancelButton.tap()
        return BasketScreen(app: app)
    }
    
    /// Navigates back to basket
    /// - Returns: BasketScreen instance
    @discardableResult
    func navigateBack() -> BasketScreen {
        TestLogger.shared.action("Navigating back from Checkout")
        Elements.backButton.tap()
        return BasketScreen(app: app)
    }
    
    // MARK: - Complete Checkout Flow
    
    /// Completes checkout with specified payment and tip
    /// - Parameters:
    ///   - paymentMethod: Payment method to use
    ///   - tip: Tip percentage
    /// - Returns: HomeScreen after successful order
    @discardableResult
    func completeCheckout(
        paymentMethod: PaymentMethod = .creditCard,
        tip: TipPercentage = .ten
    ) -> HomeScreen {
        TestLogger.shared.section("Complete Checkout Flow")
        return tapHowToPay()
            .selectPaymentMethod(paymentMethod)
            .selectTip(tip)
            .tapConfirmOrder()
            .dismissOrderConfirmation()
    }
    
    // MARK: - Validations
    
    /// Validates checkout screen is displayed
    @discardableResult
    func validateCheckoutScreen() -> CheckoutScreen {
        TestLogger.shared.validatingScreen("CheckoutScreen")
        ElementAssert.exists(Elements.confirmOrderButton, message: "Confirm Order button not visible")
        ElementAssert.exists(Elements.howToPayButton, message: "How to Pay button not visible")
        return self
    }
    
    /// Validates order confirmation alert is displayed
    @discardableResult
    func validateOrderConfirmed() -> CheckoutScreen {
        TestLogger.shared.verify("Order confirmation alert is displayed")
        AlertAssert.hasTitle("Order confirmed", in: app)
        return self
    }
    
    /// Validates payment method is selected
    /// - Parameter method: Expected selected payment method
    @discardableResult
    func validatePaymentMethodSelected(_ method: PaymentMethod) -> CheckoutScreen {
        TestLogger.shared.verify("Payment method \(method.rawValue) is selected")
        let paymentSwitch = Elements.paymentSwitch(method)
        // Check if switch value is "1" (selected)
        if let value = paymentSwitch.value as? String {
            XCTAssertEqual(value, "1", "Payment method \(method.rawValue) is not selected")
        }
        return self
    }
    
    /// Validates Confirm Order button is enabled
    @discardableResult
    func validateCanConfirmOrder() -> CheckoutScreen {
        ElementAssert.isEnabled(Elements.confirmOrderButton)
        return self
    }
    
    // MARK: - Queries
    
    /// Checks if order can be confirmed
    var canConfirmOrder: Bool {
        return Elements.confirmOrderButton.exists && Elements.confirmOrderButton.isEnabled
    }
}
