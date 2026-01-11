//
//  TestUser.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Test data management - User credentials and profiles
//

import Foundation

// MARK: - Test User
/// Represents a test user with credentials and profile information.
/// Follows the Builder pattern for flexible user creation.
struct TestUser {
    
    // MARK: - Properties
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let userType: UserType
    
    // MARK: - User Type
    enum UserType: String {
        case standard = "Standard"
        case premium = "Premium"
        case admin = "Admin"
        case guest = "Guest"
    }
    
    // MARK: - Computed Properties
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var displayName: String {
        return firstName
    }
    
    // MARK: - Initializer
    init(
        email: String,
        password: String,
        firstName: String = "Test",
        lastName: String = "User",
        userType: UserType = .standard
    ) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.userType = userType
    }
}

// MARK: - Predefined Test Users
extension TestUser {
    
    /// Default test user for general testing
    static let defaultUser = TestUser(
        email: "test.user@ecoffee.com",
        password: "TestPassword123!",
        firstName: "Test",
        lastName: "User",
        userType: .standard
    )
    
    /// Valid user with known credentials
    static let validUser = TestUser(
        email: "gupta.akki23@gmail.com",
        password: "Otrium1234",
        firstName: "Akshaya",
        lastName: "Gupta",
        userType: .standard
    )
    
    /// Premium test user
    static let premiumUser = TestUser(
        email: "premium.user@ecoffee.com",
        password: "Premium123!",
        firstName: "Premium",
        lastName: "Customer",
        userType: .premium
    )
    
    /// Admin test user
    static let adminUser = TestUser(
        email: "admin@ecoffee.com",
        password: "Admin123!",
        firstName: "Admin",
        lastName: "User",
        userType: .admin
    )
    
    /// Guest user (no credentials)
    static let guestUser = TestUser(
        email: "",
        password: "",
        firstName: "Guest",
        lastName: "",
        userType: .guest
    )
    
    // MARK: - Invalid Users for Negative Testing
    
    /// User with invalid email format
    static let invalidEmailUser = TestUser(
        email: "invalid-email",
        password: "ValidPassword123!",
        firstName: "Invalid",
        lastName: "Email"
    )
    
    /// User with wrong password
    static let wrongPasswordUser = TestUser(
        email: "gupta.akki23@gmail.com",
        password: "WrongPassword123!",
        firstName: "Wrong",
        lastName: "Password"
    )
    
    /// User with empty password
    static let emptyPasswordUser = TestUser(
        email: "test@ecoffee.com",
        password: "",
        firstName: "Empty",
        lastName: "Password"
    )
    
    /// Non-existent user
    static let nonExistentUser = TestUser(
        email: "nonexistent@ecoffee.com",
        password: "Password123!",
        firstName: "Non",
        lastName: "Existent"
    )
}

// MARK: - Test User Builder
/// Builder pattern for creating custom test users
final class TestUserBuilder {
    
    private var email: String = "builder@ecoffee.com"
    private var password: String = "Builder123!"
    private var firstName: String = "Builder"
    private var lastName: String = "User"
    private var userType: TestUser.UserType = .standard
    
    func withEmail(_ email: String) -> TestUserBuilder {
        self.email = email
        return self
    }
    
    func withPassword(_ password: String) -> TestUserBuilder {
        self.password = password
        return self
    }
    
    func withFirstName(_ firstName: String) -> TestUserBuilder {
        self.firstName = firstName
        return self
    }
    
    func withLastName(_ lastName: String) -> TestUserBuilder {
        self.lastName = lastName
        return self
    }
    
    func withUserType(_ userType: TestUser.UserType) -> TestUserBuilder {
        self.userType = userType
        return self
    }
    
    func build() -> TestUser {
        return TestUser(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            userType: userType
        )
    }
    
    /// Creates a unique user with timestamp-based email
    func buildUnique() -> TestUser {
        let timestamp = Int(Date().timeIntervalSince1970)
        let uniqueEmail = "test.user.\(timestamp)@ecoffee.com"
        return TestUser(
            email: uniqueEmail,
            password: password,
            firstName: firstName,
            lastName: lastName,
            userType: userType
        )
    }
}

// MARK: - User Credentials Provider
/// Provides user credentials based on environment
final class UserCredentialsProvider {
    
    static let shared = UserCredentialsProvider()
    
    private init() {}
    
    /// Returns appropriate test user based on current environment
    func getTestUser(for environment: TestEnvironment) -> TestUser {
        switch environment {
        case .development:
            return .validUser
        case .staging:
            return .validUser
        case .production:
            // Use dedicated production test account
            return TestUser(
                email: "prod.test@ecoffee.com",
                password: "ProdTest123!",
                firstName: "Production",
                lastName: "Tester",
                userType: .standard
            )
        }
    }
    
    /// Returns user for specific test scenario
    func getUser(for scenario: TestScenario) -> TestUser {
        switch scenario {
        case .happyPath:
            return .validUser
        case .negativeEmailValidation:
            return .invalidEmailUser
        case .negativePasswordValidation:
            return .wrongPasswordUser
        case .nonExistentAccount:
            return .nonExistentUser
        }
    }
    
    /// Test scenarios for user selection
    enum TestScenario {
        case happyPath
        case negativeEmailValidation
        case negativePasswordValidation
        case nonExistentAccount
    }
}
