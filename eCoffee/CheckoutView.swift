import SwiftUI

struct CheckoutView: View {
    
    @ObservedObject var basketListener = BasketListener()
    
    static let paymentTypes = ["Cash", "Credit Card"]
    static let tipAmounts = [10, 15, 20, 0]
    
    @State private var paymentType = 0
    @State private var tipAmount = 1
    @State private var showingPaymentAlert = false
    
    var totalPrice: Double {
        let total = basketListener.orderBasket.total
        let tipValue = total / 100 * Double(Self.tipAmounts[tipAmount])
        return total + tipValue
    }
    
    
    var body: some View {

        Form {
            Section {
                Picker(selection: $paymentType, label: Text("How do you want  to pay?")) {
                    
                    ForEach(0 ..< Self.paymentTypes.count) {
                        Text(Self.paymentTypes[$0])
                    }
                }
                .accessibilityLabel("HowToPay")
            }//End of Section
            
            
            Section (header: Text("Add a tip?")) {
                
                Picker(selection: $tipAmount, label: Text("Percentage: ")) {
                    
                    ForEach(0 ..< Self.tipAmounts.count) {
                        Text("\(Self.tipAmounts[$0]) %")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }//End of Section
            
            Section(header: Text("Total: $\(totalPrice, specifier: "%.2f")").font(.largeTitle)) {
                
                Button(action: {
                    self.showingPaymentAlert.toggle()
                    self.createOrder()
                    self.emptyBasket()
                    
                }) {
                    Text("Confirm Order")
                }
                .accessibilityLabel("ConfirmOrder")
            }.disabled(self.basketListener.orderBasket?.items.isEmpty ?? true)
            //End of Section
            
        }//End of form
        .navigationBarTitle(Text("Payment"), displayMode: .inline)
        .alert(isPresented: $showingPaymentAlert) {
                
            Alert(title: Text("Order confirmed"), message: Text("Thank You!"), dismissButton: .default(Text("OK")))
        }
    }
    
    
    private func createOrder() {
        let order = Order()
        order.amount = totalPrice
        order.id = UUID().uuidString
        order.customerId = FUser.currentId()
        order.orderItems = self.basketListener.orderBasket.items
        order.saveOrderToFirestore()
    }
    
    
    private func emptyBasket() {
        self.basketListener.orderBasket.emptyBasket()
    }
    
    
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}

