//
//  BaseTestCase.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Base test class providing common functionality for all test classes
//

import XCTest

// MARK: - Base Test Case
/// Abstract base class for all UI test cases.
/// Provides setup/teardown, screenshot capture, logging, and common utilities.
class BaseTestCase: XCTestCase {
    
    // MARK: - Properties
    
    /// The application under test
    var app: XCUIApplication!
    
    /// Configuration instance
    var config: TestConfiguration {
        return TestConfiguration.shared
    }
    
    /// Logger instance
    var logger: TestLogger {
        return TestLogger.shared
    }
    
    /// Test start time for duration tracking
    private var testStartTime: Date?
    
    /// Current test name
    var currentTestName: String {
        return String(describing: name)
    }
    
    // MARK: - Lifecycle
    
    override class func setUp() {
        super.setUp()
        // Class-level setup - runs once per test class
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        testStartTime = Date()
        
        // Configure test execution
        continueAfterFailure = false
        
        // Initialize application
        app = XCUIApplication()
        
        // Configure launch arguments and environment
        app.launchArguments = config.launchArguments
        app.launchEnvironment = config.launchEnvironment
        
        // Reset app state if configured
        if config.shouldResetAppState {
            resetApplicationState()
        }
        
        // Log test start
        logger.info("========================================================")
        logger.info("Starting Test: \(currentTestName)")
        logger.info("Device: \(config.targetDevice) - iOS \(config.targetOSVersion)")
        logger.info("Environment: \(config.environment.rawValue)")
        logger.info("========================================================")
        
        // Add test observer for failure handling
        addTeardownBlock { [weak self] in
            self?.handleTestCompletion()
        }
    }
    
    override func tearDownWithError() throws {
        // Calculate test duration
        if let startTime = testStartTime {
            let duration = Date().timeIntervalSince(startTime)
            logger.info("Test Duration: \(String(format: "%.2f", duration)) seconds")
        }
        
        // Terminate app
        app.terminate()
        app = nil
        
        try super.tearDownWithError()
    }
    
    // MARK: - Application Management
    
    /// Launches the application with configured settings
    @discardableResult
    func launchApp() -> HomeScreen {
        logger.info("Launching application...")
        app.launch()
        return HomeScreen(app: app)
    }
    
    /// Resets application state for clean test execution
    private func resetApplicationState() {
        // Uninstall and reinstall would require device management tools
        // For now, we use launch arguments to reset state
        app.launchArguments.append("-ResetState")
    }
    
    /// Terminates and relaunches the application
    @discardableResult
    func relaunchApp() -> HomeScreen {
        logger.info("Relaunching application...")
        app.terminate()
        return launchApp()
    }
    
    // MARK: - Test Completion Handling
    
    private func handleTestCompletion() {
        // Capture screenshot on failure
        if config.captureScreenshotOnFailure {
            captureScreenshotOnFailure()
        }
        
        // Log completion
        logger.info("========================================================")
        logger.info("Completed Test: \(currentTestName)")
        logger.info("========================================================\n")
    }
    
    // MARK: - Screenshot Capture
    
    /// Captures a screenshot and attaches it to the test report
    /// - Parameter name: Name for the screenshot attachment
    func captureScreenshot(named name: String) {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name
        screenshot.lifetime = config.screenshotQuality
        add(screenshot)
        logger.debug("Screenshot captured: \(name)")
    }
    
    /// Captures screenshot on test failure
    private func captureScreenshotOnFailure() {
        // Check if test failed by examining testRun
        if let testRun = testRun, testRun.failureCount > 0 {
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
            captureScreenshot(named: "Failure_\(currentTestName)_\(timestamp)")
        }
    }
    
    // MARK: - Test Activities
    
    /// Wraps an action in a named XCTest activity for better reporting
    /// - Parameters:
    ///   - name: Activity name
    ///   - block: The action to perform
    /// - Returns: The result of the block execution
    @discardableResult
    func activity<T>(named name: String, block: () throws -> T) rethrows -> T {
        logger.step(name)
        return try XCTContext.runActivity(named: name) { _ in
            try block()
        }
    }
    
    // MARK: - Retry Mechanism
    
    /// Retries an action with exponential backoff
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts
    ///   - action: The action to retry
    /// - Returns: Boolean indicating success
    @discardableResult
    func retry(maxAttempts: Int = 3, action: () throws -> Bool) rethrows -> Bool {
        var attempt = 0
        var lastError: Error?
        
        while attempt < maxAttempts {
            do {
                if try action() {
                    return true
                }
            } catch {
                lastError = error
                logger.warning("Attempt \(attempt + 1) failed: \(error.localizedDescription)")
            }
            
            attempt += 1
            if attempt < maxAttempts {
                let delay = config.retryDelaySeconds * Double(attempt)
                Thread.sleep(forTimeInterval: delay)
            }
        }
        
        if let error = lastError {
            logger.error("All \(maxAttempts) attempts failed. Last error: \(error.localizedDescription)")
        }
        
        return false
    }
    
    // MARK: - Assertions
    
    /// Custom assertion with detailed logging
    func assertThat(_ condition: Bool, _ message: String, file: StaticString = #file, line: UInt = #line) {
        if !condition {
            captureScreenshot(named: "AssertionFailure")
            logger.error("Assertion failed: \(message)")
        }
        XCTAssertTrue(condition, message, file: file, line: line)
    }
    
    /// Asserts element exists with custom timeout
    func assertElementExists(_ element: XCUIElement, timeout: TimeInterval? = nil, file: StaticString = #file, line: UInt = #line) {
        let waitTime = timeout ?? config.defaultTimeout
        let exists = element.waitForExistence(timeout: waitTime)
        
        if !exists {
            captureScreenshot(named: "ElementNotFound")
            logger.error("Element not found: \(element.debugDescription)")
        }
        
        XCTAssertTrue(exists, "Element '\(element.identifier)' does not exist after \(waitTime) seconds", file: file, line: line)
    }
    
    /// Asserts element does not exist
    func assertElementNotExists(_ element: XCUIElement, timeout: TimeInterval? = nil, file: StaticString = #file, line: UInt = #line) {
        let waitTime = timeout ?? config.shortTimeout
        let disappeared = Waiter.waitForElementToDisappear(element, timeout: waitTime)
        
        if !disappeared {
            captureScreenshot(named: "ElementStillExists")
            logger.error("Element still exists: \(element.debugDescription)")
        }
        
        XCTAssertTrue(disappeared, "Element '\(element.identifier)' still exists after \(waitTime) seconds", file: file, line: line)
    }
}

// MARK: - Test Execution Helpers
extension BaseTestCase {
    
    /// Marks test as skipped with reason
    func skipTest(reason: String) {
        logger.warning("Test skipped: \(reason)")
        XCTSkip(reason)
    }
    
    /// Fails test with detailed message
    func failTest(reason: String, file: StaticString = #file, line: UInt = #line) {
        captureScreenshot(named: "TestFailure")
        logger.error("Test failed: \(reason)")
        XCTFail(reason, file: file, line: line)
    }
    
    /// Records an issue without failing the test
    func recordIssue(_ description: String) {
        logger.warning("Issue recorded: \(description)")
        let issue = XCTIssue(type: .assertionFailure, compactDescription: description)
        record(issue)
    }
}
