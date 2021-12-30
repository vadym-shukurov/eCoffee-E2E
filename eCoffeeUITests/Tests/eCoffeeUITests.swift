import XCTest

class eCoffeeUITests: eCoffeeUITestsBase {

    
    func test01_UserLogIn() throws {
        app.launch()
        XCTAssertTrue(app.staticTexts["iCoffee"].exists)
        XCTAssertTrue(app.buttons["Basket"].exists)
        app.buttons["Basket"].tap()
        XCTAssertTrue(app.textFields["Enter your email"].exists)
        app.textFields["EnterEmail"].tap()
        app.textFields["EnterEmail"].typeText("gupta.akki23@gmail.com")
        XCTAssertTrue(app.secureTextFields["Password"].exists)
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("Otrium1234")
        XCTAssertTrue(app.buttons["Sign"].exists)
        app.buttons["Sign"].tap()
        sleep(1)
        
    }
    
    func test02_AddItemToBasket() throws {
        app.launch()
        XCTAssertTrue(app.staticTexts["iCoffee"].exists)
        app.cells.element(boundBy: 1).tap()
        XCTAssertTrue(app.buttons["AddToBasket"].exists)
        app.scrollViews.otherElements.buttons["AddToBasket"].tap()
        app.alerts["Added to  Basket!"].scrollViews.otherElements.buttons["OK"].tap()
        
                
                                
    }
    
    func test03_CompleteNewOrder() throws {
        app.launch()
        XCTAssertTrue(app.staticTexts["iCoffee"].exists)
        app.buttons["Basket"].tap()
        XCTAssertTrue(app.buttons["PlaceOrder"].exists)
        app.buttons["PlaceOrder"].tap()
        app.tables.buttons["HowToPay"].tap()
        app.tables/*@START_MENU_TOKEN@*/.switches["Credit Card"]/*[[".cells[\"Credit Card\"].switches[\"Credit Card\"]",".switches[\"Credit Card\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.tables/*@START_MENU_TOKEN@*/.buttons["10 %"]/*[[".cells[\"10 %, 10 %, 15 %, 15 %, 20 %, 20 %, 0 %, 0 %\"]",".segmentedControls.buttons[\"10 %\"]",".buttons[\"10 %\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.swipeRight()
        XCTAssertTrue(app.buttons["ConfirmOrder"].exists)
        app.buttons["ConfirmOrder"].tap()
        app.alerts["Order confirmed"].scrollViews.otherElements.buttons["OK"].tap()
        sleep(1)
        //XCUIDevice.shared.press(.home)
        
    }
    
    func test04_LogOut() throws {
        app.launch()
        XCTAssertTrue(app.staticTexts["iCoffee"].exists)
        app.buttons["LogOut"].tap()

    }

    
}
