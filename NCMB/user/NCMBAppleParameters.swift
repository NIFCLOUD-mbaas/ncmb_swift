/*
Copyright 2020 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.

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

/// SNS認証 Apple認証で用いるパラメタを保持する構造体です。
public struct NCMBAppleParameters : NCMBSnsInfoProtocol {
    
    static let PARAMETER_ID : String = "id"
    static let PARAMETER_ACCESS_TOKEN : String = "access_token"
    static let PARAMETER_CLIENT_ID : String = "client_id"
    
    /// Apple IDです。
    public var id : String

    /// アクセストークンです。
    public var accessToken : String
    
    private var clientId : String
    
    /// イニシャライズです。
    ///
    /// - Parameter id: Apple ID
    /// - Parameter accessToken: アクセストークン
    public init(id: String, accessToken: String) {
        self.id = id
        self.accessToken = accessToken
        self.clientId = Bundle.main.bundleIdentifier ?? ""
    }
    
    var type: NCMBSNSType {
        get {
            return NCMBSNSType.apple
        }
    }
    
    func toObject() -> [String : Any] {
        var object : [String : Any] = [:]
        object[NCMBAppleParameters.PARAMETER_ID] = self.id
        object[NCMBAppleParameters.PARAMETER_ACCESS_TOKEN] = self.accessToken
        object[NCMBAppleParameters.PARAMETER_CLIENT_ID] = self.clientId
        return object
    }
    
}
