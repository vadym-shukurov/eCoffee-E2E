import Foundation
import XCTest

class BDDTest: eCoffeeUITestsBase

{
    func test01_UserLogIn() {
        givenAppIsReady()
        whenIOpenBasket()
        whenIEnterLogIn(Login: "gupta.akki23@gmail.com")
        whenIEnterPassword(Password: "Otrium1234")
        thenUserCanLogIn()
    }
    
    func test02_AddItemToBasket() {
        givenAppIsReady()
        whenISelectItem()
        whenIAddItemToBasket()
        thenISeeAddedToBasketConfirmation()
    }
    
    func test03_CompleteOrder() {
        givenAppIsReady()
        whenIOpenBasket()
        whenIPlaceOrder()
        whenISelectCreditCardOption()
        whenISelectTipTenPercent()
        whenIConfirmOrder()
        thenISeeOrderConfirmation()
    }
    
    func test04_UserLogOut() {
        givenAppIsReady()
        thenICanLogOut()
    }
}
