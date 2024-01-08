import SwiftUI

class ItemManager: ObservableObject {
    @Published var items: [Item] = []

    func addItem(name: String, count: Int, expirationDate: Date?) {
        if let existingIndex = items.firstIndex(where: { $0.name == name }) {
            incrementItemCount(at: existingIndex)
        } else {
            items.append(Item(name: name, count: count, expirationDate: expirationDate))
        }
    }

    func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func removeItem() {
        if !items.isEmpty {
            items.removeLast()
        }
    }

    func editItemName(at index: Int, newName: String) {
        items[index].name = newName
    }

    func incrementItemCount(at index: Int) {
        items[index].count += 1
    }

    func decrementItemCount(at index: Int) {
        if items[index].count > 1 {
            items[index].count -= 1
        } else {
            deleteItem(at: IndexSet([index]))
        }
    }

    func sortByExpirationDate() {
        items.sort { item1, item2 in
            if let date1 = item1.expirationDate, let date2 = item2.expirationDate {
                return date1 < date2
            } else if item1.expirationDate == nil && item2.expirationDate != nil {
                return false
            } else if item1.expirationDate != nil && item2.expirationDate == nil {
                return true
            }
            return false
        }
    }
}

struct NowFridgeView: View {
    @StateObject private var itemManager = ItemManager()
    @State private var newItem = ""
    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var editedItemIndex: Int?
    @State private var selectedQuantity: Int?
    @State private var expirationDate: Date?
    @State private var isDatePickerPresented = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(itemManager.items.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(itemManager.items[index].name)
                                    .onTapGesture {
                                        editedName = itemManager.items[index].name
                                        isEditingName = true
                                        editedItemIndex = index
                                    }
                                Spacer()
                                Text("＋")
                                    .onTapGesture {
                                        self.itemManager.incrementItemCount(at: index)
                                    }
                                Text("\(itemManager.items[index].count)")
                                Text("−")
                                    .onTapGesture {
                                        self.itemManager.decrementItemCount(at: index)
                                    }
                                Menu {
                                    ForEach(1...10, id: \.self) { quantity in
                                        Button(action: {
                                            selectedQuantity = quantity
                                            self.itemManager.items[index].count = quantity
                                        }) {
                                            Text("\(quantity)")
                                        }
                                    }
                                } label: {
                                    Image(systemName: "arrowtriangle.down.circle")
                                }
                                .foregroundColor(.primary)
                            }
                            if let expirationDate = itemManager.items[index].expirationDate {
                                Text("賞味期限: \(dateFormatter.string(from: expirationDate))")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                    .onDelete(perform: itemManager.deleteItem)
                }

                HStack {
                    TextField("新しいアイテムを追加", text: $newItem, onCommit: {
                        // キーボードを閉じる
                        hideKeyboard()
                        self.addItem()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        // キーボードを閉じる
                        hideKeyboard()
                        self.addItem()
                    }) {
                        Text("追加")
                    }
                }
                .padding()

                HStack {
                    Button(action: itemManager.removeItem) {
                        Text("削除")
                    }
                    .disabled(itemManager.items.isEmpty)
                    Spacer()
                }
                .padding()

                HStack {
                    // 賞味期限順に並べ替えるボタン
                    Button(action: {
                        self.itemManager.sortByExpirationDate()
                    }) {
                        Text("賞味期限でソート")
                    }
                }
                .padding()

                // 更新されたDatePicker
                HStack {
                    // 更新されたTextField
                    DatePicker("賞味期限", selection: Binding(
                        get: { expirationDate ?? Date() },
                        set: { expirationDate = $0 }
                    ), displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .padding()
                }

            }
            .navigationTitle("冷蔵庫管理")
            .sheet(isPresented: $isEditingName, content: {
                EditItemNameView(name: $editedName, isEditing: $isEditingName) {
                    if let index = editedItemIndex {
                        itemManager.editItemName(at: index, newName: editedName)
                    }
                }
            })
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }

    private func addItem() {
        self.itemManager.addItem(name: self.newItem, count: selectedQuantity ?? 1, expirationDate: expirationDate)
        self.newItem = ""
        self.selectedQuantity = nil
        self.expirationDate = nil
    }

    private func hideKeyboard() {
        // キーボードを閉じる
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct EditItemNameView: View {
    @Binding var name: String
    @Binding var isEditing: Bool
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("アイテム名")) {
                    TextField("アイテム名", text: $name)
                }
            }
            .navigationBarItems(trailing: Button(action: {
                isEditing = false
                onSave()
            }) {
                Text("保存")
            })
            .navigationBarTitle("アイテム名を編集", displayMode: .inline)
        }
    }
}

struct Item: Identifiable {
    var id = UUID()
    var name: String
    var count: Int
    var expirationDate: Date?
}

