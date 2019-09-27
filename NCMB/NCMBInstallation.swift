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

/// 配信端末情報を操作するためのクラスです。
public class NCMBInstallation : NCMBBase {
    static let CLASSNAME : String = "installation"
    static let FIELDNAME_DEVICE_TYPE = "deviceType"
    static let FIELDNAME_DEVICE_TOKEN = "deviceToken"
    static let FIELDNAME_APPLICATION_NAME = "applicationName"
    static let FIELDNAME_APP_VERSION = "appVersion"
    static let FIELDNAME_TIMEZONE = "timeZone"
    static let FIELDNAME_SDK_VERSION = "sdkVersion"
    static let FIELDNAME_BADGE = "badge"
    static let FIELDNAME_CHANNELS = "channels"

    /// イニシャライズです。
    /// このイニシャライズは変更フィールドを正しく把握するためにモジュール外での利用は許可しません。
    ///
    /// - Parameter className: データストアのクラス名
    /// - Parameter fields: フィールド内容
    /// - Parameter modifiedFieldKeys: 更新フィールド名一覧
    required init(className: String, fields: [String : Any], modifiedFieldKeys: Set<String> = []) {
        super.init(className: className, fields: fields, modifiedFieldKeys: modifiedFieldKeys)
    }

    /// イニシャライズです。
    public init() {
        super.init(className: NCMBInstallation.CLASSNAME)
        let channels : [String] = []
        self[NCMBInstallation.FIELDNAME_DEVICE_TYPE] = NCMBDeviceSystem.osType
        self[NCMBInstallation.FIELDNAME_APPLICATION_NAME] = NCMBInstallation.getApplicationName()
        self[NCMBInstallation.FIELDNAME_APP_VERSION] = NCMBInstallation.getAppVersion()
        self[NCMBInstallation.FIELDNAME_TIMEZONE] = NCMBInstallation.getTimeZone()
        self[NCMBInstallation.FIELDNAME_SDK_VERSION] = NCMB.SDK_VERSION
        self[NCMBInstallation.FIELDNAME_CHANNELS] = channels
    }

    /// デバイスの種類です。
    public var deviceType : String? {
        get {
            return self[NCMBInstallation.FIELDNAME_DEVICE_TYPE]
        }
    }

    /// デバイストークンです。
    public var deviceToken : String? {
        get {
            return self[NCMBInstallation.FIELDNAME_DEVICE_TOKEN]
        }
        set {
            self[NCMBInstallation.FIELDNAME_DEVICE_TOKEN] = newValue
        }
    }

    /// バッジです。
    public var badge : Int? {
        get {
            return self[NCMBInstallation.FIELDNAME_BADGE]
        }
        set {
            self[NCMBInstallation.FIELDNAME_BADGE] = newValue
        }
    }

    /// タイムゾーンです。
    public var timeZone : String? {
        get {
            return self[NCMBInstallation.FIELDNAME_TIMEZONE]
        }
        set {
            self[NCMBInstallation.FIELDNAME_TIMEZONE] = newValue
        }
    }

    /// チャンネルです。
    public var channels : [String]? {
        get {
            return self[NCMBInstallation.FIELDNAME_CHANNELS]
        }
        set {
            self[NCMBInstallation.FIELDNAME_CHANNELS] = newValue
        }
    }

    /// 配信端末を検索するためのクエリです。
    public class var query : NCMBQuery<NCMBInstallation> {
        get {
            return NCMBQuery<NCMBInstallation>(service: NCMBInstallationService())
        }
    }

    /// 設定されたオブジェクトIDに対応する配信端末情報を同期処理にて取得します。
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

    /// 設定されたオブジェクトIDに対応する配信端末情報を非同期処理にて取得します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func fetchInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBInstallationService().fetch(object: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    self.removeAllFields()
                    self.reflectResponse(response: response)
                    self.updateInstallation()
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// 配信端末情報を同期処理にて保存します。
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

    /// 配信端末情報を非同期処理にて保存します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func saveInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBInstallationService().save(object: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    self.reflectResponse(response: response)
                    self.saveToFile()
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// 設定されたオブジェクトIDに対応する配信端末情報を同期処理にて削除します。
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

    /// 設定されたオブジェクトIDに対応する配信端末情報を非同期処理にて削除します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func deleteInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBInstallationService().delete(object: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case .success(_):
                    self.removeAllFields()
                    self.removeAllModifiedFieldKeys()
                    NCMBInstallation.deleteFile()
                    callback(NCMBResult<Void>.success(()))
                    break
                case let .failure(error):
                    callback(NCMBResult<Void>.failure(error))
                    break
            }
        })
    }

    /// アプリが動作している端末のNCMBInstallationです。
    public class var currentInstallation : NCMBInstallation {
        get {
            if let installation = NCMBInstallation.loadFromFile() {
                installation.updateInstallation()
                installation.saveToFile()
                return installation
            }
            return NCMBInstallation()
        }
    }

    /// 配信端末情報が持つSDKバージョン、アプリバージョンを更新します。
    private func updateInstallation() -> Void {
        self[NCMBInstallation.FIELDNAME_SDK_VERSION] = NCMB.SDK_VERSION
        self[NCMBInstallation.FIELDNAME_APP_VERSION] = NCMBInstallation.getAppVersion()
    }

    /// デバイストークンを設定します。
    ///
    /// - Parameter data: 取得したデバイストークン
    public func setDeviceTokenFromData(data: Data) -> Void {
        var deviceToken : String = ""
        for i in 0..<data.count {
            deviceToken += String(format: "%02hhx", data[i])
        }
        self.deviceToken = deviceToken
    }

    /// ローカルファイルから配信端末情報を取得します。
    ///
    /// - Returns: すでに保存されている配信端末情報が存在する場合は保存された情報を、存在しない場合は `nil`
    class func loadFromFile() -> NCMBInstallation? {
        let manager : NCMBLocalFileManagerProtocol = NCMBLocalFileManagerFactory.getInstance()
        let data : Data? = manager.loadFromFile(target: .currentInstallation)
        if let data : Data = data {
            do {
                let fields : [String : Any] = try NCMBJsonConverter.convertToKeyValue(data)
                return NCMBInstallation(className: NCMBInstallation.CLASSNAME, fields: fields)
            } catch let error {
                NSLog("NCMB: Failed to acquire local file with current installation : \(error)")
                return nil
            }
        }
        return nil
    }

    /// 配信端末情報をローカルファイルに保存します。
    func saveToFile() -> Void {
        let manager : NCMBLocalFileManagerProtocol = NCMBLocalFileManagerFactory.getInstance()
        do {
            let data : Data? = try self.toJson()
            if let data : Data = data {
                manager.saveToFile(data: data, target: .currentInstallation)
            }
        } catch let error {
            NSLog("NCMB: Failed to save local file with current installation : \(error)")
        }
    }

    /// ローカルに保存されいてる配信端末情報を削除します。
    class func deleteFile() -> Void {
        let manager : NCMBLocalFileManagerProtocol = NCMBLocalFileManagerFactory.getInstance()
        manager.deleteFile(target: .currentInstallation)
    }

    /// 端末のタイムゾーンを取得します。
    ///
    /// - Returns: タイムゾーン
    class func getTimeZone() -> String {
        return TimeZone.current.identifier
    }

    /// アプリケーション名を取得します。
    ///
    /// - Returns: アプリケーション名
    class func getApplicationName() -> String {
        if let infoDictionary = Bundle.main.infoDictionary {
            if let bundleName = infoDictionary["CFBundleName"] {
                if let bundleName  = bundleName as? String {
                    return bundleName
                }
            }
        }
        return ""
    }

    /// アプリケーションのバージョンを取得します。
    ///
    /// - Returns: アプリケーションのバージョン
    class func getAppVersion() -> String {
        if let infoDictionary = Bundle.main.infoDictionary {
            if let bundleName = infoDictionary["CFBundleVersion"] {
                if let bundleName  = bundleName as? String {
                    return bundleName
                }
            }
        }
        return ""
    }
}
