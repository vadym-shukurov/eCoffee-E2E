import Foundation
import XCTest

class eCoffeeUITestsBase: XCTestCase {
    
    var app = XCUIApplication()
    
    override func setUpWithError() throws {
        
        try super.setUpWithError()

        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
        
        try super.tearDownWithError()
        
    }
    
}
