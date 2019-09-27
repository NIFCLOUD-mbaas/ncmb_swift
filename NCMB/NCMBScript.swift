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

/// スクリプト機能を利用するためのクラスです。
public struct NCMBScript {

    let service : NCMBScriptService
    public var name : String

    /// イニシャライズです。
    ///
    /// エンドポイントURL、APIバージョンは他の機能とは異なります。
    ///
    /// - Parameter name: スクリプト名
    /// - Parameter method: スクリプトを実行する際の HTTPメソッド
    /// - Parameter domainURL: エンドポイントURL
    /// - Parameter apiVersion: APIバージョン
    public init(
            name: String,
            method: NCMBHTTPMethod,
            endpoint: String = NCMB.DEFAULT_SCRIPT_ENDPOINT,
            apiVersion: String = NCMB.DEFAULT_SCRIPT_API_VERSION) {
        self.name = name
        self.service = NCMBScriptService(method: method, endpoint: endpoint, apiVersion: apiVersion)
    }

    /// 設定されたスクリプトを同期処理にて実行します。
    ///
    /// - Parameter header: スクリプト実行時のヘッダー（key-value形式）
    /// - Parameter queries: スクリプト実行時のクエリー（key-value形式）
    /// - Parameter body: スクリプト実行時のbody（key-value形式）
    /// - Returns: リクエストが成功した場合は `.success` 、 失敗した場合は `.failure<Error>`
    public func execute(
            headers: [String : String?] = [:],
            queries: [String : String?] = [:],
            body: [String : Any?] = [:]) -> NCMBResult<Data?> {
        var result : NCMBResult<Data?> = NCMBResult.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        executeInBackground(
            headers: headers,
            queries: queries,
            body: body,
            callback: {(res: NCMBResult<Data?>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// 設定されたスクリプトを非同期処理にて実行します。
    ///
    /// - Parameter header: スクリプト実行時のヘッダー（key-value形式）
    /// - Parameter queries: スクリプト実行時のクエリー（key-value形式）
    /// - Parameter body: スクリプト実行時のbody
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func executeInBackground(
            headers: [String : String?] = [:],
            queries: [String : String?] = [:],
            body: [String : Any?] = [:],
            callback: @escaping NCMBHandler<Data?>) -> Void {
        service.executeScript(
                name: name,
                headers: headers,
                queries: queries,
                body: body,
                callback: { (result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    callback( NCMBResult<Data?>.success(response.body))
                    break
                case let .failure(error):
                    callback( NCMBResult<Data?>.failure(error))
                    break
            }
        })
    }
}
