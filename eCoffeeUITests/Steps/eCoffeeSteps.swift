import Foundation
import XCTest

extension eCoffeeUITestsBase {
    
    func givenAppIsReady() {
        XCTContext.runActivity(named: "Given App Is Ready") { _ in app.launch()
            XCTAssertTrue(eCoffeeScreen.iCoffee.element.exists)
        }
        
    }
    
    func whenIOpenBasket() {
        XCTContext.runActivity(named: "When I Open Basket") { _ in
            XCTAssertTrue(eCoffeeScreen.Basket.element.exists)
            eCoffeeScreen.Basket.element.tap()
        }
    }
    
    func whenIEnterLogIn(Login: String) {
        XCTContext.runActivity(named: "When I Enter Login") { _ in
            XCTAssertTrue(eCoffeeScreen.Login.element.exists)
            eCoffeeScreen.Login.element.tap()
            eCoffeeScreen.Login.element.typeText(Login)
        }
    }
    
    func whenIEnterPassword(Password: String) {
        XCTContext.runActivity(named: "When I Enter Password") { _ in
            XCTAssertTrue(eCoffeeScreen.Password.element.exists)
            eCoffeeScreen.Password.element.tap()
            eCoffeeScreen.Password.element.typeText(Password)
        }
    }
    
    func thenUserCanLogIn() {
        XCTContext.runActivity(named: "Then User Can Login") { _ in
            XCTAssertTrue(eCoffeeScreen.SignIn.element.exists)
            eCoffeeScreen.SignIn.element.tap()
            sleep(1)
        }
    }
    
    func whenISelectItem() {
        XCTContext.runActivity(named: "When I Select Item") { _ in
        app.cells.element(boundBy: 1).tap()
        }
    }
    
    func whenIAddItemToBasket() {
        XCTContext.runActivity(named: "When I Add Item To Basket") { _ in
            XCTAssertTrue(eCoffeeScreen.AddToBasket.element.exists)
            eCoffeeScreen.AddToBasket.element.tap()
        }
    }
    
    func thenISeeAddedToBasketConfirmation() {
        XCTContext.runActivity(named: "Then I See Added To Basket Confirmation") { _ in
        app.alerts["Added to  Basket!"].scrollViews.otherElements.buttons["OK"].tap()
        }
    }
    
    func whenIPlaceOrder() {
        XCTContext.runActivity(named: "When I Place Order") { _ in
            XCTAssertTrue(eCoffeeScreen.PlaceOrder.element.exists)
            eCoffeeScreen.PlaceOrder.element.tap()
        }
    }
    
    func whenISelectCreditCardOption() {
        XCTContext.runActivity(named: "When I Select Credit Card Option") { _ in
            XCTAssertTrue(eCoffeeScreen.HowToPay.element.exists)
            eCoffeeScreen.HowToPay.element.tap()
            app.tables/*@START_MENU_TOKEN@*/.switches["Credit Card"]/*[[".cells[\"Credit Card\"].switches[\"Credit Card\"]",".switches[\"Credit Card\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
    }
    
    func whenISelectTipTenPercent() {
        XCTContext.runActivity(named: "When I Select Tip Ten Percent") { _ in
        app.tables/*@START_MENU_TOKEN@*/.buttons["10 %"]/*[[".cells[\"10 %, 10 %, 15 %, 15 %, 20 %, 20 %, 0 %, 0 %\"]",".segmentedControls.buttons[\"10 %\"]",".buttons[\"10 %\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.swipeRight()
        }
    }
    
    func whenIConfirmOrder() {
        XCTContext.runActivity(named: "When I Confirm Order") { _ in
            XCTAssertTrue(eCoffeeScreen.ConfirmOrder.element.exists)
            eCoffeeScreen.ConfirmOrder.element.tap()
        }
    }
    
    func thenISeeOrderConfirmation() {
        XCTContext.runActivity(named: "Then I See Order Confirmation") { _ in
        app.alerts["Order confirmed"].scrollViews.otherElements.buttons["OK"].tap()
        sleep(1)
        }
    }
    
    func thenICanLogOut() {
        XCTContext.runActivity(named: "Then I Can Logout") { _ in
            XCTAssertTrue(eCoffeeScreen.LogOut.element.exists)
            eCoffeeScreen.LogOut.element.tap()
        }
    }
}

