//
//  TestConfiguration.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Centralized configuration management for test execution
//

import Foundation
import XCTest

// MARK: - Test Environment
/// Represents different test environments
enum TestEnvironment: String {
    case development = "DEV"
    case staging = "STAGING"
    case production = "PROD"
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://dev-api.ecoffee.com"
        case .staging:
            return "https://staging-api.ecoffee.com"
        case .production:
            return "https://api.ecoffee.com"
        }
    }
}

// MARK: - Test Configuration
/// Singleton class managing all test configuration parameters
final class TestConfiguration {
    
    // MARK: - Singleton
    static let shared = TestConfiguration()
    
    private init() {
        loadConfiguration()
    }
    
    // MARK: - Environment
    var environment: TestEnvironment = .development
    
    // MARK: - Timeouts
    var defaultTimeout: TimeInterval = 10.0
    var shortTimeout: TimeInterval = 3.0
    var longTimeout: TimeInterval = 30.0
    var animationTimeout: TimeInterval = 0.5
    
    // MARK: - Retry Configuration
    var maxRetryAttempts: Int = 3
    var retryDelaySeconds: TimeInterval = 1.0
    
    // MARK: - Screenshot Configuration
    var captureScreenshotOnFailure: Bool = true
    var captureScreenshotOnSuccess: Bool = false
    var screenshotQuality: XCTAttachment.Lifetime = .keepAlways
    
    // MARK: - Logging
    var enableVerboseLogging: Bool = true
    var logLevel: LogLevel = .info
    
    // MARK: - Test Execution
    var shouldResetAppState: Bool = true
    var parallelExecutionEnabled: Bool = false
    
    // MARK: - Device Configuration
    var targetDevice: String {
        return UIDevice.current.model
    }
    
    var targetOSVersion: String {
        return UIDevice.current.systemVersion
    }
    
    // MARK: - Load Configuration
    private func loadConfiguration() {
        // Load from environment variables if available
        if let envString = ProcessInfo.processInfo.environment["TEST_ENVIRONMENT"],
           let env = TestEnvironment(rawValue: envString) {
            environment = env
        }
        
        if let timeoutString = ProcessInfo.processInfo.environment["DEFAULT_TIMEOUT"],
           let timeout = TimeInterval(timeoutString) {
            defaultTimeout = timeout
        }
        
        if let verboseString = ProcessInfo.processInfo.environment["VERBOSE_LOGGING"] {
            enableVerboseLogging = verboseString.lowercased() == "true"
        }
    }
    
    // MARK: - Runtime Configuration
    /// Updates configuration at runtime
    /// - Parameters:
    ///   - timeout: New default timeout value
    ///   - environment: New target environment
    func configure(timeout: TimeInterval? = nil, environment: TestEnvironment? = nil) {
        if let timeout = timeout {
            self.defaultTimeout = timeout
        }
        if let environment = environment {
            self.environment = environment
        }
    }
    
    // MARK: - Launch Arguments
    /// Returns launch arguments for the application
    var launchArguments: [String] {
        var arguments: [String] = []
        
        // UI Testing mode
        arguments.append("-UITesting")
        
        // Environment
        arguments.append("-Environment")
        arguments.append(environment.rawValue)
        
        // Animations (disable for faster test execution)
        arguments.append("-DisableAnimations")
        
        return arguments
    }
    
    // MARK: - Launch Environment
    /// Returns launch environment variables for the application
    var launchEnvironment: [String: String] {
        return [
            "UITEST_RUNNING": "1",
            "ENVIRONMENT": environment.rawValue,
            "ANIMATIONS_DISABLED": "1"
        ]
    }
}

// MARK: - Log Level
enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case critical = 4
    
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    var prefix: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        case .critical: return "CRITICAL"
        }
    }
}

// MARK: - Test Tags
/// Tags for categorizing and filtering tests
struct TestTags {
    static let smoke = "Smoke"
    static let regression = "Regression"
    static let sanity = "Sanity"
    static let critical = "Critical"
    static let authentication = "Authentication"
    static let checkout = "Checkout"
    static let catalog = "Catalog"
    static let orders = "Orders"
    static let performance = "Performance"
    static let accessibility = "Accessibility"
}
