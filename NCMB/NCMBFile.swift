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

/// ファイルストアへの操作を行うクラスです。
public class NCMBFile : NCMBBase {
    static let CLASSNAME : String = "file"

    static let FIELDNAME_FILENAME : String = "fileName"
    static let FIELDNAME_MIMETYPE : String = "mimeType"
    static let FIELDNAME_FILESIZE : String = "fileSize"
    private var _fileName : String

    /// ファイル名です。
    public var fileName : String {
        get {
            return self._fileName
        }
        set {
            self._fileName = newValue
            self[NCMBFile.FIELDNAME_FILENAME] = newValue
        }
    }

    /// ファイルを検索するためのクエリです。
    public class var query : NCMBQuery<NCMBFile> {
        get {
            return NCMBQuery<NCMBFile>(service: NCMBFileService())
        }
    }

    /// MIME-TYPEです。
    public var mimeType : String? {
        get {
            return self[NCMBFile.FIELDNAME_MIMETYPE]
        }
    }

    /// ファイルサイズ（バイト単位）です。
    public var fileSize : Int? {
        get {
            return self[NCMBFile.FIELDNAME_FILESIZE]
        }
    }

    /// イニシャライズです。
    /// このイニシャライズは変更フィールドを正しく把握するためにモジュール外での利用は許可しません。
    ///
    /// - Parameter className: データストアのクラス名
    /// - Parameter fields: フィールド内容
    /// - Parameter modifiedFieldKeys: 更新フィールド名一覧
    required init(className: String, fields: [String : Any], modifiedFieldKeys: Set<String> = []) {
        self._fileName = ""
        super.init(className: className, fields: fields, modifiedFieldKeys: modifiedFieldKeys)
    }

    /// イニシャライズです。
    ///
    /// - Parameter fileName: ファイル名
    /// - Parameter acl: ACL
    public init(fileName: String, acl: NCMBACL? = nil) {
        self._fileName = fileName
        super.init(className: NCMBFile.CLASSNAME)
        self[NCMBFile.FIELDNAME_FILENAME] = fileName
        self.acl = acl
    }

    /// ユーザーが設定可能なフィールドであるかを判定します。
    ///
    /// - Parameter field: フィールド名
    /// - Returns: ユーザーが設定可能なフィールドの場合は `true` 、それ以外では `false` 。
    override func isIgnoredKey(field: String) -> Bool {
        return true
    }

    /// ファイルを同期処理にて取得します。
    ///
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public func fetch() -> NCMBResult<Data?> {
        var result : NCMBResult<Data?> = NCMBResult.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        fetchInBackground(callback: {(res: NCMBResult<Data?>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// 設定されたファイル名のファイルを非同期処理にて取得します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func fetchInBackground(callback: @escaping NCMBHandler<Data?> ) -> Void {
        NCMBFileService().fetch(
                file: self,
                callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    callback(NCMBResult<Data?>.success(response.body))
                    break
                case let .failure(error):
                    callback(NCMBResult<Data?>.failure(error))
                    break
            }
        })
    }

    /// 設定されたファイル名のファイルを同期処理にて取得します。
    ///
    /// - Parameter data: ファイルデータ
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public func save(data: Data) -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        saveInBackground(data: data, callback: {(res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// ファイルを非同期処理にて保存します。
    ///
    /// - Parameter data: ファイルデータ
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func saveInBackground(data: Data, callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBFileService().save(
                file: self,
                data: data,
                callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case .success(_):
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// ファイルのACLを同期処理にて更新します。
    ///
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public func update() -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        updateInBackground(callback: {(res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// ファイルのACLを非同期処理にて更新します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func updateInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBFileService().update(file: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case .success(_):
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// 設定されたファイル名のファイルを同期処理にて削除します。
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

    /// 設定されたファイル名のファイルを非同期処理にて削除します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func deleteInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBFileService().delete(file: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case .success(_):
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }
}