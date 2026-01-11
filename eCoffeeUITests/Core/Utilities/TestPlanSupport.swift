//
//  TestPlanSupport.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Test Plan support utilities for Xcode Test Plans
//

import XCTest

// MARK: - Test Plan Configuration
/// Support for Xcode Test Plans and test organization
struct TestPlanSupport {
    
    // MARK: - Test Suite Types
    enum TestSuiteType: String {
        case smoke = "Smoke"
        case regression = "Regression"
        case sanity = "Sanity"
        case e2e = "E2E"
        case performance = "Performance"
        case accessibility = "Accessibility"
    }
    
    // MARK: - Environment Variables
    
    /// Gets the current test suite type from environment
    static var currentSuiteType: TestSuiteType {
        if let suiteString = ProcessInfo.processInfo.environment["TEST_SUITE"],
           let suite = TestSuiteType(rawValue: suiteString) {
            return suite
        }
        return .regression
    }
    
    /// Gets test tags from environment
    static var testTags: [String] {
        if let tagsString = ProcessInfo.processInfo.environment["TEST_TAGS"] {
            return tagsString.components(separatedBy: ",")
        }
        return []
    }
    
    /// Checks if running in CI environment
    static var isCI: Bool {
        return ProcessInfo.processInfo.environment["CI"] == "true"
    }
    
    /// Gets the retry count for flaky tests
    static var retryCount: Int {
        if let retryString = ProcessInfo.processInfo.environment["RETRY_COUNT"],
           let count = Int(retryString) {
            return count
        }
        return 0
    }
}

// MARK: - Test Categorization
/// Protocol for categorizing tests
protocol TestCategorizable {
    var testTags: [String] { get }
    var testPriority: TestPriority { get }
}

/// Test priority levels
enum TestPriority: Int, Comparable {
    case p0 = 0  // Critical - Must pass
    case p1 = 1  // High - Should pass
    case p2 = 2  // Medium - Nice to have
    case p3 = 3  // Low - Can fail
    
    static func < (lhs: TestPriority, rhs: TestPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    var description: String {
        switch self {
        case .p0: return "P0 - Critical"
        case .p1: return "P1 - High"
        case .p2: return "P2 - Medium"
        case .p3: return "P3 - Low"
        }
    }
}

// MARK: - Test Skip Conditions
extension XCTestCase {
    
    /// Skips test if running in CI
    func skipIfCI(reason: String = "Test disabled in CI") {
        if TestPlanSupport.isCI {
            XCTSkip(reason)
        }
    }
    
    /// Skips test if not running specified suite
    func skipIfNotSuite(_ suite: TestPlanSupport.TestSuiteType) {
        if TestPlanSupport.currentSuiteType != suite {
            XCTSkip("Test only runs in \(suite.rawValue) suite")
        }
    }
    
    /// Skips test on specific iOS versions
    func skipOn(iOSVersion: String, reason: String) {
        if UIDevice.current.systemVersion.hasPrefix(iOSVersion) {
            XCTSkip(reason)
        }
    }
    
    /// Skips test on specific device types
    func skipOnDevice(_ deviceType: String, reason: String) {
        if UIDevice.current.model.contains(deviceType) {
            XCTSkip(reason)
        }
    }
}

// MARK: - Test Metrics
/// Collects and reports test execution metrics
final class TestMetricsCollector {
    
    static let shared = TestMetricsCollector()
    
    private init() {}
    
    // MARK: - Properties
    private var testStartTime: [String: Date] = [:]
    private var testDurations: [String: TimeInterval] = [:]
    private var testResults: [String: Bool] = [:]
    
    // MARK: - Methods
    
    /// Records test start
    func recordStart(testName: String) {
        testStartTime[testName] = Date()
    }
    
    /// Records test completion
    func recordCompletion(testName: String, passed: Bool) {
        if let startTime = testStartTime[testName] {
            testDurations[testName] = Date().timeIntervalSince(startTime)
        }
        testResults[testName] = passed
    }
    
    /// Gets summary of all test executions
    func getSummary() -> String {
        let total = testResults.count
        let passed = testResults.values.filter { $0 }.count
        let failed = total - passed
        let totalDuration = testDurations.values.reduce(0, +)
        
        return """
        Test Execution Summary:
        -------------------------
        Total Tests: \(total)
        Passed: \(passed)
        Failed: \(failed)
        Pass Rate: \(total > 0 ? String(format: "%.1f%%", Double(passed)/Double(total)*100) : "N/A")
        Total Duration: \(String(format: "%.2f", totalDuration))s
        """
    }
    
    /// Resets all metrics
    func reset() {
        testStartTime.removeAll()
        testDurations.removeAll()
        testResults.removeAll()
    }
}

// MARK: - Allure-Compatible Annotations
/// Annotations compatible with Allure reporting
struct AllureAnnotations {
    
    /// Adds feature annotation
    static func feature(_ name: String) -> String {
        return "Feature: \(name)"
    }
    
    /// Adds story annotation
    static func story(_ name: String) -> String {
        return "Story: \(name)"
    }
    
    /// Adds severity annotation
    static func severity(_ level: String) -> String {
        return "Severity: \(level)"
    }
    
    /// Adds link annotation
    static func link(_ url: String, name: String) -> String {
        return "Link: [\(name)](\(url))"
    }
    
    /// Adds issue annotation
    static func issue(_ id: String) -> String {
        return "Issue: \(id)"
    }
    
    /// Adds test case ID annotation
    static func testCaseId(_ id: String) -> String {
        return "TestCase: \(id)"
    }
}
