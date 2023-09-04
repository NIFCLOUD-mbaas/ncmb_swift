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

/// テストコードで使用する値のチェックなどを管理するユーティリティクラスです。
public class NCMBTestUtil {

    /// 指定された結果が成功かどうかを判定します。
    ///
    /// - Parameter result: 判定する結果
    /// - Returns: 結果の内容が成功の場合は `true` 、 失敗の場合は `false`
    public class func checkResultIsSuccess<T>(result: NCMBResult<T>) -> Bool {
        switch result {
            case .success:
                return true
            default:
                return false
        }
    }

    /// 指定された結果が失敗かどうかを判定します。
    ///
    /// - Parameter result: 判定する結果
    /// - Returns: 結果の内容が失敗の場合は `true` 、 成功の場合は `false`
    public class func checkResultIsFailure<T>(result: NCMBResult<T>) -> Bool {
        switch result {
            case .failure:
                return true
            default:
                return false
        }
    }

    /// 指定された結果から成功時に持つ内容 `T` を取得します。
    ///
    /// - Parameter result: 対象の結果
    /// - Returns: 成功時に持つ内容 `T` 。結果が失敗の場合は `nil`。
    public class func getResponse<T>(result: NCMBResult<T>) -> T? {
        switch result {
            case let .success(response):
                return response
            default:
                return nil
        }
    }

    /// 指定された結果からエラー内容を取得します。
    ///
    /// - Parameter result: 対象の結果
    /// - Returns: エラー内容結果。結果が成功の場合は `nil`。
    public class func getError<T>(result: NCMBResult<T>) -> Error? {
        switch result {
            case let .failure(error):
                return error
            default:
                return nil
        }
    }

    /// 指定された結果から成功時に持つ内容 `T` を取得します。
    ///
    /// - Parameter result: 対象の結果
    /// - Returns: 成功時に持つ内容 `T` 。結果が失敗の場合は `nil`。
    public class func generateApiError(code: String, message: String) -> NCMBApiError {
        var body : [String : Any] = [:]
        body["code"] = code
        body["error"] = message
        return NCMBApiError(body: body)
    }

}
