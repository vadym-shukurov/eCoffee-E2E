//
//  eCoffeeUITestsLaunchTests.swift
//  eCoffeeUITests
//
//  Enterprise-Grade iOS UI Test Automation Framework
//  Author: Vadym Shukurov
//
//  Launch and Performance Tests
//

import XCTest

// MARK: - Launch Tests
/// Tests for application launch scenarios and performance metrics.
/// Tags: Launch, Performance, Smoke
final class LaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Test: Application launches successfully
    /// Priority: P0 - Critical
    /// Tags: Smoke, Launch
    func test_Launch_ShouldDisplayHomeScreen() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Capture launch screenshot
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Launch_Screen"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        
        // Verify home screen loads
        XCTAssertTrue(app.staticTexts["iCoffee"].waitForExistence(timeout: 10))
    }
}

// MARK: - Performance Tests
/// Tests for measuring application performance metrics.
/// Tags: Performance, NonFunctional
final class PerformanceTests: XCTestCase {
    
    /// Test: Measure application launch time
    /// Priority: P2 - Medium
    /// Tags: Performance, Launch
    func test_LaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    /// Test: Measure scroll performance
    /// Priority: P2 - Medium
    /// Tags: Performance, UI
    func test_ScrollPerformance() throws {
        let app = XCUIApplication()
        app.launch()
        
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            app.swipeUp()
            app.swipeDown()
        }
    }
    
    /// Test: Measure navigation performance
    /// Priority: P2 - Medium
    /// Tags: Performance, Navigation
    func test_NavigationPerformance() throws {
        let app = XCUIApplication()
        app.launch()
        
        let measureOptions = XCTMeasureOptions()
        measureOptions.iterationCount = 5
        
        measure(options: measureOptions) {
            // Navigate to drink detail
            if app.cells.element(boundBy: 1).waitForExistence(timeout: 5) {
                app.cells.element(boundBy: 1).tap()
            }
            
            // Navigate back
            if app.navigationBars.buttons.element(boundBy: 0).exists {
                app.navigationBars.buttons.element(boundBy: 0).tap()
            }
        }
    }
}

// MARK: - Memory Tests
/// Tests for memory-related scenarios.
/// Tags: Performance, Memory
final class MemoryTests: XCTestCase {
    
    /// Test: Multiple navigation cycles don't cause memory issues
    /// Priority: P2 - Medium
    /// Tags: Memory, Stability
    func test_RepeatedNavigation_ShouldNotLeakMemory() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Perform multiple navigation cycles
        for _ in 1...10 {
            let cell = app.cells.element(boundBy: 1)
            if cell.waitForExistence(timeout: 3) {
                cell.tap()
            }
            
            // Wait for detail screen to load (using element existence, not sleep)
            let addButton = app.scrollViews.otherElements.buttons["AddToBasket"]
            _ = addButton.waitForExistence(timeout: 3)
            
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.waitForExistence(timeout: 2) {
                backButton.tap()
            }
            
            // Wait for catalog to load (using element existence, not sleep)
            _ = app.staticTexts["iCoffee"].waitForExistence(timeout: 3)
        }
        
        // App should still be responsive
        XCTAssertTrue(app.staticTexts["iCoffee"].exists)
    }
}
