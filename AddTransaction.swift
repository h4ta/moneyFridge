import SwiftUI
import RealmSwift

struct AddTransactionView: View {
    @State private var shop = ""
    @ObservedObject var transactionsManager: TransactionsManager

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("新しい支出")) {
                    TextField("店の名前", text: $shop)
                }
                Section {
                    NavigationLink(destination: AddItemView(shop: $shop, transactionsManager: transactionsManager)) {
                        Text("次へ")
                    }
                }
            }
            .navigationTitle("支出を追加")
        }
    }
}

struct AddItemView: View {
    @Binding var shop: String
    @ObservedObject var transactionsManager: TransactionsManager
    @State private var title = ""
    @State private var amount = ""
    @FocusState private var isKeyBoardActive: Bool
    @State private var showMessage = false

    var body: some View {
        Form {
            Section(header: Text("新しい支出")) {
                TextField("商品の名称", text: $title)
                TextField("金額", text: $amount)
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
                    saveTransaction()
                }
                .alert(isPresented: $showMessage) {
                    Alert(title: Text("追加しました"), dismissButton: .default(Text("OK")))
                }
            }
        }
        .navigationTitle("\(shop)での支出を追加")
    }

    func saveTransaction() {
        guard let amount = Int(amount), !title.isEmpty else { return }

        let newTransaction = Transaction()
        newTransaction.shop = shop
        newTransaction.title = title
        newTransaction.amount = amount
        let realm = try! Realm()

        do {
            try realm.write {
                realm.add(newTransaction)
            }
        } catch {
            print("Error saving transaction: \(error)")
        }

        // 保存後に入力欄をクリア
        self.title = ""
        self.amount = ""
        isKeyBoardActive = false

        showMessage = true
    }
}
