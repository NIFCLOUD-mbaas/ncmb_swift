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

///　会員管理のロールを操作するためのクラスです。
public class NCMBRole : NCMBBase {

    static let CLASSNAME : String = "role"
    static let FIELDNAME_ROLE_NAME = "roleName"
    static let FIELDNAME_BELONG_ROLE = "belongRole"
    static let FIELDNAME_BELONG_USER = "belongUser"

    /// コンストラクタです。
    /// このコンストラクタは変更フィールドを正しく把握するためにモジュール外での利用は許可しません。
    ///
    /// - Parameter className: データストアのクラス名
    /// - Parameter fields: フィールド内容
    /// - Parameter modifiedFieldKeys: 更新フィールド名一覧
    required init(className: String, fields: [String : Any], modifiedFieldKeys: Set<String> = []) {
        super.init(className: className, fields: fields, modifiedFieldKeys: modifiedFieldKeys)
    }

    /// ロール名称です。
    public var roleName : String? {
        get {
            if let roleName : Any = self[NCMBRole.FIELDNAME_ROLE_NAME] {
                if let roleName = roleName as? String {
                    return roleName
                }
            }
            return nil
        }
        set {
            self[NCMBRole.FIELDNAME_ROLE_NAME] = newValue
        }
    }

    /// **TBD** ロールに紐づくユーザーです。
    public var users : [NCMBUser] {
        //TBD
        get {
            return []
        }
    }

    /// **TBD** ロールに紐づくロールです。
    public var roles : [NCMBRole] {
        //TBD
        get {
            return []
        }
    }

    /// ロールを検索するためのクエリです。
    public class var query : NCMBQuery<NCMBRole> {
        get {
            return NCMBQuery<NCMBRole>(service: NCMBRoleService())
        }
    }

    /// コンストラクタです。
    ///
    /// - Parameter roleName: ロール名称
    public init(roleName: String) {
        super.init(className: NCMBRole.CLASSNAME)
        self[NCMBRole.FIELDNAME_ROLE_NAME] = roleName
    }

    /// **TBD** 指定したユーザーを非同期処理にて追加します。
    ///
    /// - Parameter user: ユーザー
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func addUserInBackground(user: NCMBUser, callback: @escaping NCMBHandler<Void> ) -> Void {
        //TBD
    }

    /// **TBD** 指定したユーザーを非同期処理にて削除します。
    ///
    /// - Parameter user: ユーザー
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func removeUserInBackground(user: NCMBUser, callback: @escaping NCMBHandler<Void> ) -> Void {
        //TBD
    }

    /// **TBD** 指定したロールを非同期処理にて追加します。
    ///
    /// - Parameter user: ロール
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func addRoleInBackground(user: NCMBRole, callback: @escaping NCMBHandler<Void> ) -> Void {
        //TBD
    }

    /// **TBD** 指定したロールを非同期処理にて削除します。
    ///
    /// - Parameter user: ロール
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func removeRoleInBackground(user: NCMBRole, callback: @escaping NCMBHandler<Void> ) -> Void {
        //TBD
    }

    /// 設定されたオブジェクトIDに対応するロールを同期処理にて取得します。
    ///
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public func fetch() -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        fetchInBackground(callback: {(res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// 設定されたオブジェクトIDに対応するロールを非同期処理にて取得します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func fetchInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBRoleService().fetch(object: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    self.removeAllFields()
                    self.reflectResponse(response: response)
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// ロールを同期処理にて保存します。
    ///
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public func save() -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        saveInBackground(callback: {(res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// ロールを非同期処理にて保存します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func saveInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBRoleService().save(object: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    self.reflectResponse(response: response)
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// ロールを同期処理にて削除します
    ///
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public func delete() -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        deleteInBackground(callback: {(res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// ロールを非同期処理にて削除します
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func deleteInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBRoleService().delete(object: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case .success(_):
                    self.removeAllFields()
                    self.removeAllModifiedFieldKeys()
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }
}
