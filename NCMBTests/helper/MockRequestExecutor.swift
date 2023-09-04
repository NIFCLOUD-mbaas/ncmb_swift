/*
 Copyright 2019-2023 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

import XCTest
@testable import NCMB

/// テストコード内で使用するリクエスト実行クラスのモックです。
public class MockRequestExecutor : NCMBRequestExecutorProtocol {

    private let result : NCMBResult<NCMBResponse>
    private var _requests : [NCMBRequest]

    /// 実行するために登録されたリクエストです。
    public var requests : [NCMBRequest] {
        get {
            let value : [NCMBRequest] = self._requests
            return value
        }
    }

    /// イニシャライズです。
    ///
    /// - Parameter result: リクエスト処理後に返されるレスポンス
    public init(result: NCMBResult<NCMBResponse>) {
        self.result = result
        self._requests = []
    }

    /// イニシャライズです。
    public required init() {
        self.result = NCMBResult<NCMBResponse>.failure(DummyErrors.dummyError)
        self._requests = []
    }

    /// リクエストを実行します。
    ///
    /// - Parameter request: リクエスト
    /// - Parameter callback: レスポンス取得後に実行されるコールバック。モッククラスであるためメソッド実行後ただちに処理されます。
    public func exec(request: NCMBRequest, callback: @escaping (NCMBResult<NCMBResponse>) -> Void) -> Void {
        self._requests.append(request)
        callback(result)
    }

}
