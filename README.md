# ニフクラ mobile backend Swift SDKについて

## 概要

ニフクラ mobile backend Swift SDKは、
モバイルアプリのバックエンド機能を提供するクラウドサービス
[ニフクラ mobile backend](https://mbaas.nifcloud.com)用の Swift SDK です。

- プッシュ通知
- データストア
- 会員管理
- ファイルストア
- SNS連携(Sign In With Apple, Facebook, Twitterのみ)

といった機能をアプリから利用することが可能です。

このSDKを利用する前に、ニフクラ mobile backendのアカウントを作成する必要があります。

## 動作環境
- Swift version 4.2
- iOS 10.x ～ iOS 15.x
- Xcode 9.x ～ Xcode 13.x
- armv7s, arm64, arm64e アーキテクチャ
- iOS/Xcodeのバージョンに依って対応が必要となる可能性があります。詳細はニフクラ mobile backendのドキュメントをご覧ください。

※ 動作確認バージョン、開発環境につきましては今後、順次拡大する予定です。

## テクニカルサポート窓口対応バージョン

テクニカルサポート窓口では、1年半以内にリリースされたSDKに対してのみサポート対応させていただきます。<br>
定期的なバージョンのアップデートにご協力ください。<br>
※なお、mobile backend にて大規模な改修が行われた際は、1年半以内のSDKであっても対応出来ない場合がございます。<br>
その際は[informationブログ](https://mbaas.nifcloud.com/info/)にてお知らせいたします。予めご了承ください。

- v1.1.2 ~ (※2022年2月時点)

### 現在未実装部分について

以下の機能につきましては現在実装中です。今後順次、提供いたします。

* クエリ
  * 副問い合わせ
  * 位置情報検索
* プッシュ通知
  * 位置情報連動配信
* 会員管理
  * SNS認証(Google認証)
  * メールアドレス確認

## ライセンス

このSDKのライセンスについては、LICENSEファイルをご覧ください。

## SDK開発者向け資料

このSDKの開発者向け資料として、FORDEVELOPER.md を用意しております。
SDKの改修をされる際には、ご一読ください。

## 参考URL集

- [ニフクラ mobile backend](https://mbaas.nifcloud.com/)
- [SDKの詳細な使い方](https://mbaas.nifcloud.com/doc/current/)
- [サンプル＆チュートリアル](https://mbaas.nifcloud.com/doc/current/tutorial/tutorial_swift.html)
- [ユーザーコミュニティ](https://github.com/NIFCLOUD-mbaas/UserCommunity)
