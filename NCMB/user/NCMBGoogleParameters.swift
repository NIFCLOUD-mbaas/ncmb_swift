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

/// SNS認証 Google認証で用いるパラメタを保持する構造体です。
public struct NCMBGoogleParameters : NCMBSnsInfoProtocol {

    static let PARAMETER_ID : String = "id"
    static let PARAMETER_ACCESS_TOKEN : String = "access_token"

    /// ユーザーIDです。
    public var id : String

    /// アクセストークンです。
    public var accessToken : String

    /// イニシャライズです。
    ///
    /// - Parameter id: ユーザーID
    /// - Parameter accessToken: アクセストークン
    public init(id: String, accessToken: String) {
        self.id = id
        self.accessToken = accessToken
    }

    var type : NCMBSNSType {
        get {
            return NCMBSNSType.google
        }
    }

    func toObject() -> [String : Any] {
        var object : [String : Any] = [:]
        object[NCMBGoogleParameters.PARAMETER_ID] = self.id
        object[NCMBGoogleParameters.PARAMETER_ACCESS_TOKEN] = self.accessToken
        return object
    }

}