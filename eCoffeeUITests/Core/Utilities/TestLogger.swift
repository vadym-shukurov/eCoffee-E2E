//
//  TestLogger.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Comprehensive logging system for test execution tracking
//

import Foundation
import XCTest

// MARK: - Test Logger
/// Centralized logging system for test execution with multiple log levels and formatting.
final class TestLogger {
    
    // MARK: - Singleton
    static let shared = TestLogger()
    
    private init() {}
    
    // MARK: - Properties
    private var stepCounter: Int = 0
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    // MARK: - Configuration
    private var config: TestConfiguration {
        return TestConfiguration.shared
    }
    
    // MARK: - Core Logging
    
    /// Logs a message at specified level
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: Log level
    ///   - file: Source file (auto-captured)
    ///   - function: Source function (auto-captured)
    ///   - line: Source line (auto-captured)
    func log(
        _ message: String,
        level: LogLevel,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard level >= config.logLevel else { return }
        
        let timestamp = dateFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        
        var logMessage = "[\(timestamp)] \(level.prefix): \(message)"
        
        if config.enableVerboseLogging && level >= .debug {
            logMessage += " | \(fileName):\(line)"
        }
        
        print(logMessage)
    }
    
    // MARK: - Convenience Methods
    
    /// Logs a debug message
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    /// Logs an info message
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    /// Logs a warning message
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    /// Logs an error message
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    /// Logs a critical message
    func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, file: file, function: function, line: line)
    }
    
    // MARK: - Test Execution Logging
    
    /// Logs a test step with auto-incrementing number
    func step(_ description: String) {
        stepCounter += 1
        let stepMessage = "Step \(stepCounter): \(description)"
        log(stepMessage, level: .info)
    }
    
    /// Resets step counter (call at test start)
    func resetStepCounter() {
        stepCounter = 0
    }
    
    /// Logs entering a screen
    func enteringScreen(_ screenName: String) {
        log("Navigating to: \(screenName)", level: .info)
    }
    
    /// Logs screen validation
    func validatingScreen(_ screenName: String) {
        log("Validating screen: \(screenName)", level: .info)
    }
    
    /// Logs an action being performed
    func action(_ description: String) {
        log("Action: \(description)", level: .info)
    }
    
    /// Logs a verification/assertion
    func verify(_ description: String) {
        log("Verifying: \(description)", level: .info)
    }
    
    /// Logs test data usage
    func testData(_ description: String) {
        log("Test Data: \(description)", level: .debug)
    }
    
    // MARK: - Separator Logging
    
    /// Logs a section separator
    func section(_ title: String) {
        let separator = String(repeating: "-", count: 50)
        log("\n\(separator)", level: .info)
        log("\(title.uppercased())", level: .info)
        log("\(separator)", level: .info)
    }
    
    /// Logs a subsection
    func subsection(_ title: String) {
        log("  |-- \(title)", level: .info)
    }
    
    // MARK: - Performance Logging
    
    /// Logs performance metrics
    func performance(operation: String, duration: TimeInterval) {
        let formattedDuration = String(format: "%.3f", duration)
        log("Performance - \(operation): \(formattedDuration)s", level: .info)
    }
    
    /// Measures and logs execution time of a block
    func measureTime<T>(_ operation: String, block: () throws -> T) rethrows -> T {
        let startTime = Date()
        let result = try block()
        let duration = Date().timeIntervalSince(startTime)
        performance(operation: operation, duration: duration)
        return result
    }
    
    // MARK: - API/Network Logging
    
    /// Logs API request
    func apiRequest(method: String, endpoint: String) {
        log("API Request: \(method) \(endpoint)", level: .debug)
    }
    
    /// Logs API response
    func apiResponse(statusCode: Int, endpoint: String) {
        let status = (200...299).contains(statusCode) ? "OK" : "ERROR"
        log("\(status) API Response: \(statusCode) from \(endpoint)", level: .debug)
    }
}

// MARK: - XCTestCase Extension for Logging
extension XCTestCase {
    
    /// Quick access to logger
    var log: TestLogger {
        return TestLogger.shared
    }
}

// MARK: - Report Generator
/// Generates test execution reports
final class TestReportGenerator {
    
    // MARK: - Singleton
    static let shared = TestReportGenerator()
    
    private init() {}
    
    // MARK: - Properties
    private var testResults: [TestResult] = []
    
    // MARK: - Test Result
    struct TestResult {
        let name: String
        let status: TestStatus
        let duration: TimeInterval
        let errorMessage: String?
        let timestamp: Date
        
        enum TestStatus: String {
            case passed = "PASSED"
            case failed = "FAILED"
            case skipped = "SKIPPED"
        }
    }
    
    // MARK: - Methods
    
    /// Records a test result
    func recordResult(_ result: TestResult) {
        testResults.append(result)
    }
    
    /// Generates summary report
    func generateSummary() -> String {
        let total = testResults.count
        let passed = testResults.filter { $0.status == .passed }.count
        let failed = testResults.filter { $0.status == .failed }.count
        let skipped = testResults.filter { $0.status == .skipped }.count
        let totalDuration = testResults.reduce(0) { $0 + $1.duration }
        
        var report = """
        
        ================================================================
                            TEST EXECUTION SUMMARY                    
        ================================================================
          Total Tests:    \(String(format: "%-42d", total))
          Passed:         \(String(format: "%-42d", passed))
          Failed:         \(String(format: "%-42d", failed))
          Skipped:        \(String(format: "%-42d", skipped))
          Duration:       \(String(format: "%-42.2f", totalDuration))s
        ================================================================
        
        """
        
        if !testResults.filter({ $0.status == .failed }).isEmpty {
            report += "\nFAILED TESTS:\n"
            for result in testResults.where({ $0.status == .failed }) {
                report += "  - \(result.name)"
                if let error = result.errorMessage {
                    report += ": \(error)"
                }
                report += "\n"
            }
        }
        
        return report
    }
    
    /// Clears all recorded results
    func clearResults() {
        testResults.removeAll()
    }
}

// MARK: - Array Extension for Report
extension Array where Element == TestReportGenerator.TestResult {
    func `where`(_ predicate: (Element) -> Bool) -> [Element] {
        return self.filter(predicate)
    }
}
