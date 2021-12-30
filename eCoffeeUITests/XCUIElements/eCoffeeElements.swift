import Foundation
import XCTest

enum eCoffeeScreen: String {
 case iCoffee = "iCoffee"
 case Basket = "Basket"
 case Login = "EnterEmail"
 case Password = "Password"
 case SignIn = "Sign"
 case AddToBasket = "AddToBasket"
 case PlaceOrder = "PlaceOrder"
 case HowToPay = "HowToPay"
 case ConfirmOrder = "ConfirmOrder"
 case LogOut = "LogOut"
    
    var element: XCUIElement {
            
            switch self {
            case .iCoffee:
                return XCUIApplication().staticTexts[self.rawValue]
            case .Basket:
                return XCUIApplication().buttons[self.rawValue]
            case .Login:
                return XCUIApplication().textFields[self.rawValue]
            case .Password:
                return XCUIApplication().secureTextFields[self.rawValue]
            case .SignIn:
                return XCUIApplication().buttons[self.rawValue]
            case .AddToBasket:
                return XCUIApplication().buttons[self.rawValue]
            case .PlaceOrder:
                return XCUIApplication().buttons[self.rawValue]
            case .HowToPay:
                return XCUIApplication().tables.buttons[self.rawValue]
            case .ConfirmOrder:
                return XCUIApplication().buttons[self.rawValue]
            case .LogOut:
                return XCUIApplication().buttons[self.rawValue]
                
            }
        }
    
}
