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

import Foundation

/// 匿名ユーザでのログインを管理するクラスです。
public class NCMBAnonymousUtils {

    static let AUTH_TYPE_ANONYMOUS : String = "anonymous"

    class func login(callback: @escaping NCMBHandler<NCMBUser>) -> Void {
        let user : NCMBUser = createAnonymousUser()
        user.signUpInBackground(callback: { result in
            switch result {
                case .success:
                    callback( NCMBResult<NCMBUser>.success(user))
                    break
                case let .failure(error):
                    callback( NCMBResult<NCMBUser>.failure(error))
                    break
            }
        })
    }

    /// 指定したユーザが匿名ユーザかどうかを判定します。
    ///
    /// - Parameter user: ユーザー
    /// - Returns: 匿名ユーザーの場合は `true` 、それ以外では `false`
    public class func isLinked(user: NCMBUser) -> Bool {
        if let authData : [String : Any] = user.authData {
            if authData[AUTH_TYPE_ANONYMOUS] != nil && user.password == nil {
                return true
            }
        }
        return false
    }

    class func createAnonymousUser() -> NCMBUser {
        var anonymous : [String : Any] = [:]
        anonymous["id"] = createUUID()
        var anonymousDic : [String : Any] = [:]
        anonymousDic[AUTH_TYPE_ANONYMOUS] = anonymous
        let user = NCMBUser()
        user.authData = anonymousDic
        return user
    }

    class func createUUID() -> String {
        return UUID().uuidString
    }
}