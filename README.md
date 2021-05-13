# ニフクラ mobile backend Swift SDKについて

## 概要

ニフクラ mobile backend Swift SDKは、
モバイルアプリのバックエンド機能を提供するクラウドサービス
[ニフクラ mobile backend](https://mbaas.nifcloud.com)用の Swift SDK です。

- プッシュ通知
- データストア
- 会員管理
- ファイルストア
- SNS連携(Sign In With Apple, Facebookのみ)

といった機能をアプリから利用することが可能です。

このSDKを利用する前に、ニフクラ mobile backendのアカウントを作成する必要があります。

## 動作環境
- Swift version 4.2
- iOS 10.x ～ iOS 14.x
- Xcode 9.x ～ Xcode 12.x
- armv7s, arm64, arm64e アーキテクチャ
- iOS/Xcodeのバージョンに依って対応が必要となる可能性があります。詳細はニフクラ mobile backendのドキュメントをご覧ください。

※ 動作確認バージョン、開発環境につきましては今後、順次拡大する予定です。

## テクニカルサポート窓口対応バージョン

テクニカルサポート窓口では、1年半以内にリリースされたSDKに対してのみサポート対応させていただきます。<br>
定期的なバージョンのアップデートにご協力ください。<br>
※なお、mobile backend にて大規模な改修が行われた際は、1年半以内のSDKであっても対応出来ない場合がございます。<br>
その際は[informationブログ](https://mbaas.nifcloud.com/info/)にてお知らせいたします。予めご了承ください。

- v1.1.0 ~ (※2021年5月時点)

### 現在未実装部分について

以下の機能につきましては現在実装中です。今後順次、提供いたします。

* クエリ
  * 副問い合わせ
  * 位置情報検索
* プッシュ通知
  * 位置情報連動配信
* 会員管理
  * SNS認証(Sign In With Apple, Facebook以外)
  * メールアドレス確認

## ライセンス

このSDKのライセンスについては、LICENSEファイルをご覧ください。

## SDK開発者向け資料

このSDKの開発者向け資料として、FORDEVELOPER.md を用意しております。
SDKの改修をされる際には、ご一読ください。

## 参考URL集

- [ニフクラ mobile backend](https://mbaas.nifcloud.com/)
- [ドキュメント](https://mbaas.nifcloud.com/doc/current/)
- [ユーザーコミュニティ](https://github.com/NIFCLOUD-mbaas/UserCommunity)

## サンプル

### 初期化

```swift
    NCMB.initialize(
        applicationKey: /* アプリケーションキー */,
        clientKey: /* クライアントキー */)
```

### データストア

#### オブジェクトをデータストアに保存する

```swift
    // testクラスのNCMBObjectを作成
    let object : NCMBObject = NCMBObject(className: "test")

    // オブジェクトに値を設定
    object["fieldA"] = "Hello, NCMB!"
    object["fieldB"] = "日本語の内容"
    object["fieldC"] = 42
    object["fieldD"] = ["abcd", "efgh", "ijkl"]

    // データストアへの登録を実施
    object.saveInBackground(callback: { result in
        switch result {
            case .success:
                // 保存に成功した場合の処理
                print("保存に成功しました")
            case let .failure(error):
                // 保存に失敗した場合の処理
                print("保存に失敗しました: \(error)")
        }
    })
```

#### オブジェクトの取得

```swift
    // testクラスへのNCMBObjectを設定
    let object : NCMBObject = NCMBObject(className: "test")

    // objectIdプロパティを設定
    object.objectId = "Mz6xym6wNi63lxb8"

    object.fetchInBackground(callback: { result in
        switch result {
            case .success:
                // 取得に成功した場合の処理
                print("取得に成功しました")
                if let fieldB : String = object["fieldB"] {
                    print("fieldB value: \(fieldB)")
                }
            case let .failure(error):
                // 取得に失敗した場合の処理
                print("取得に失敗しました: \(error)")
        }
    })
```

#### オブジェクトの更新

保存済み（または、objectIdを持っている）のオブジェクトに新しい値をセットして `saveInBackground` メソッドを実行することでデータストアの値が更新されます。

#### データストアに対しての操作を設定する

```swift
    // testクラスのNCMBObjectを作成
    let object : NCMBObject = NCMBObject(className: "test")

    // objectIdプロパティを設定
    object.objectId = "Mz6xym6wNi63lxb8"

    // 指定したフィールドの値をインクリメントする（すでに該当フィールドに値が存在する場合にのみ更新可能）
    object["fieldC"] = NCMBIncrementOperator(amount: 1)
    // 指定したフィールドの配列内で重複しなければ追加する
    object["fieldD"] = NCMBAddUniqueOperator(elements: ["food", "fish"])

    // データストアへの更新を実施
    object.saveInBackground(callback: { result in
        switch result {
            case .success:
                // 更新に成功した場合の処理
                print("更新に成功しました")
            case let .failure(error):
                // 更新に失敗した場合の処理
                print("更新に失敗しました: \(error)")
        }
    })
```

#### オブジェクトの削除

```swift
    // testクラスのNCMBObjectを作成
    let object : NCMBObject = NCMBObject(className: "test")

    // objectIdプロパティを設定
    object.objectId = "Mz6xym6wNi63lxb8"

    // データストアから削除
    object.deleteInBackground(callback: { result in
        switch result {
            case .success:
                print("削除に成功しました")
            case let .failure(error):
                print("削除に失敗しました: \(error)")
        }
    })
```

#### オブジェクトの関連付け

* TBD

#### リレーション

ポインタは1つのオブジェクトへの参照しか持つことができませんが、
リレーションを利用することで、特定クラスの複数オブジェクトと関連づけることが可能です。
リレーションを追加・削除する場合は、それぞれ `NCMBAddRelationOperator` と `NCMBRemoveRelationOperator` という構造体を使用します。
リレーションの取得には `NCMBRelation` を使用します。

##### リレーションの新規作成

```swift
// testクラスへのNCMBObjectを設定
let object : NCMBObject = NCMBObject(className: "test")
let pointerA = NCMBPointer(className: "test", objectId: "84lywBlhwuA8SeUo")
let pointerB = NCMBPointer(className: "test", objectId: "SqG3oH0tgXx50hT7")

object["NewRelation"] = NCMBAddRelationOperator(elements: [pointerA, pointerB])

// データストアへの登録を実施
object.saveInBackground(callback: { result in
    switch result {
    case .success:
        // 保存に成功した場合の処理
        print("保存に成功しました")
    case let .failure(error):
        // 保存に失敗した場合の処理
        print("保存に失敗しました: \(error)")
    }
})
```

##### リレーションの追加

```swift
// testクラスへのNCMBObjectを設定
let object : NCMBObject = NCMBObject(className: "test")
let pointerC = NCMBPointer(className: "test", objectId: "2tEvocmtRTllMgQT")

// objectIdプロパティを設定
object.objectId = "ATfLxBq683MF3zy9"

object["NewRelation"] = NCMBAddRelationOperator(elements: [PointerC])

// データストアへの登録を実施
object.saveInBackground(callback: { result in
    switch result {
    case .success:
        // 保存に成功した場合の処理
        print("保存に成功しました")
    case let .failure(error):
        // 保存に失敗した場合の処理
        print("保存に失敗しました: \(error)")
    }
})
```
##### リレーションの削除

```swift
// testクラスへのNCMBObjectを設定
let object : NCMBObject = NCMBObject(className: "test")
let pointerC = NCMBPointer(className: "test", objectId: "2tEvocmtRTllMgQT")

// objectIdプロパティを設定
object.objectId = "ATfLxBq683MF3zy9"

object["NewRelation"] = NCMBRemoveRelationOperator(elements: [PointerC])

// データストアへの登録を実施
object.saveInBackground(callback: { result in
    switch result {
    case .success:
        // 保存に成功した場合の処理
        print("保存に成功しました")
    case let .failure(error):
        // 保存に失敗した場合の処理
        print("保存に失敗しました: \(error)")
    }
})
```

##### リレーションの取得

```swift
// testクラスへのNCMBObjectを設定
let object : NCMBObject = NCMBObject(className: "test")

// objectIdプロパティを設定
object.objectId = "ATfLxBq683MF3zy9"

object.fetchInBackground(callback: { result in
    switch result {
    case .success:
        // 取得に成功した場合の処理
        print("取得に成功しました")
        if let relation : NCMBRelation = object["NewRelation"] {
            print("relation value: \(relation)")
        }
    case let .failure(error):
        // 取得に失敗した場合の処理
        print("取得に失敗しました: \(error)")
    }
})
```
#### オブジェクトの検索を行う

```swift
    // クエリの作成
    var query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className: "test")
    // フィールドの値が 42 と一致
    query.where(field: "fieldC", equalTo: 42)

    // 検索を行う
    query.findInBackground(callback: { result in
        switch result {
            case let .success(array):
                print("取得に成功しました 件数: \(array.count)")
            case let .failure(error):
                print("取得に失敗しました: \(error)")
        }
    })
```

#### 標準クラスを検索する場合

```swift
    // 会員管理
    let userQuery : NCMBQuery<NCMBUser> = NCMBUser.query

    // ロール
    let roleQuery : NCMBQuery<NCMBRole> = NCMBRole.query

    // ファイルストレージ
    let fileQuery : NCMBQuery<NCMBFile> = NCMBFile.query

    // 配信端末
    let installationQuery : NCMBQuery<NCMBInstallation> = NCMBInstallation.query

    // プッシュ通知
    let pushQuery : NCMBQuery<NCMBPush> = NCMBPush.query
```

#### クエリの合成

and検索

```swift
    // クエリの作成
    var query = NCMBQuery.getQuery(className: "test")
    query.where(field: "fieldA", equalTo: "Hello, NCMB!")
    query.where(field: "fieldC", greaterThanOrEqualTo: 40)

    // 検索を行う
    query.findInBackground(callback: { result in
        switch result {
            case let .success(array):
                print("取得に成功しました 件数: \(array.count)")
            case let .failure(error):
                print("取得に失敗しました: \(error)")
        }
    })
```

or検索

```swift
    // 一つ目のクエリの作成
    var query1 = NCMBQuery.getQuery(className: "test")
    query1.where(field: "fieldB", equalTo: "日本語の内容")

    // 二つ目のクエリの作成
    var query2 = NCMBQuery.getQuery(className: "test")
    query2.where(field: "fieldC", lessThan: 50)

    // OR検索を行うためにクエリを合成する
    let query = NCMBQuery.orQuery(query1, query2)

    // 検索を行う
    query.findInBackground(callback: { result in
        switch result {
            case let .success(array):
                print("取得に成功しました 件数: \(array.count)")
            case let .failure(error):
                print("取得に失敗しました: \(error)")
        }
    })
```

### プッシュ通知

#### 配信端末情報の登録

`AppDelegate.swift` 内に記述

```swift
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        // 配信端末インスタンスの作成
        let installation : NCMBInstallation = NCMBInstallation.currentInstallation

        // デバイストークンの設定
        installation.setDeviceTokenFromData(data: deviceToken)

        // 配信端末の登録
        installation.saveInBackground(callback: { result in
            switch result {
                case .success:
                    print("保存に成功しました")
                case let .failure(error):
                    print("保存に失敗しました: \(error)")
                    return;
            }
        })
    }
```

#### プッシュ通知をアプリから送信する

```swift
    // プッシュ通知オブジェクトの作成
    let push : NCMBPush = NCMBPush()
    // メッセージの設定
    push.message = "プッシュ通知です"
    // iOS端末を送信対象に設定する
    push.isSendToIOS = true
    // android端末を送信対象に設定する
    push.isSendToAndroid = true
    // 即時配信を設定する
    push.setImmediateDelivery()

    // プッシュ通知を配信登録する
    push.sendInBackground(callback: { result in
        switch result {
            case .success:
                print("登録に成功しました。プッシュID: \(push.objectId!)")
            case let .failure(error):
                print("登録に失敗しました: \(error)")
                return;
        }
    })
```

#### プッシュ通知のスケジューリング

```swift
    // プッシュ通知オブジェクトの作成
    let push : NCMBPush = NCMBPush()
    // メッセージの設定
    push.message = "プッシュ通知です"
    // iOS端末を送信対象に設定する
    push.isSendToIOS = true
    // android端末を送信対象に設定する
    push.isSendToAndroid = true
    // 配信時刻を設定する
    let formatter : DateFormatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    push.deliveryTime = formatter.date(from: "2020-07-24T10:10:01.964Z")

    // プッシュ通知を配信登録する
    push.sendInBackground(callback: { result in
        switch result {
            case .success:
                print("登録に成功しました。プッシュID: \(push.objectId!)")
            case let .failure(error):
                print("登録に失敗しました: \(error)")
                return;
        }
    })
```

#### 配信端末の絞り込み

```Swift
   // プッシュ通知オブジェクトの作成
   let push : NCMBPush = NCMBPush()
   // メッセージの設定
   push.message = "プッシュ通知です"
   push.action = "ReceiveActivity"
   push.title = "testPush"
   // android端末を送信対象に設定する
   push.isSendToAndroid = true
   // 即時配信を設定する
   push.setImmediateDelivery()

   var query : NCMBQuery<NCMBInstallation> = NCMBInstallation.query
   //installationクラス（端末情報）に独自フィールドtakanokunに持っている値が ["d", "e", "f"] 配列に入っているデータを検索する条件を設定
   var searchStringsArray: [String] = ["d", "e", "f"]
   query.where(field: "takanokun", containedIn:  searchStringsArray)
   push.searchCondition = query

   push.sendInBackground(callback: { result in
       switch result {
       case .success:
           print("登録に成功しました。プッシュID: \(push.objectId!)")
       case let .failure(error):
           print("登録に失敗しました: \(error)")
           return;
       }
   })
```

### 会員管理

#### ユーザーの新規登録

```swift
    //　Userインスタンスの生成
    let user = NCMBUser()

    // ユーザー名・パスワードを設定
    user.userName = "takanokun"
    user.password = "openGoma"

    // ユーザーの新規登録
    user.signUpInBackground(callback: { result in
        switch result {
            case .success:
                // 新規登録に成功した場合の処理
                print("新規登録に成功しました")
            case let .failure(error):
                // 新規登録に失敗した場合の処理
                print("新規登録に失敗しました: \(error)")
        }
    })
```

#### 会員登録用のメールを要求する

```swift
    // 会員登録用メールを要求する
    let result = NCMBUser.requestAuthenticationMailInBackground(mailAddress: "takanokun@example.com", callback: { result in
        switch result {
            case .success:
                // 会員登録用メールの要求に成功した場合の処理
                print("会員登録用メールの要求に成功しました")
            case let .failure(error):
                // 会員登録用のメール要求に失敗した場合の処理
                print("会員登録用メールの要求に失敗しました: \(error)")
        }
    })
```

#### ログイン

ユーザー名、パスワードでのログイン

```swift
    // ログイン状況の確認
    if let user = NCMBUser.currentUser {
        print("ログインしています。ユーザー: \(user.userName!)")
    } else {
        print("ログインしていません")
    }

    // ログイン
    NCMBUser.logInInBackground(userName: "takanokun", password: "openGoma", callback: { result in
        switch result {
            case .success:
                // ログインに成功した場合の処理
                print("ログインに成功しました")

                // ログイン状況の確認
                if let user = NCMBUser.currentUser {
                    print("ログインしています。ユーザー: \(user.userName!)")
                } else {
                    print("ログインしていません")
                }

            case let .failure(error):
                // ログインに失敗した場合の処理
                print("ログインに失敗しました: \(error)")
        }
    })
```

メールアドレス、パスワードでのログイン

```swift
    // ログイン状況の確認
    if let user = NCMBUser.currentUser {
        print("ログインしています。ユーザー: \(user.userName!)")
    } else {
        print("ログインしていません")
    }

    // ログイン
    NCMBUser.logInInBackground(mailAddress: "takanokun@example.com", password: "openGoma", callback: { result in
        switch result {
            case .success:
                // ログインに成功した場合の処理
                print("ログインに成功しました")

                // ログイン状況の確認
                if let user = NCMBUser.currentUser {
                    print("ログインしています。ユーザー: \(user.userName!)")
                } else {
                    print("ログインしていません")
                }

            case let .failure(error):
                // ログインに失敗した場合の処理
                print("ログインに失敗しました: \(error)")
        }
    })
```

#### ログアウト

```swift
    // ログイン状況の確認
    if let user = NCMBUser.currentUser {
        print("ログインしています。ユーザー: \(user.userName!)")
    } else {
        print("ログインしていません")
    }

    // ログアウト
    NCMBUser.logOutInBackground(callback: { result in
        switch result {
            case .success:
                // ログアウトに成功した場合の処理
                print("ログアウトに成功しました")

                // ログイン状況の確認
                if let user = NCMBUser.currentUser {
                    print("ログインしています。ユーザー: \(user.userName!)")
                } else {
                    print("ログインしていません")
                }

            case let .failure(error):
                // ログアウトに失敗した場合の処理
                print("ログアウトに失敗しました: \(error)")
        }
    })
```

#### パスワードのリセット

```swift
    // パスワードのリセット
    NCMBUser.requestPasswordResetInBackground(mailAddress: "takanokun@example.com", callback: { result in
        switch result {
            case .success:
                // パスワードのリセット処理登録に成功した場合の処理
                print("パスワードのリセット処理登録に成功しました")
            case let .failure(error):
                // パスワードのリセット処理登録に失敗した場合の処理
                print("パスワードのリセット処理登録に失敗しました: \(error)")
        }
    })
```

#### メールアドレス確認の有無

* TBD


#### 匿名認証

```swift
    // ログイン状況の確認
    if let user = NCMBUser.currentUser {
        print("ログインしています。ユーザー: \(user.userName!)")
    } else {
        print("ログインしていません")
    }

    // 匿名ユーザの自動生成を有効化
    NCMBUser.enableAutomaticUser()

    // 匿名ユーザーでのログイン
    let result = NCMBUser.automaticCurrentUserInBackground(callback: { result in
        switch result {
            case .success:
                // ログインに成功した場合の処理
                print("ログインに成功しました")

                // ログイン状況の確認
                if let user = NCMBUser.currentUser {
                    print("ログインしています。ユーザー: \(user.userName!)")

                    // 匿名ユーザーでログインしているかの確認
                    if NCMBAnonymousUtils.isLinked(user: user) {
                        print("匿名ユーザーです。")
                    } else {
                        print("匿名ユーザーではありません。")
                    }

                } else {
                    print("ログインしていません")
                }

            case let .failure(error):
                // ログインに失敗した場合の処理
                print("ログインに失敗しました: \(error)")
        }
    })
```

#### 会員のグルーピング

##### ロールの作成

```swift
// ロールの作成
let freePlanRole : NCMBRole = NCMBRole.init(roleName: "freePlan");
freePlanRole.save();
let proPlanRole : NCMBRole = NCMBRole.init(roleName: "proPlan");
proPlanRole.save();
```

##### 会員をロールに追加する

```swift
// ユーザーを作成
let user: NCMBUser = NCMBUser.init();
user.userName = "expertUser"
user.password = "pass"
user.signUp()
// 登録済みユーザーを新規ロールに追加
let role : NCMBRole = NCMBRole.init(roleName: "expertPlan");
role.addUserInBackground(user: user, callback: { result in
   switch result {
   case .success:
         print("保存に成功しました")
   case let .failure(error):
         print("保存に失敗しました: \(error)")
         return;
   }
})
```

### ファイルストア

#### ファイルストアへのアップロード

```swift
    // アップロード対象のデータ
    let data : Data

    // ファイルオブジェクトの作成
    let file : NCMBFile = NCMBFile(fileName: "Takanokun.txt")

    // アップロード
    file.saveInBackground(data: data, callback: { result in
        switch result {
            case .success:
                print("保存に成功しました")
            case let .failure(error):
                print("保存に失敗しました: \(error)")
                return;
        }
    })
```

#### ファイルを取得する

```swift
    // ファイルオブジェクトの作成
    let file : NCMBFile = NCMBFile(fileName: "Takanokun.txt")

    // ファイルの取得
    file.fetchInBackground(callback: { result in
        switch result {
            case let .success(data):
                print("取得に成功しました: \(data)")
            case let .failure(error):
                print("取得に失敗しました: \(error)")
                return;
        }
    })
```


#### ファイルの削除

```swift
    // ファイルオブジェクトの作成
    let file : NCMBFile = NCMBFile(fileName: "Takanokun.txt")

    // ファイルの削除
    file.deleteInBackground(callback: { result in
        switch result {
            case .success:
                print("削除に成功しました")
            case let .failure(error):
                print("削除に失敗しました: \(error)")
                return;
        }
    })
```

### スクリプト

#### スクリプト実行

```swift
    // スクリプトインスタンスの作成
    let script = NCMBScript(name: "myCoolScript.js", method: .get)

    // スクリプトの実行
    script.executeInBackground(headers: [:], queries: ["name": "foo"], body: [:], callback: { result in
        switch result {
            case let .success(data):
                print("scriptSample 実行に成功しました: \(data)")
            case let .failure(error):
                print("scriptSample 実行に失敗しました: \(error)")
                return;
        }
    })
```
