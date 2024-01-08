# moneyFridgeとは
1. 支出、収入の履歴を管理できる
2. 購入情報をレシートから読み取り保存できる
3. 冷蔵庫内の食品状況を確認できる

以上の機能を有した家計簿iOSアプリです。

モダンな言語の学習のため、自分が今最も必要なもの(簡単に支出管理などができるアプリ)を自分で作成したい、といった目的のもと作成しました。

## 開発環境
Xcodeのバージョン : 15.0.1<br>
Swiftのバージョン : 5.9

言語はSwift, UIはSwiftUI, DBはRealmを利用しています。

## 各画面について
本アプリでは大きく分けて以下の画面を用意しています。

1. 支出、収入の閲覧画面
2. 支出、収入の追加画面
3. レシート撮影画面
4. 冷蔵庫内の商品の管理画面

### 1. 支出、収入の閲覧画面
この画面では日毎での購入履歴を閲覧することができます。<br>
<img src="https://github.com/h4ta/moneyFridge/assets/141723500/81dcf8b4-1d2a-4f20-89d6-ca3c8fd83a04" width="25%"><br>
右上の+ボタンをタップすると追加画面に遷移できます。

<br>
その店の欄をタップすると、同日にその店で購入した商品を確認することができます。<br>
<img src="https://github.com/h4ta/moneyFridge/assets/141723500/9369bc33-5dc3-4ac9-8e5d-b17eb1fb2dd1" width="25%">

<br>
さらに商品をタップすると、その商品の情報を修正することができます。<br>
<img src="https://github.com/h4ta/moneyFridge/assets/141723500/2db40f3c-982f-4a58-b7ed-e83af7f7757d" width="25%">

### 2. 支出、収入の追加画面
ここでは支出、収入を追加することができます。<br>
まず店の名前を入力します。<br>
<img src="https://github.com/h4ta/moneyFridge/assets/141723500/477ce96c-09fb-4ba7-bc80-43b84f7825db" width="25%">

<br>
次の画面で商品名、価格を入力します。<br>
保存をタップすると、商品情報がRealmDBに保存されます。<br>
<img src="https://github.com/h4ta/moneyFridge/assets/141723500/6ce51b60-fa81-423e-8075-d1bc13262106" width="25%">

### 3. レシート撮影画面
この画面ではレシートを撮影した後、店名、日付、商品名、金額を取得しDBに追加します。(実装中)<br>
テキスト検出にはiOSのvisionフレームワークを利用しています。

まず、以下の様にレシートを撮影します。<br>
<img src="https://github.com/h4ta/moneyFridge/assets/141723500/04c1586c-fccb-45a8-ab23-545af9057124" width="25%">

<br>
(現在はこれらを処理する箇所の実装が完了していません。今のところ以下の様に文字のみを取得しています。)<br>
<img src="https://github.com/h4ta/moneyFridge/assets/141723500/dedaf6f1-904d-472c-9091-6daa14cb9d66" width="25%">

### 4. 冷蔵庫管理画面
この画面では冷蔵庫の中にある商品の名前、個数、賞味期限を確認できます。"賞味期限でソート"をタップすることで賞味期限が今から近い商品順にソートすることができます。<br>
<img src="https://github.com/h4ta/moneyFridge/assets/141723500/be5ba975-7933-465c-a3af-6bd1c211afb9" width="25%"><br>

<br>
商品欄の右側の-ボタン、+ボタンで商品の個数を一つづつ増減させることができます。また、その右のマークをタップすることで1~10の個数に一気に変更することができます。<br>
<img src="https://github.com/h4ta/moneyFridge/assets/141723500/55158af6-8bb5-451f-94c6-3c9c5a6696d8" width="25%"><br>

<br>
(RealmDBへ登録する箇所の実装は未完了です。購入履歴などのDBとは別に管理する予定です。)