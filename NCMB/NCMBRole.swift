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

    /// イニシャライズです。
    /// このイニシャライズは変更フィールドを正しく把握するためにモジュール外での利用は許可しません。
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

    /// ロールを検索するためのクエリです。
    public class var query : NCMBQuery<NCMBRole> {
        get {
            return NCMBQuery<NCMBRole>(service: NCMBRoleService())
        }
    }

    /// イニシャライズです。
    ///
    /// - Parameter roleName: ロール名称
    public init(roleName: String) {
        super.init(className: NCMBRole.CLASSNAME)
        self[NCMBRole.FIELDNAME_ROLE_NAME] = roleName
    }

    /// 指定したユーザーを同期処理にて追加します。
    ///
    /// - Parameter user: ユーザー
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func addUser(user: NCMBUser) -> NCMBResult<Void> {
        let users: [NCMBUser] = [user]
        return saveCore(addUsers: users)
    }

    /// 指定したユーザーを非同期処理にて追加します。
    ///
    /// - Parameter user: ユーザー
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func addUserInBackground(user: NCMBUser, callback: @escaping NCMBHandler<Void> ) -> Void {
        let users: [NCMBUser] = [user]
        saveInBackgroundCore(addUsers: users, callback: callback)
    }

    /// 指定したユーザーを同期処理にて追加します。
    ///
    /// - Parameter users: ユーザーの配列
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func addUsers(users: [NCMBUser]) -> NCMBResult<Void> {
        return saveCore(addUsers: users)
    }

    /// 指定したユーザーを非同期処理にて追加します。
    ///
    /// - Parameter users: ユーザーの配列
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func addUsersInBackground(users: [NCMBUser], callback: @escaping NCMBHandler<Void> ) -> Void {
        saveInBackgroundCore(addUsers: users, callback: callback)
    }

    /// 指定したユーザーを同期処理にて削除します。
    ///
    /// - Parameter user: ユーザー
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func removeUser(user: NCMBUser) -> NCMBResult<Void> {
        let users: [NCMBUser] = [user]
        return saveCore(removeUsers: users)
    }

    /// 指定したユーザーを非同期処理にて削除します。
    ///
    /// - Parameter user: ユーザー
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func removeUserInBackground(user: NCMBUser, callback: @escaping NCMBHandler<Void> ) -> Void {
        let users: [NCMBUser] = [user]
        saveInBackgroundCore(removeUsers: users, callback: callback)
    }

    /// 指定したユーザーを同期処理にて削除します。
    ///
    /// - Parameter users: ユーザーの配列
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func removeUsers(users: [NCMBUser]) -> NCMBResult<Void> {
        return saveCore(removeUsers: users)
    }

    /// 指定したユーザーを非同期処理にて削除します。
    ///
    /// - Parameter users: ユーザーの配列
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func removeUsersInBackground(users: [NCMBUser], callback: @escaping NCMBHandler<Void> ) -> Void {
        saveInBackgroundCore(removeUsers: users, callback: callback)
    }

    /// 指定したロールを子ロールとして同期処理にて追加します。
    ///
    /// - Parameter role: 子ロール
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func addRole(role: NCMBRole) -> NCMBResult<Void> {
        let roles: [NCMBRole] = [role]
        return saveCore(addRoles: roles)
    }

    /// 指定したロールを子ロールとして非同期処理にて追加します。
    ///
    /// - Parameter role: 子ロール
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func addRoleInBackground(role: NCMBRole, callback: @escaping NCMBHandler<Void> ) -> Void {
        let roles: [NCMBRole] = [role]
        saveInBackgroundCore(addRoles: roles, callback: callback)
    }

    /// 指定したロールを子ロールとして同期処理にて追加します。
    ///
    /// - Parameter roles: 子ロールの配列
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func addRoles(roles: [NCMBRole]) -> NCMBResult<Void> {
        return saveCore(addRoles: roles)
    }

    /// 指定したロールを子ロールとして非同期処理にて追加します。
    ///
    /// - Parameter roles: 子ロールの配列
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func addRolesInBackground(roles: [NCMBRole], callback: @escaping NCMBHandler<Void> ) -> Void {
        saveInBackgroundCore(addRoles: roles, callback: callback)
    }

    /// 指定した子ロールをロールから同期処理にて削除します。
    ///
    /// - Parameter roles: 子ロールの配列
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func removeRole(role: NCMBRole) -> NCMBResult<Void> {
        let roles: [NCMBRole] = [role]
        return saveCore(removeRoles: roles)
    }

    /// 指定した子ロールをロールから非同期処理にて削除します。
    ///
    /// - Parameter role: 子ロール
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func removeRoleInBackground(role: NCMBRole, callback: @escaping NCMBHandler<Void> ) -> Void {
        let roles: [NCMBRole] = [role]
        saveInBackgroundCore(removeRoles: roles, callback: callback)
    }

    /// 指定した子ロールをロールから同期処理にて削除します。
    ///
    /// - Parameter roles: 子ロールの配列
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func removeRoles(roles: [NCMBRole]) -> NCMBResult<Void> {
        return saveCore(removeRoles: roles)
    }

    /// 指定した子ロールをロールから非同期処理にて削除します。
    ///
    /// - Parameter roles: 子ロールの配列
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func removeRolesInBackground(roles: [NCMBRole], callback: @escaping NCMBHandler<Void> ) -> Void {
        saveInBackgroundCore(removeRoles: roles, callback: callback)
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
        return saveCore()
    }

    /// ロールを非同期処理にて保存します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func saveInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        saveInBackgroundCore(callback: callback)
    }

    /// ロールを同期処理にて保存します。
    ///
    /// - Parameter addUsers: 追加するユーザーの配列
    /// - Parameter removeUsers: 削除するユーザーの配列
    /// - Parameter addRoles: 追加する子ロールの配列
    /// - Parameter removeRoles: 削除する子ロールの配列
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    func saveCore(
            addUsers: [NCMBUser] = [],
            removeUsers: [NCMBUser] = [],
            addRoles: [NCMBRole] = [],
            removeRoles: [NCMBRole] = []) -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        saveInBackgroundCore(
                addUsers: addUsers,
                removeUsers: removeUsers,
                addRoles: addRoles,
                removeRoles: removeRoles,
                callback: {(res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// ロールを非同期処理にて保存します。
    ///
    /// - Parameter addUsers: 追加するユーザーの配列
    /// - Parameter removeUsers: 削除するユーザーの配列
    /// - Parameter addRoles: 追加する子ロールの配列
    /// - Parameter removeRoles: 削除する子ロールの配列
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    func saveInBackgroundCore(
            addUsers: [NCMBUser] = [],
            removeUsers: [NCMBUser] = [],
            addRoles: [NCMBRole] = [],
            removeRoles: [NCMBRole] = [],
            callback: @escaping NCMBHandler<Void> ) -> Void {
        let roleRelationOperator = createBelongItems(className: NCMBRole.CLASSNAME, add: addRoles, remove: removeRoles)
        if let roleRelationOperator = roleRelationOperator {
            self[NCMBRole.FIELDNAME_BELONG_ROLE] = roleRelationOperator
        }
        let userRelationOperator = createBelongItems(className: NCMBUser.CLASSNAME, add: addUsers, remove: removeUsers)
        if let userRelationOperator = userRelationOperator {
            self[NCMBRole.FIELDNAME_BELONG_USER] = userRelationOperator
        }
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

    func createBelongItems(className: String, add: [NCMBBase], remove: [NCMBBase]) -> Any? {
        if add.count != 0 {
            return NCMBAddRelationOperator(elements: getPointers(className: className, objects: add))
        }
        if remove.count != 0 {
            return NCMBRemoveRelationOperator(elements: getPointers(className: className, objects: remove))
        }
        return nil
    }

    func getPointers(className: String, objects: [NCMBBase]) -> [NCMBPointer] {
        var elements: [NCMBPointer] = []
        for object in objects {
            if let objectId = object.objectId {
                elements.append(NCMBPointer(className: className, objectId: objectId))
            }
        }
        return elements
    }
}
