import SwiftUI
import RealmSwift

class Transaction: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var category: String = ""
    @Persisted var date: Date = Date()
    @Persisted var memo: String?
    @Persisted var amount: Int = 0
    @Persisted var shop: String = ""
}

private func formattedDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter.string(from: date)
}

private func groupTransactionsByShop(transactions: [Transaction]) -> [String: [Transaction]] {
    return Dictionary(grouping: transactions, by: { $0.shop })
}

//日にちをsessionTitleとし、その日ごとで購入した店を表示
struct TransactionListView: View {
    @StateObject private var transactionsManager = TransactionsManager()

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(transactionsManager.groupedTransactions), id: \.key) { (date, transactions) in
                    Section(header: Text(formattedDate(date: date))) {
                        ForEach(Array(groupTransactionsByShop(transactions: transactions).keys), id: \.self) { shop in
                            let shopTransactions = groupTransactionsByShop(transactions: transactions)[shop] ?? []
                            NavigationLink(destination: TransactionShopDetailView(transactions: shopTransactions)) {
                                TransactionShopView(shop: shop, transactions: shopTransactions)
                            }
                        }
                    }
                }
            }
            .navigationTitle("収支一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddTransactionView(transactionsManager: transactionsManager)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            // Realmからトランザクションデータを読み込む
            let realm = try! Realm()
            let transactionObjects = realm.objects(Transaction.self)
            transactionsManager.transactions = Array(transactionObjects)
        }
    }
}

//店名とその店での合計購入金額を表示する
struct TransactionShopView: View {
    var shop: String
    var transactions: [Transaction]
    
    private var totalAmount: Int {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
            HStack {
                Text(shop)
                    .font(.headline)
                    .padding(.vertical, 5)
                
                Spacer()

                Text("合計購入金額: \(totalAmount)")
                    .foregroundColor(.yellow)
            }
    }
}

//同じ店で購入した商品をリストで表示する画面
struct TransactionShopDetailView: View {
    var transactions: [Transaction]

    var body: some View {
        let shopName = transactions.first?.shop ?? "Unknown Shop"
        List {
            ForEach(transactions, id: \.self) { transaction in
                NavigationLink(destination: EditItemView(transaction: transaction)) {
                    TransactionDetailRowView(transaction: transaction)
                }
            }
        }
        .navigationTitle("\(shopName)の購入履歴").navigationBarTitleDisplayMode(.inline)
    }
}

//一つの商品の名前、金額を表示する
struct TransactionDetailRowView: View {
    var transaction: Transaction

    var body: some View {
        HStack {
            Text(transaction.title)
                .font(.headline)
            Spacer()
            Text(transaction.amount.description)
                .foregroundColor(transaction.amount >= 0 ? .green : .red)
        }
        .padding()
    }
}

//商品の情報を修正する画面
struct EditItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var editedTitle: String
    @State private var editedAmount: String
    @FocusState private var isKeyBoardActive: Bool
    @State private var showMessage = false
    
    @StateObject private var transactionsManager = TransactionsManager()
    var transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
        _editedTitle = State(initialValue: transaction.title)
        _editedAmount = State(initialValue: String(transaction.amount))
    }
    
    var body: some View {
        Form {
            Section(header: Text("商品情報を修正")) {
                TextField("商品名", text: $editedTitle)
                TextField("金額", text: $editedAmount)
                    .keyboardType(.numberPad)
                    .focused($isKeyBoardActive)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("閉じる") {
                                isKeyBoardActive = false
                            }
                        }
                    }
            }
            
            Section {
                Button("保存") {
                    saveChanges()
                    //保存後、初めの画面(TransactionListView)に戻る
                    
                }
                .alert(isPresented: $showMessage) {
                    Alert(title: Text("修正しました"), dismissButton: .default(Text("OK")))
                }
//                .onChange(of: transactionsManager.transactions) { _ in
//                    presentationMode.wrappedValue.dismiss()
//                }
            }
        }
        .navigationTitle("商品情報を修正")
    }
        
    func saveChanges() {
        guard let editedAmount = Int(editedAmount) else {
            // 金額が無効な場合のエラーハンドリング
            return
        }
            
        let realm = try! Realm()
            
        do {
            try realm.write {
                transaction.title = editedTitle
                transaction.amount = editedAmount
            }
            
//            transactionsManager.transactions = realm.objects(Transaction.self)
        } catch {
            // トランザクションの保存エラーのハンドリング
            print("Error saving transaction: \(error)")
        }
        
        isKeyBoardActive = false
        showMessage = true
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView()
    }
}
