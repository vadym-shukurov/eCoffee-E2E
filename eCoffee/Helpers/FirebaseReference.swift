import Foundation
import FirebaseFirestore


//There are going to be the data base in fire base
 
enum FCollectioReference : String{
    
    case User
    case Menu
    case Order
    case Basket
}

func FirebaseReference(collectionReference: FCollectioReference) ->
    CollectionReference{
    
    return Firestore.firestore().collection(collectionReference.rawValue)
}

