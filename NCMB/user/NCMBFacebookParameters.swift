/*
 Copyright 2019-2023 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

import Foundation

/// SNS認証 Facebook認証で用いるパラメタを保持する構造体です。
public struct NCMBFacebookParameters : NCMBSnsInfoProtocol {

    static let PARAMETER_ID : String = "id"
    static let PARAMETER_ACCESS_TOKEN : String = "access_token"
    static let PARAMETER_EXPIRATION_DATE : String = "expiration_date"

    /// Facebook IDです。
    public var id : String

    /// アクセストークンです。
    public var accessToken : String

    /// トークン有効期限です。
    public var expirationDate : Date

    /// イニシャライズです。
    ///
    /// - Parameter id: Facebook ID
    /// - Parameter accessToken: アクセストークン
    /// - Parameter expirationDate: トークン有効期限
    public init(id: String, accessToken: String, expirationDate: Date) {
        self.id = id
        self.accessToken = accessToken
        self.expirationDate = expirationDate
    }

    var type : NCMBSNSType {
        get {
            return NCMBSNSType.facebook
        }
    }

    func toObject() -> [String : Any] {
        var object : [String : Any] = [:]
        var dateObject : [String : Any] = [:]       
        object[NCMBFacebookParameters.PARAMETER_ID] = self.id
        object[NCMBFacebookParameters.PARAMETER_ACCESS_TOKEN] = self.accessToken
        dateObject["__type"] = "Date"
        dateObject["iso"] =
            NCMBDateFormatter.getISO8601Timestamp(date: self.expirationDate)
        object[NCMBFacebookParameters.PARAMETER_EXPIRATION_DATE] = dateObject
        return object
    }

}
