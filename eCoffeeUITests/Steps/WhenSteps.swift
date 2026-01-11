//
//  WhenSteps.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  BDD Steps - When (Actions)
//

import XCTest

// MARK: - When Steps
/// BDD-style step definitions for actions (When).
/// All actions return screen objects for fluent chaining.
extension BaseTestCase {
    
    // MARK: - Navigation Actions
    
    /// When: User taps the basket button
    /// - Parameter from: HomeScreen instance
    /// - Returns: BasketScreen instance
    @discardableResult
    func when_UserTapsBasket(from screen: HomeScreen) -> BasketScreen {
        return activity(named: "When: User taps Basket button") {
            logger.section("ACTION")
            return screen.tapBasket()
        }
    }
    
    /// When: User taps logout
    /// - Parameter from: HomeScreen instance
    /// - Returns: HomeScreen instance
    @discardableResult
    func when_UserTapsLogout(from screen: HomeScreen) -> HomeScreen {
        return activity(named: "When: User taps Logout button") {
            return screen.tapLogOut()
        }
    }
    
    /// When: User navigates back
    @discardableResult
    func when_UserNavigatesBack<T: ScreenProtocol>(from screen: T) -> HomeScreen {
        return activity(named: "When: User navigates back") {
            app.navigationBars.buttons.element(boundBy: 0).tap()
            return HomeScreen(app: app)
        }
    }
    
    // MARK: - Authentication Actions
    
    /// When: User enters login credentials
    /// - Parameters:
    ///   - screen: LoginScreen instance
    ///   - user: TestUser with credentials
    /// - Returns: LoginScreen instance
    @discardableResult
    func when_UserEntersCredentials(on screen: LoginScreen, user: TestUser) -> LoginScreen {
        return activity(named: "When: User enters credentials for \(user.email)") {
            logger.testData("Email: \(user.email)")
            return screen.enterEmail(user.email)
                .enterPassword(user.password)
        }
    }
    
    /// When: User taps sign in
    /// - Parameter screen: LoginScreen instance
    /// - Returns: BasketScreen on success
    @discardableResult
    func when_UserTapsSignIn(on screen: LoginScreen) -> BasketScreen {
        return activity(named: "When: User taps Sign In button") {
            return screen.tapSignIn()
        }
    }
    
    /// When: User performs complete login
    /// - Parameters:
    ///   - screen: LoginScreen instance
    ///   - user: TestUser with credentials
    /// - Returns: BasketScreen on success
    @discardableResult
    func when_UserLogsIn(on screen: LoginScreen, with user: TestUser) -> BasketScreen {
        return activity(named: "When: User logs in as \(user.email)") {
            return screen.login(with: user)
        }
    }
    
    // MARK: - Catalog Actions
    
    /// When: User selects a drink by index
    /// - Parameters:
    ///   - screen: HomeScreen instance
    ///   - index: Drink index
    /// - Returns: DrinkDetailScreen instance
    @discardableResult
    func when_UserSelectsDrink(from screen: HomeScreen, at index: Int) -> DrinkDetailScreen {
        return activity(named: "When: User selects drink at index \(index)") {
            return screen.selectDrink(at: index)
        }
    }
    
    /// When: User selects a drink by name
    /// - Parameters:
    ///   - screen: HomeScreen instance
    ///   - name: Drink name
    /// - Returns: DrinkDetailScreen instance
    @discardableResult
    func when_UserSelectsDrink(from screen: HomeScreen, named name: String) -> DrinkDetailScreen {
        return activity(named: "When: User selects drink '\(name)'") {
            return screen.selectDrink(named: name)
        }
    }
    
    // MARK: - Basket Actions
    
    /// When: User adds item to basket
    /// - Parameter screen: DrinkDetailScreen instance
    /// - Returns: DrinkDetailScreen instance
    @discardableResult
    func when_UserAddsToBasket(from screen: DrinkDetailScreen) -> DrinkDetailScreen {
        return activity(named: "When: User adds item to basket") {
            return screen.tapAddToBasket()
        }
    }
    
    /// When: User adds item to basket and confirms
    /// - Parameter screen: DrinkDetailScreen instance
    /// - Returns: HomeScreen instance
    @discardableResult
    func when_UserAddsToBasketAndConfirms(from screen: DrinkDetailScreen) -> HomeScreen {
        return activity(named: "When: User adds item to basket and confirms") {
            return screen.addToBasketAndConfirm()
        }
    }
    
    /// When: User places order
    /// - Parameter screen: BasketScreen instance
    /// - Returns: CheckoutScreen instance
    @discardableResult
    func when_UserPlacesOrder(from screen: BasketScreen) -> CheckoutScreen {
        return activity(named: "When: User places order") {
            return screen.tapPlaceOrder()
        }
    }
    
    /// When: User clears basket
    /// - Parameter screen: BasketScreen instance
    /// - Returns: BasketScreen instance
    @discardableResult
    func when_UserClearsBasket(from screen: BasketScreen) -> BasketScreen {
        return activity(named: "When: User clears basket") {
            return screen.tapClearBasket()
        }
    }
    
    // MARK: - Checkout Actions
    
    /// When: User selects payment method
    /// - Parameters:
    ///   - screen: CheckoutScreen instance
    ///   - method: PaymentMethod to select
    /// - Returns: CheckoutScreen instance
    @discardableResult
    func when_UserSelectsPayment(on screen: CheckoutScreen, method: PaymentMethod) -> CheckoutScreen {
        return activity(named: "When: User selects \(method.rawValue) payment") {
            return screen.tapHowToPay()
                .selectPaymentMethod(method)
        }
    }
    
    /// When: User selects tip
    /// - Parameters:
    ///   - screen: CheckoutScreen instance
    ///   - tip: TipPercentage to select
    /// - Returns: CheckoutScreen instance
    @discardableResult
    func when_UserSelectsTip(on screen: CheckoutScreen, tip: TipPercentage) -> CheckoutScreen {
        return activity(named: "When: User selects \(tip.rawValue) tip") {
            return screen.selectTip(tip)
        }
    }
    
    /// When: User confirms order
    /// - Parameter screen: CheckoutScreen instance
    /// - Returns: CheckoutScreen instance
    @discardableResult
    func when_UserConfirmsOrder(on screen: CheckoutScreen) -> CheckoutScreen {
        return activity(named: "When: User confirms order") {
            return screen.tapConfirmOrder()
        }
    }
    
    /// When: User completes checkout
    /// - Parameters:
    ///   - screen: CheckoutScreen instance
    ///   - payment: PaymentMethod (default creditCard)
    ///   - tip: TipPercentage (default ten)
    /// - Returns: HomeScreen instance
    @discardableResult
    func when_UserCompletesCheckout(
        on screen: CheckoutScreen,
        payment: PaymentMethod = .creditCard,
        tip: TipPercentage = .ten
    ) -> HomeScreen {
        return activity(named: "When: User completes checkout") {
            return screen.completeCheckout(paymentMethod: payment, tip: tip)
        }
    }
    
    // MARK: - Quantity Actions
    
    /// When: User changes quantity
    /// - Parameters:
    ///   - screen: DrinkDetailScreen instance
    ///   - quantity: New quantity
    /// - Returns: DrinkDetailScreen instance
    @discardableResult
    func when_UserChangesQuantity(on screen: DrinkDetailScreen, to quantity: Int) -> DrinkDetailScreen {
        return activity(named: "When: User changes quantity to \(quantity)") {
            return screen.setQuantity(quantity)
        }
    }
}

// MARK: - When Fluent Actions
/// Fluent action chains for complex scenarios
extension BaseTestCase {
    
    /// Performs complete order flow
    /// - Parameters:
    ///   - drinkIndex: Index of drink to order
    ///   - quantity: Quantity to order
    ///   - payment: Payment method
    ///   - tip: Tip percentage
    /// - Returns: HomeScreen after order completion
    @discardableResult
    func when_UserPlacesCompleteOrder(
        drinkIndex: Int = 1,
        quantity: Int = 1,
        payment: PaymentMethod = .creditCard,
        tip: TipPercentage = .ten
    ) -> HomeScreen {
        return activity(named: "When: User places complete order") {
            let homeScreen = given_UserIsLoggedIn()
            
            // Select drink and add to basket
            let detailScreen = homeScreen.selectDrink(at: drinkIndex)
            if quantity > 1 {
                _ = detailScreen.increaseQuantity(times: quantity - 1)
            }
            let homeAfterAdd = detailScreen.addToBasketAndConfirm()
            
            // Proceed to checkout
            let basketScreen = homeAfterAdd.tapBasket()
            let checkoutScreen = basketScreen.tapPlaceOrder()
            
            // Complete checkout
            return checkoutScreen.completeCheckout(paymentMethod: payment, tip: tip)
        }
    }
}
