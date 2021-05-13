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

/// 共通情報を管理するクラスです。
public class NCMB {
    public static let SDK_VERSION : String = "1.2.0"
    static let METADATA_PREFIX : String = "com.nifcloud.mbaas."
    public static let DEFAULT_DOMAIN_URL : String = "https://mbaas.api.nifcloud.com/"
    public static let DEFAULT_API_VERSION : String = "2013-09-01"
    public static let DEFAULT_SCRIPT_ENDPOINT : String = "https://script.mbaas.api.nifcloud.com/"
    public static let DEFAULT_SCRIPT_API_VERSION : String = "2015-09-01"

    private static let shared = NCMB()
    private var _domainURL : String = DEFAULT_DOMAIN_URL
    private var _apiVersion : String = DEFAULT_API_VERSION
    private var _applicationKey : String = ""
    private var _clientKey : String = ""

    /// イニシャライズです。
    private init() {}

    /// エンドポイントURLです。
    class var domainURL : String {
        get {
            return getInstance()._domainURL
        }
    }

    /// APIバージョンです。
    class var apiVersion : String {
        get {
            return getInstance()._apiVersion
        }
    }

    /// アプリケーションキーです。
    class var applicationKey : String {
        get {
            return getInstance()._applicationKey
        }
    }

    /// クライアントキーです。
    class var clientKey : String {
        get {
            return getInstance()._clientKey
        }
    }

    /// イニシャライズです。
    ///
    /// エンドポイントURL、APIバージョンはスクリプト機能では使用されません。独自指定をする場合は `NCMBScript` を利用する際に別途指定してください。
    ///
    /// - Parameter applicationKey: アプリケーションキー
    /// - Parameter clientKey: クライアントキー
    /// - Parameter domainURL: エンドポイントURL
    /// - Parameter apiVersion: APIバージョン
    public class func initialize(
        applicationKey: String,
        clientKey: String,
        domainURL: String = DEFAULT_DOMAIN_URL,
        apiVersion : String = DEFAULT_API_VERSION) {

        shared._applicationKey = applicationKey
        shared._clientKey = clientKey
        shared._domainURL = domainURL
        shared._apiVersion = apiVersion
    }

    /// 自らの型のインスタンスを返します。
    ///
    /// - Returns: `NCMB` インスタンス
    private class func getInstance() -> NCMB {
        return shared
    }

}
