import Foundation
import Firebase

class OrderBasket: Identifiable {
    
    var id: String!
    var ownerId: String!
    var items: [Drink] = []
    
    var total: Double {
        if items.count > 0 {
            return items.reduce(0) { $0 + $1.price }
        } else {
            return 0.0
        }
    }
    
    func add(_ item: Drink) {
        items.append(item)
    }
    
    func remove(_ item: Drink) {
        
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }
    }
    
    func emptyBasket() {
        self.items = []
        saveBasketToFirestore()
    }
    
    func saveBasketToFirestore() {
        
        FirebaseReference(collectionReference:.Basket).document(self.id).setData(basketDictionaryFrom(self))
    }
    
}


func basketDictionaryFrom(_ basket: OrderBasket) -> [String : Any] {
    
    var allDrinkIds: [String] = []

    for drink in basket.items {
        allDrinkIds.append(drink.id)
    }

    return NSDictionary(objects: [basket.id,
                                  basket.ownerId,
                                  allDrinkIds
                                ],
                    forKeys: [kID as NSCopying,
                     kOWNERID as NSCopying,
                     kDRINKIDS as NSCopying
    ]) as! [String : Any]

}
