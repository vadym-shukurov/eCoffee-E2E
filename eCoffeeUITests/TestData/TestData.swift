//
//  TestData.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Test data management - Products, orders, and fixtures
//

import Foundation

// MARK: - Test Product
/// Represents a coffee product for testing
struct TestProduct {
    let name: String
    let price: Double
    let category: ProductCategory
    let isAvailable: Bool
    
    enum ProductCategory: String {
        case hot = "Hot"
        case cold = "Cold"
        case specialty = "Specialty"
    }
}

// MARK: - Predefined Test Products
extension TestProduct {
    
    static let americano = TestProduct(
        name: "Americano",
        price: 3.50,
        category: .hot,
        isAvailable: true
    )
    
    static let cappuccino = TestProduct(
        name: "Cappuccino",
        price: 4.00,
        category: .hot,
        isAvailable: true
    )
    
    static let latte = TestProduct(
        name: "Latte",
        price: 4.50,
        category: .hot,
        isAvailable: true
    )
    
    static let espresso = TestProduct(
        name: "Espresso",
        price: 2.50,
        category: .hot,
        isAvailable: true
    )
    
    static let coldBrew = TestProduct(
        name: "Cold Brew",
        price: 4.50,
        category: .cold,
        isAvailable: true
    )
    
    static let frappe = TestProduct(
        name: "Frappe",
        price: 5.00,
        category: .cold,
        isAvailable: true
    )
    
    static let icedLatte = TestProduct(
        name: "Iced Latte",
        price: 5.00,
        category: .cold,
        isAvailable: true
    )
    
    /// All available products
    static let allProducts: [TestProduct] = [
        .americano, .cappuccino, .latte, .espresso,
        .coldBrew, .frappe, .icedLatte
    ]
    
    /// Hot drinks only
    static let hotDrinks: [TestProduct] = allProducts.filter { $0.category == .hot }
    
    /// Cold drinks only
    static let coldDrinks: [TestProduct] = allProducts.filter { $0.category == .cold }
}

// MARK: - Test Order
/// Represents an order for testing
struct TestOrder {
    let items: [OrderItem]
    let paymentMethod: PaymentMethod
    let tipPercentage: TipPercentage
    
    struct OrderItem {
        let product: TestProduct
        let quantity: Int
        
        var subtotal: Double {
            return product.price * Double(quantity)
        }
    }
    
    var subtotal: Double {
        return items.reduce(0) { $0 + $1.subtotal }
    }
    
    var tipAmount: Double {
        let tipPercent: Double
        switch tipPercentage {
        case .zero: tipPercent = 0
        case .ten: tipPercent = 0.10
        case .fifteen: tipPercent = 0.15
        case .twenty: tipPercent = 0.20
        }
        return subtotal * tipPercent
    }
    
    var total: Double {
        return subtotal + tipAmount
    }
}

// MARK: - Predefined Test Orders
extension TestOrder {
    
    /// Simple order with one item
    static let singleItemOrder = TestOrder(
        items: [
            OrderItem(product: .cappuccino, quantity: 1)
        ],
        paymentMethod: .creditCard,
        tipPercentage: .ten
    )
    
    /// Order with multiple items
    static let multiItemOrder = TestOrder(
        items: [
            OrderItem(product: .latte, quantity: 2),
            OrderItem(product: .espresso, quantity: 1),
            OrderItem(product: .coldBrew, quantity: 1)
        ],
        paymentMethod: .creditCard,
        tipPercentage: .fifteen
    )
    
    /// Large order for performance testing
    static let largeOrder = TestOrder(
        items: TestProduct.allProducts.map { OrderItem(product: $0, quantity: 2) },
        paymentMethod: .creditCard,
        tipPercentage: .twenty
    )
    
    /// Cash payment order
    static let cashOrder = TestOrder(
        items: [
            OrderItem(product: .americano, quantity: 1)
        ],
        paymentMethod: .cash,
        tipPercentage: .zero
    )
}

// MARK: - Test Data Provider
/// Centralized provider for all test data
final class TestDataProvider {
    
    static let shared = TestDataProvider()
    
    private init() {}
    
    // MARK: - Users
    var defaultUser: TestUser { .validUser }
    var invalidUser: TestUser { .invalidEmailUser }
    
    // MARK: - Products
    var defaultProduct: TestProduct { .cappuccino }
    var allProducts: [TestProduct] { TestProduct.allProducts }
    
    // MARK: - Orders
    var defaultOrder: TestOrder { .singleItemOrder }
    
    // MARK: - Random Data
    
    /// Returns a random product
    func randomProduct() -> TestProduct {
        return TestProduct.allProducts.randomElement() ?? .cappuccino
    }
    
    /// Returns a random hot drink
    func randomHotDrink() -> TestProduct {
        return TestProduct.hotDrinks.randomElement() ?? .cappuccino
    }
    
    /// Returns a random cold drink
    func randomColdDrink() -> TestProduct {
        return TestProduct.coldDrinks.randomElement() ?? .coldBrew
    }
    
    /// Returns N random products
    func randomProducts(count: Int) -> [TestProduct] {
        return Array(TestProduct.allProducts.shuffled().prefix(count))
    }
    
    // MARK: - Dynamic Data Generation
    
    /// Generates unique email
    func generateUniqueEmail(prefix: String = "test") -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 1000...9999)
        return "\(prefix).\(timestamp).\(random)@ecoffee.com"
    }
    
    /// Generates order reference number
    func generateOrderReference() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        return "ORD-\(timestamp)"
    }
}

// MARK: - Data-Driven Test Support
/// Structure for parameterized testing
struct TestCase<Input, Expected> {
    let name: String
    let input: Input
    let expected: Expected
    let tags: [String]
    
    init(name: String, input: Input, expected: Expected, tags: [String] = []) {
        self.name = name
        self.input = input
        self.expected = expected
        self.tags = tags
    }
}

// MARK: - Login Test Cases
extension TestCase where Input == TestUser, Expected == Bool {
    
    /// Test cases for login functionality
    static let loginTestCases: [TestCase<TestUser, Bool>] = [
        TestCase(
            name: "Valid credentials should login successfully",
            input: .validUser,
            expected: true,
            tags: [TestTags.smoke, TestTags.authentication]
        ),
        TestCase(
            name: "Invalid email should fail login",
            input: .invalidEmailUser,
            expected: false,
            tags: [TestTags.regression, TestTags.authentication]
        ),
        TestCase(
            name: "Wrong password should fail login",
            input: .wrongPasswordUser,
            expected: false,
            tags: [TestTags.regression, TestTags.authentication]
        ),
        TestCase(
            name: "Non-existent user should fail login",
            input: .nonExistentUser,
            expected: false,
            tags: [TestTags.regression, TestTags.authentication]
        )
    ]
}
