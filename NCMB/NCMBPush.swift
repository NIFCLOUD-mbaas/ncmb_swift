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
#if os(iOS)
    import UIKit
#endif

/// プッシュ通知を操作するクラスです。
public class NCMBPush : NCMBBase {
    static let CLASSNAME : String = "push"
    static let FIELDNAME_DELIVERY_TIME : String = "deliveryTime"
    static let FIELDNAME_IMMEDIATE_DELIVERY_FLAG : String = "immediateDeliveryFlag"
    static let FIELDNAME_TARGET : String = "target"
    static let FIELDNAME_SEARCHCONDITION : String = "searchCondition"
    static let FIELDNAME_MESSAGE : String = "message"
    static let FIELDNAME_USERSETTINGVALUE : String = "userSettingValue"
    static let FIELDNAME_DELIVERYEXPIRATIONDATE : String = "deliveryExpirationDate"
    static let FIELDNAME_DELIVERYEXPIRATIONTIME : String = "deliveryExpirationTime"
    static let FIELDNAME_ACTION : String = "action"
    static let FIELDNAME_TITLE : String = "title"
    static let FIELDNAME_DIALOG : String = "dialog"
    static let FIELDNAME_BADGEINCREMENTFLAG : String = "badgeIncrementFlag"
    static let FIELDNAME_BADGESETTING : String = "badgeSetting"
    static let FIELDNAME_SOUND : String = "sound"
    static let FIELDNAME_CONTENTAVAILABLE : String = "contentAvailable"
    static let FIELDNAME_RICHURL : String = "richUrl"
    static let FIELDNAME_CATEGORY : String = "category"

    /// イニシャライズです。
    /// このイニシャライズは変更フィールドを正しく把握するためにモジュール外での利用は許可しません。
    ///
    /// - Parameter className: データストアのクラス名
    /// - Parameter fields: フィールド内容
    /// - Parameter modifiedFieldKeys: 更新フィールド名一覧
    required init(className: String, fields: [String : Any], modifiedFieldKeys: Set<String> = []) {
        super.init(className: className, fields: fields, modifiedFieldKeys: modifiedFieldKeys)
    }
    
    /// 配信時刻です。
    public var deliveryTime : Date? {
        get {
            if let field = self[NCMBPush.FIELDNAME_DELIVERY_TIME] as Any? {
                if let date = field as? Date {
                    return date
                }
            }
            return nil
        }
        set {
            if let date = newValue {
                self[NCMBPush.FIELDNAME_DELIVERY_TIME] = date
                self[NCMBPush.FIELDNAME_IMMEDIATE_DELIVERY_FLAG] = false
            } else {
                self[NCMBPush.FIELDNAME_DELIVERY_TIME] = nil as Date?
                self[NCMBPush.FIELDNAME_IMMEDIATE_DELIVERY_FLAG] = true
            }
        }
    }
    
    /// 即時配信設定値です。即時配信の場合は `true` 、それ以外では `false` 。
    public var immediateDeliveryFlag : Bool {
        get {
            if let value = self[NCMBPush.FIELDNAME_IMMEDIATE_DELIVERY_FLAG] as Any? {
                if let flag = value as? Bool {
                    return flag
                }
            }
            return false
        }
    }
    
    /// ターゲットです。
    public var target : [String]? {
        get {
            return self[NCMBPush.FIELDNAME_TARGET]
        }
        set {
            self[NCMBPush.FIELDNAME_TARGET] = newValue
        }
    }
    
    /// iOSのプッシュ通知送信対象です。
    public var isSendToIOS : Bool {
        get {
            let target = NCMBPushTarget(object: self.target)
            return target.isSendToIOS
        }
        set {
            var target = NCMBPushTarget(object: self.target)
            target.isSendToIOS = newValue
            self.target = target.toObject()
        }
    }
    
    /// androidのプッシュ通知送信対象です。
    public var isSendToAndroid : Bool {
        get {
            let target = NCMBPushTarget(object: self.target)
            return target.isSendToAndroid
        }
        set {
            var target = NCMBPushTarget(object: self.target)
            target.isSendToAndroid = newValue
            self.target = target.toObject()
        }
    }
    
    /// 検索条件です。
    public var searchCondition : NCMBQuery<NCMBInstallation>? {
        get {
            if let queryWhereItems: [String : Any] = self[NCMBPush.FIELDNAME_SEARCHCONDITION] {
                return NCMBQuery<NCMBInstallation>(
                    className: NCMBInstallation.CLASSNAME,
                    service: NCMBInstallationService(),
                    whereItems: queryWhereItems)
            }
            return NCMBQuery<NCMBInstallation>(
                className: NCMBInstallation.CLASSNAME,
                service: NCMBInstallationService())
        }
        set {
            if let query: NCMBQuery<NCMBInstallation> = newValue {
                self[NCMBPush.FIELDNAME_SEARCHCONDITION] = query.whereItems
            } else {
                self[NCMBPush.FIELDNAME_SEARCHCONDITION] = [:] as [String:Any]
            }
        }
    }
    
    /// メッセージです。
    public var message : String? {
        get {
            return self[NCMBPush.FIELDNAME_MESSAGE]
        }
        set {
            self[NCMBPush.FIELDNAME_MESSAGE] = newValue
        }
    }
    
    /// ユーザー設定値です。
    public var userSettingValue : Any? {
        get {
            return self[NCMBPush.FIELDNAME_USERSETTINGVALUE]
        }
        set {
            self[NCMBPush.FIELDNAME_USERSETTINGVALUE] = newValue
        }
    }
    
    /// 配信期限日です。
    public var deliveryExpirationDate : Date? {
        get {
            return self[NCMBPush.FIELDNAME_DELIVERYEXPIRATIONDATE]
        }
        set {
            self[NCMBPush.FIELDNAME_DELIVERYEXPIRATIONDATE] = newValue
            if newValue != nil {
                self.removeField(field: NCMBPush.FIELDNAME_DELIVERYEXPIRATIONTIME)
            }
        }
    }
    
    /// 配信期限時間です。
    public var deliveryExpirationTime : NCMBExpirationTime? {
        get {
            if let string: String = self[NCMBPush.FIELDNAME_DELIVERYEXPIRATIONTIME] {
                return NCMBExpirationTime(string: string)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self[NCMBPush.FIELDNAME_DELIVERYEXPIRATIONTIME] = newValue.getString()
                self.removeField(field: NCMBPush.FIELDNAME_DELIVERYEXPIRATIONDATE)
            } else {
                self.removeField(field: NCMBPush.FIELDNAME_DELIVERYEXPIRATIONTIME)
            }
        }
    }
    
    /// アクションです。
    public var action : String? {
        get {
            return self[NCMBPush.FIELDNAME_ACTION]
        }
        set {
            self[NCMBPush.FIELDNAME_ACTION] = newValue
        }
    }
    
    /// タイトルです。
    public var title : String? {
        get {
            return self[NCMBPush.FIELDNAME_TITLE]
        }
        set {
            self[NCMBPush.FIELDNAME_TITLE] = newValue
        }
    }
    
    /// ダイアログ通知有効化フラグです。
    public var dialog : Bool? {
        get {
            return self[NCMBPush.FIELDNAME_DIALOG]
        }
        set {
            self[NCMBPush.FIELDNAME_DIALOG] = newValue
        }
    }
    
    /// バッジ数増加フラグです。
    public var badgeIncrementFlag : Bool? {
        get {
            return self[NCMBPush.FIELDNAME_BADGEINCREMENTFLAG]
        }
        set {
            self[NCMBPush.FIELDNAME_BADGEINCREMENTFLAG] = newValue
        }
    }
    
    /// バッジ数です。
    public var badgeSetting : Int? {
        get {
            return self[NCMBPush.FIELDNAME_BADGESETTING]
        }
        set {
            self[NCMBPush.FIELDNAME_BADGESETTING] = newValue
        }
    }
    
    /// 音楽ファイルです。
    public var sound : String? {
        get {
            return self[NCMBPush.FIELDNAME_SOUND]
        }
        set {
            self[NCMBPush.FIELDNAME_SOUND] = newValue
        }
    }
    
    /// content-availableです。
    public var contentAvailable : Bool? {
        get {
            return self[NCMBPush.FIELDNAME_CONTENTAVAILABLE]
        }
        set {
            self[NCMBPush.FIELDNAME_CONTENTAVAILABLE] = newValue
        }
    }
    
    /// リッチプッシュURLです。
    public var richUrl : String? {
        get {
            return self[NCMBPush.FIELDNAME_RICHURL]
        }
        set {
            self[NCMBPush.FIELDNAME_RICHURL] = newValue
        }
    }
    
    /// カテゴリです。
    public var category : String? {
        get {
            return self[NCMBPush.FIELDNAME_CATEGORY]
        }
        set {
            self[NCMBPush.FIELDNAME_CATEGORY] = newValue
        }
    }
    
    /// 即時にて配信するよう設定します。
    public func setImmediateDelivery() -> Void {
        self[NCMBPush.FIELDNAME_IMMEDIATE_DELIVERY_FLAG] = true
        self[NCMBPush.FIELDNAME_DELIVERY_TIME] = nil as NCMBDateField?
    }

    /// イニシャライズです。
    public init() {
        super.init(className: NCMBPush.CLASSNAME)
        self[NCMBPush.FIELDNAME_IMMEDIATE_DELIVERY_FLAG] = true
        self[NCMBPush.FIELDNAME_DELIVERY_TIME] = nil as NCMBDateField?
        self[NCMBPush.FIELDNAME_TARGET] = [] as [String]?
        self[NCMBPush.FIELDNAME_SEARCHCONDITION] = [:] as [String:Any]
    }
    
    /// プッシュ通知登録情報を検索するためのクエリです。
    public class var query : NCMBQuery<NCMBPush> {
        get {
            return NCMBQuery<NCMBPush>(service: NCMBPushService())
        }
    }
    
    /// 設定されたオブジェクトIDに対応するプッシュ通知登録情報を同期処理にて取得します。
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
    
    /// 設定されたオブジェクトIDに対応するプッシュ通知登録情報を非同期処理にて取得します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func fetchInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBPushService().fetch(object: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
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
    
    /// プッシュ通知を同期処理にて登録します。
    ///
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public func send() -> NCMBResult<Void> {
        var result : NCMBResult<Void> = NCMBResult<Void>.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        sendInBackground(callback: {(res: NCMBResult<Void>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }
    
    /// プッシュ通知を非同期処理にて登録します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func sendInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBPushService().save(object: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
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
    
    /// 設定されたオブジェクトIDに対応するプッシュ通知登録情報を同期処理にて削除します。
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
    
    /// 設定されたオブジェクトIDに対応するプッシュ通知登録情報を非同期処理にて削除します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func deleteInBackground(callback: @escaping NCMBHandler<Void> ) -> Void {
        NCMBPushService().delete(object: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
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
    
    private struct NCMBPushTarget {
        private static let TARGET_IOS = "ios"
        private static let TARGET_ANDROID = "android"
        var isSendToIOS : Bool
        var isSendToAndroid : Bool
        
        init(object: [String]?) {
            self.isSendToIOS = false
            self.isSendToAndroid = false
            if let object = object {
                for item in object {
                    if item == NCMBPushTarget.TARGET_IOS {
                        self.isSendToIOS = true
                    }
                    if item == NCMBPushTarget.TARGET_ANDROID {
                        self.isSendToAndroid = true
                    }
                }
            }
        }
        
        func toObject() -> [String] {
            var object : [String] = []
            if self.isSendToIOS {
                object.append(NCMBPushTarget.TARGET_IOS)
            }
            if self.isSendToAndroid {
                object.append(NCMBPushTarget.TARGET_ANDROID)
            }
            return object
        }
    }

    public static func handleRichPush(userInfo: [String : AnyObject]?, completion: @escaping () -> Void = {}) {
        #if os(iOS)
            if let urlStr = userInfo?["com.nifcloud.mbaas.RichUrl"] as? String {
                let richPushView = NCMBRichPushView()
                richPushView.richUrl = urlStr
                richPushView.closeCallback = completion
                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow?.rootViewController?.present(richPushView, animated: true, completion: nil)
                }
            }
        #endif
    }
}
