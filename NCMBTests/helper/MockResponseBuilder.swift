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
@testable import NCMB
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// テストコードで使用するモック用のレスポンスを生成するクラスです。
public class MockResponseBuilder {

    /// モック用のレスポンスを生成します。
    ///
    /// - Parameter contents: レスポンスの持つbodyがjson型式である場合の構造
    /// - Parameter statusCode: レスポンスのHTTPステータスコード
    /// - Returns: モック用のレスポンス
    public class func createResponse(
            contents: [String : Any],
            statusCode: Int) -> NCMBResponse {
        let header : [String : String] = [:]
        let httpUrlResponse = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: header)!
        return try! NCMBResponse(contents: contents, response: httpUrlResponse)
    }

    /// モック用のレスポンスを生成します。
    ///
    /// - Parameter body: レスポンスの持つbody
    /// - Parameter statusCode: レスポンスのHTTPステータスコード
    /// - Returns: モック用のレスポンス
    public class func createResponse(
            body: Data?,
            statusCode: Int) -> NCMBResponse {
        let header : [String : String] = [:]
        let httpUrlResponse = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: header)!
        return try! NCMBResponse(body: body, response: httpUrlResponse)
    }
}
