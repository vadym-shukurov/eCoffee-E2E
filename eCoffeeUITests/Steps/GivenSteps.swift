//
//  GivenSteps.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  BDD Steps - Given (Preconditions)
//

import XCTest

// MARK: - Given Steps
/// BDD-style step definitions for preconditions (Given).
/// Provides fluent interface for setting up test state.
extension BaseTestCase {
    
    // MARK: - Application State
    
    /// Given: The application is launched and ready
    /// - Returns: HomeScreen instance
    @discardableResult
    func given_AppIsLaunched() -> HomeScreen {
        return activity(named: "Given: App is launched and ready") {
            logger.section("PRECONDITION")
            let homeScreen = launchApp()
            homeScreen.validateHomeScreen()
            return homeScreen
        }
    }
    
    /// Given: The user is on the home screen
    /// - Returns: HomeScreen instance
    @discardableResult
    func given_UserIsOnHomeScreen() -> HomeScreen {
        return activity(named: "Given: User is on Home screen") {
            let homeScreen = launchApp()
            homeScreen.validateHomeScreen()
                .validateCatalogDisplayed()
            return homeScreen
        }
    }
    
    /// Given: The user is logged in
    /// - Parameter user: TestUser credentials (defaults to valid user)
    /// - Returns: HomeScreen instance
    @discardableResult
    func given_UserIsLoggedIn(as user: TestUser = .validUser) -> HomeScreen {
        return activity(named: "Given: User is logged in as \(user.email)") {
            logger.testData("Using credentials for: \(user.email)")
            
            let homeScreen = launchApp()
            let basketScreen = homeScreen.tapBasket()
            
            // Check if already logged in
            if homeScreen.isLogOutButtonDisplayed {
                logger.info("User already logged in")
                return homeScreen
            }
            
            // Perform login
            let loginScreen = LoginScreen(app: app)
            _ = loginScreen.login(with: user)
            
            return HomeScreen(app: app)
        }
    }
    
    /// Given: The user is logged out
    /// - Returns: HomeScreen instance
    @discardableResult
    func given_UserIsLoggedOut() -> HomeScreen {
        return activity(named: "Given: User is logged out") {
            let homeScreen = launchApp()
            
            // Log out if currently logged in
            if homeScreen.isLogOutButtonDisplayed {
                homeScreen.tapLogOut()
            }
            
            return homeScreen.validateUserLoggedOut()
        }
    }
    
    // MARK: - Screen Navigation Preconditions
    
    /// Given: The user is on the login screen
    /// - Returns: LoginScreen instance
    @discardableResult
    func given_UserIsOnLoginScreen() -> LoginScreen {
        return activity(named: "Given: User is on Login screen") {
            let homeScreen = launchApp()
            _ = homeScreen.tapBasket()
            let loginScreen = LoginScreen(app: app)
            loginScreen.validateLoginScreen()
            return loginScreen
        }
    }
    
    /// Given: The user is on the basket screen
    /// - Returns: BasketScreen instance
    @discardableResult
    func given_UserIsOnBasketScreen() -> BasketScreen {
        return activity(named: "Given: User is on Basket screen") {
            let homeScreen = given_UserIsLoggedIn()
            return homeScreen.tapBasket()
                .validateBasketScreen()
        }
    }
    
    /// Given: The user is on the drink detail screen
    /// - Parameter productIndex: Index of drink to select (default 1)
    /// - Returns: DrinkDetailScreen instance
    @discardableResult
    func given_UserIsOnDrinkDetail(productIndex: Int = 1) -> DrinkDetailScreen {
        return activity(named: "Given: User is on Drink Detail screen") {
            let homeScreen = launchApp()
            return homeScreen.selectDrink(at: productIndex)
                .validateDrinkDetailScreen()
        }
    }
    
    /// Given: The user is on the checkout screen
    /// - Returns: CheckoutScreen instance
    @discardableResult
    func given_UserIsOnCheckoutScreen() -> CheckoutScreen {
        return activity(named: "Given: User is on Checkout screen") {
            let basketScreen = given_UserHasItemsInBasket()
            return basketScreen.tapPlaceOrder()
                .validateCheckoutScreen()
        }
    }
    
    // MARK: - Basket State Preconditions
    
    /// Given: The user has items in basket
    /// - Parameter itemCount: Number of items to add (default 1)
    /// - Returns: BasketScreen instance
    @discardableResult
    func given_UserHasItemsInBasket(itemCount: Int = 1) -> BasketScreen {
        return activity(named: "Given: User has \(itemCount) item(s) in basket") {
            _ = given_UserIsLoggedIn()
            let homeScreen = HomeScreen(app: app)
            
            // Add items to basket
            for i in 0..<itemCount {
                let detailScreen = homeScreen.selectDrink(at: i + 1)
                _ = detailScreen.addToBasketAndConfirm()
            }
            
            return homeScreen.tapBasket()
                .validateBasketHasItems()
        }
    }
    
    /// Given: The user has an empty basket
    /// - Returns: BasketScreen instance
    @discardableResult
    func given_UserHasEmptyBasket() -> BasketScreen {
        return activity(named: "Given: User has empty basket") {
            _ = given_UserIsLoggedIn()
            let homeScreen = HomeScreen(app: app)
            let basketScreen = homeScreen.tapBasket()
            
            // Clear basket if has items
            if !basketScreen.isEmpty {
                basketScreen.tapClearBasket()
            }
            
            return basketScreen.validateBasketIsEmpty()
        }
    }
    
    // MARK: - Custom Preconditions
    
    /// Given: A specific product is selected
    /// - Parameter product: TestProduct to select
    /// - Returns: DrinkDetailScreen instance
    @discardableResult
    func given_ProductIsSelected(_ product: TestProduct) -> DrinkDetailScreen {
        return activity(named: "Given: Product '\(product.name)' is selected") {
            let homeScreen = launchApp()
            return homeScreen.selectDrink(named: product.name)
                .validateDrinkDetailScreen()
        }
    }
}

// MARK: - Given Step Builder
/// Fluent builder for complex preconditions
final class GivenBuilder {
    
    private weak var testCase: BaseTestCase?
    private var user: TestUser = .validUser
    private var isLoggedIn: Bool = false
    private var basketItemCount: Int = 0
    
    init(testCase: BaseTestCase) {
        self.testCase = testCase
    }
    
    /// User is logged in
    func userLoggedIn(as user: TestUser = .validUser) -> GivenBuilder {
        self.user = user
        self.isLoggedIn = true
        return self
    }
    
    /// User has items in basket
    func withItemsInBasket(count: Int) -> GivenBuilder {
        self.basketItemCount = count
        return self
    }
    
    /// Execute the preconditions
    @discardableResult
    func setup() -> HomeScreen {
        guard let testCase = testCase else {
            XCTFail("GivenBuilder: TestCase reference was lost - ensure builder is used within test scope")
            return HomeScreen(app: XCUIApplication())
        }
        
        if isLoggedIn {
            _ = testCase.given_UserIsLoggedIn(as: user)
        } else {
            _ = testCase.given_AppIsLaunched()
        }
        
        if basketItemCount > 0 {
            _ = testCase.given_UserHasItemsInBasket(itemCount: basketItemCount)
        }
        
        return HomeScreen(app: testCase.app)
    }
}

extension BaseTestCase {
    
    /// Creates a GivenBuilder for fluent precondition setup
    var given: GivenBuilder {
        return GivenBuilder(testCase: self)
    }
}
