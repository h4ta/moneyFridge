import SwiftUI

class TransactionsManager: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    var groupedTransactions: [Date: [Transaction]] {
            return Dictionary(grouping: transactions) { transaction in
                return Calendar.current.startOfDay(for: transaction.date)
            }
        }
}

struct ContentView: View {
    @StateObject private var transactionsManager = TransactionsManager()
    
    init() {
        UITabBar.appearance().backgroundColor = .white
    }
    
    var body: some View {
        TabView {
            TransactionListView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("一覧")
                }
            
            AddTransactionView(transactionsManager: transactionsManager)
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("追加")
                }
            
            AddTransactionByCameraView()
                .tabItem {
                    Image(systemName: "camera")
                    Text("レシート撮影")
                }
            
            NowFridgeView()
                .tabItem {
                    Image(systemName: "cabinet.fill")
                    Text("Now冷蔵庫")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
