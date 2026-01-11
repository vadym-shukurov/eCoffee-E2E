//
//  ScreenshotCapture.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Screenshot capture utilities for visual debugging and reporting
//

import XCTest

// MARK: - Screenshot Manager
/// Manages screenshot capture with naming conventions and storage
final class ScreenshotManager {
    
    // MARK: - Singleton
    static let shared = ScreenshotManager()
    
    private init() {}
    
    // MARK: - Properties
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
    
    // MARK: - Capture Methods
    
    /// Captures screenshot with automatic naming
    /// - Parameters:
    ///   - app: XCUIApplication instance
    ///   - context: Context description for naming
    ///   - testCase: Current test case for attachment
    func capture(
        from app: XCUIApplication,
        context: String,
        attachTo testCase: XCTestCase
    ) {
        let timestamp = dateFormatter.string(from: Date())
        let sanitizedContext = context.replacingOccurrences(of: " ", with: "_")
        let name = "\(sanitizedContext)_\(timestamp)"
        
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        testCase.add(screenshot)
        
        TestLogger.shared.debug("Screenshot: \(name)")
    }
    
    /// Captures screenshot on test failure
    /// - Parameters:
    ///   - app: XCUIApplication instance
    ///   - testName: Name of the failed test
    ///   - testCase: Current test case for attachment
    func captureOnFailure(
        from app: XCUIApplication,
        testName: String,
        attachTo testCase: XCTestCase
    ) {
        let timestamp = dateFormatter.string(from: Date())
        let name = "FAILURE_\(testName)_\(timestamp)"
        
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        testCase.add(screenshot)
        
        TestLogger.shared.error("Failure screenshot: \(name)")
    }
    
    /// Captures screenshot of specific element
    /// - Parameters:
    ///   - element: XCUIElement to capture
    ///   - name: Name for the screenshot
    ///   - testCase: Current test case for attachment
    func captureElement(
        _ element: XCUIElement,
        named name: String,
        attachTo testCase: XCTestCase
    ) {
        guard element.exists else {
            TestLogger.shared.warning("Cannot capture screenshot - element does not exist")
            return
        }
        
        let screenshot = XCTAttachment(screenshot: element.screenshot())
        screenshot.name = "Element_\(name)"
        screenshot.lifetime = .keepAlways
        testCase.add(screenshot)
        
        TestLogger.shared.debug("Element screenshot: \(name)")
    }
    
    /// Captures full page screenshot
    /// - Parameters:
    ///   - app: XCUIApplication instance
    ///   - screenName: Name of the screen
    ///   - testCase: Current test case for attachment
    func captureFullPage(
        from app: XCUIApplication,
        screenName: String,
        attachTo testCase: XCTestCase
    ) {
        // Capture visible area
        capture(from: app, context: "\(screenName)_FullPage", attachTo: testCase)
    }
}

// MARK: - Test Attachment Extensions
extension XCTestCase {
    
    /// Adds text attachment to test report
    /// - Parameters:
    ///   - text: Text content
    ///   - name: Attachment name
    func addTextAttachment(_ text: String, named name: String) {
        let attachment = XCTAttachment(string: text)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /// Adds JSON attachment to test report
    /// - Parameters:
    ///   - json: JSON data
    ///   - name: Attachment name
    func addJSONAttachment(_ json: Data, named name: String) {
        let attachment = XCTAttachment(data: json, uniformTypeIdentifier: "public.json")
        attachment.name = "\(name).json"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /// Adds test context information
    func addTestContext() {
        let context = """
        Test Context:
        - Device: \(UIDevice.current.model)
        - iOS Version: \(UIDevice.current.systemVersion)
        - Environment: \(TestConfiguration.shared.environment.rawValue)
        - Timestamp: \(Date())
        """
        addTextAttachment(context, named: "TestContext")
    }
}

// MARK: - Video Recording Support
/// Video recording manager for test execution.
/// Note: Video recording via simctl requires running from command line.
/// Usage: xcrun simctl io <device> recordVideo <output.mov>
final class VideoRecordingManager {
    
    static let shared = VideoRecordingManager()
    
    private var isRecording = false
    private var currentTestName: String?
    
    private init() {}
    
    /// Starts video recording for test (logs intent for CI integration)
    /// - Parameter testName: Name of the test being recorded
    func startRecording(testName: String) {
        guard !isRecording else { return }
        isRecording = true
        currentTestName = testName
        TestLogger.shared.debug("Video recording marker: START - \(testName)")
    }
    
    /// Stops video recording
    func stopRecording() {
        guard isRecording else { return }
        isRecording = false
        if let testName = currentTestName {
            TestLogger.shared.debug("Video recording marker: END - \(testName)")
        }
        currentTestName = nil
    }
}
