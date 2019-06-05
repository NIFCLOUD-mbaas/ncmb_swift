# SDK開発者向け資料

* 本資料は SDK の開発を円滑にするために SDK 開発者に向けて以下の内容をお伝えするために作成いたしました。
  * SDK の内部構造、 REST API の呼び出し方法
  * テストコードのルールと補助ツール
  * p-r など開発フロー について
* 機能追加、修正される際などに参考としていただけたらと思います。

## ディレクトリ・ファイル構成

```
.github/
NCMB.xcodeproj/
NCMB/ : SDK 本体のコード
  component/ : 共通的に利用されるクラス、構造体などのソースコード
  error/ : エラー列挙型、エラー情報
  fieldtype/ : データストアで使用される特殊なフィールド型・オペレーター
  localfile/ : ローカルファイル操作
  network/ : REST API を処理するためのソースコード
  service/ : 各機能と REST API をつなぐためのソースコード
  user/ : 会員管理機能
  NCMB.h : ヘッダファイル
  NCMB***.swift : SDK 利用者が直接利用する主だったクラス・構造体のソースコード
  NCMB_Info.plist : プロパティリスト
NCMBTests/ : テストコード
  helper/ : 補助ツール
.gitignore
FORDEVELOPER.md : このファイル
LICENSE : ライセンス情報
NCMB.podspec
README.md : Read Me
```

## SDK の内部処理と REST API の関係について

SDK では以下の順序で REST API リクエストを行い、レスポンスを取得している。

例: データストアへの新規保存

```
NCMBObject.save() 

  -> service/NCMBObjectService.save() 
      （service/NCMBRequestServiceProtocol を継承しているため、実体は NCMBRequestServiceProtocol.save() ）
      この中で REST API に送信するリクエストを NCMBRequest の型で生成し、
      これを引数とし NCMBRequestExecutorProtocol を用いて REST API を実行する。
      （テストコードでは、モックを利用したいため、 NCMBRequestExecutorFactory.getInstance() を用いインスタンスを生成する ）

      -> network/NCMBRequestExecutor.exec()
          NCMBRequest を URLRequest に変換し
          NCMBSessionProtocol.dataTask により REST API を実行する。
          （テストコードでは、モックを利用したいため、URLSession を直接利用せず NCMBSessionProtocol を利用する。）

          -> network/NCMBSession.dataTask()
              URLSession を利用し、REST API を実行する。

      -> network/NCMBRequestExecutor.exec()
          NCMBSessionProtocol.dataTask から返されたレスポンス／エラーより NCMBResult<NCMBResponse> を生成

-> 受け取った NCMBResult<NCMBResponse> を オブジェクトに反映し、
   戻り値 NCMBResult<Void> としてREST API リクエストの成功／失敗を返却する
   （オブジェクトへの反映に使用した情報は返却しない）

```

参考: [REST APIリファレンス：オブジェクト登録](https://mbaas.nifcloud.com/doc/current/rest/datastore/objectRegistration.html)

## 同期処理と非同期処理について

SDK 利用者が直接利用するメソッドの中で REST API を利用するものについては同期処理メソッドと非同期処理メソッドの2点を用意する。

### 同期処理

メソッドは `public func メソッド名() -> NCMBResult<リクエスト結果>` の形式とし、
戻り値は REST API リクエストの成功／失敗が完了するかタイムアウトするまでは返さない。
`リクエスト結果` については、REST API のリクエスト結果の成功／失敗や失敗時のエラー内容については `NCMBResult<>` が表現できるため、
SDK 利用者に返すべき情報が無い場合は `Void` とする。

例: `NCMBObject.fetch()` については REST API のレスポンスは NCMBObject インスタンスのフィールド値として格納するため戻り値は `NCMBResult<Void>` としている。

### 非同期処理

メソッドは `public func メソッド名InBackground(callback: @escaping NCMBHandler<リクエスト結果>) -> Void` の形式とし、
REST API リクエストの成功／失敗が完了するかタイムアウトした時点で `callback` を実行する。
`リクエスト結果` については、同期処理と同様。

## SDK 本体のコードについて

* クラス・構造体
  * 新規に実装する場合は、クラスではなく構造体で実装できないかを検討する。
    * メンバを含めた継承、複数インスタンスからの参照などクラスでしか実現できない場合を除く
* アクセスレベル
  * クラス・構造体・列挙型 について直接 SDK 利用者が利用するものでない場合は、アクセスレベルを `internal` にする。
  * メソッドについても同様に直接 SDK 利用者が利用する必要があるのかを吟味し、必要でなければアクセスレベルを `internal` にする。
  * プライベートメソッドについては直接テストを行えないため、アクセスレベルを `internal` にすることができないか検討する。

### NCMBBase

データストアを利用しているクラスは `NCMBBase` を継承している。
このクラスを継承することにより、データストアの持つ各フィールドについて、追加・更新・取得・削除などの操作を行うことができる。

## テストコードについて

* 原則的にすべてのメソッドについてテストコードを作成する。不足している部分についても今後追加を行う。
* バグ修正、新機能開発などの改修時には必ず全パターンのテストを行い、テスト失敗が発生していないことを確認する。
* テストケースは、 `NCMBTestCase` を継承したクラス内に記述する。
  * `NCMBTestCase` を継承することにより、アプリ情報の初期化、ログインユーザーのログアウトなどを自動的に行い、前後のテストケースに依存しないテストが行える。

### テストコード実行方法

* `ncmb_swift/` 直下の `NCMB.xcodeproj` を Xcode にて開く。
* メニュー `[Produce]` → `[Test]` を実行することによりテストコードの実行する。

### テスト補助ツール( NCMBTests/helper/ )について

テストを効率的に行うために、以下の補助ツールを用意している。

* DummyErrors: テストコード内で使用するダミーエラーを表現する列挙型。
* MockLocalFileManager: 端末内に保存するユーザー情報、配信端末情報のアクセスをモックするためのクラス。
* MockRequestExecutor: リクエスト実行クラスのモック。SDK 本体のコードが生成したリクエスト内容の確認や、指定したAPIレスポンスが渡された場合での SDK 本体のコードの振る舞いをテストする際に利用する。
* MockResponseBuilder: テストコード内で疑似的なAPIレスポンスを利用する場合に、その生成を手助けするクラス。
* NCMBTestUtil: テストコードで使用する頻度の高い処理を持つクラス。

### NCMB/service/ 配下のコードに対するテストコード実装について

`NCMB/service/` 配下のコードについては以下の内容をテストコードに含める。

* NCMBRequestExecutorProtocol に渡される `NCMBRequest` の内容の妥当性。
* REST API リクエスト成功／失敗時それぞれについての 戻り値 NCMBResult<NCMBResponse> について内容が欠損していないこと。

例: NCMBObjectService.save() に対する、NCMBTests/NCMBObjectServiceTests の以下の4メソッド

* test_save_request_post()
* test_save_request_put()
* test_save_recieveResponse()
* test_save_invalidRequest()

### NCMB/ 直下のコードに対するテストコード実装について

`NCMB/` 直下のコードについては、以下の内容を同期／非同期メソッドそれぞれテストコードに含める。

* REST API リクエスト成功／失敗時それぞれについての挙動 

例: NCMBObject.save() 、NCMBObject.saveInBackground() に対する、NCMBTests/NCMBObjectTests の以下の3メソッド

* test_save_success_insert()
* test_save_success_update()
* test_save_failure()
* test_saveInBackground_success_insert()
* test_saveInBackground_success_update()
* test_saveInBackground_failure()

## 開発フロー

* バグ修正、新機能開発での開発フローは Github フローを用いる。
* 各開発、改修は develop ブランチ へ向けたプルリクエストにて行う。
* バージョン番号が設定されるリリースにて develop ブランチを再度検証した上で、master ブランチにマージする。


