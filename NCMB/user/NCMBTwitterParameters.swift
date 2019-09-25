/*
 Copyright 2019 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

/// SNS認証 Twitter認証で用いるパラメタを保持する構造体です。
public struct NCMBTwitterParameters : NCMBSnsInfoProtocol {

    static let PARAMETER_ID : String = "id"
    static let PARAMETER_SCREEN_NAME : String = "screen_name"
    static let PARAMETER_OAUTH_CONSUMER_KEY : String = "oauth_consumer_key"
    static let PARAMETER_CONSUMER_SECRET : String = "consumer_secret"
    static let PARAMETER_OAUTH_TOKEN : String = "oauth_token"
    static let PARAMETER_OAUTH_TOKEN_SECRET : String = "oauth_token_secret"

    /// Twitter IDです。
    public var id : String

    /// 名前です。
    public var screenName : String

    /// コンシューマーキーです。
    public var oauthConsumerKey : String

    /// コンシューマーシークレットキーです。
    public var consumerSecret : String

    /// トークンです。
    public var oauthToken : String

    /// トークンシークレットです。
    public var oauthTokenSecret : String

    /// イニシャライズです。
    ///
    /// - Parameter id: Twitter ID
    /// - Parameter screenName: 名前
    /// - Parameter oauthConsumerKey: コンシューマーキー
    /// - Parameter consumerSecret: コンシューマーシークレットキー
    /// - Parameter oauthToken: トークン
    /// - Parameter oauthTokenSecret: トークンシークレット
    public init(
            id: String,
            screenName: String,
            oauthConsumerKey: String,
            consumerSecret: String,
            oauthToken: String,
            oauthTokenSecret: String) {
        self.id = id
        self.screenName = screenName
        self.oauthConsumerKey = oauthConsumerKey
        self.consumerSecret = consumerSecret
        self.oauthToken = oauthToken
        self.oauthTokenSecret = oauthTokenSecret
    }

    var type : NCMBSNSType {
        get {
            return NCMBSNSType.twitter
        }
    }

    func toObject() -> [String : Any] {
        var object : [String : Any] = [:]
        object[NCMBTwitterParameters.PARAMETER_ID] = self.id
        object[NCMBTwitterParameters.PARAMETER_SCREEN_NAME] = self.screenName
        object[NCMBTwitterParameters.PARAMETER_OAUTH_CONSUMER_KEY] = self.oauthConsumerKey
        object[NCMBTwitterParameters.PARAMETER_CONSUMER_SECRET] = self.consumerSecret
        object[NCMBTwitterParameters.PARAMETER_OAUTH_TOKEN] = self.oauthToken
        object[NCMBTwitterParameters.PARAMETER_OAUTH_TOKEN_SECRET] = self.oauthTokenSecret
        return object
    }

}