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

/// データストアの検索を行うクラスです。
public struct NCMBQuery<T : NCMBBase> {

    let className : String
    let service : NCMBRequestServiceProtocol
    var whereItems : [String : Any] = [:]
    var isCount : Bool = false

    /// オブジェクト取得時の並び順です。
    /// フィールド名（文字列）の配列として設定し、降順の場合はフィールド名の先頭に"-"（マイナス）をつけてください。
    public var order : [String] = []

    /// オブジェクト取得時の開始位置です。
    public var skip : Int? = nil

    /// オブジェクト取得時の取得件数です。
    public var limit : Int? = nil

    /// 検索条件の key-value オブジェクトです。 `NCMBRequest` にて使用します。
    var requestItems : [String : String?] {
        get {
            var items : [String : String?] = [:]
            for (key, value) in self.query {
                items[key] = convertAnyToString(value)
            }
            return items
        }
    }

    /// 指定された値を 検索条件を表すJsonで使用できる値に変換します。
    ///
    /// - Parameter value: 変換対象の値
    /// - Returns: 変換後の値
    func convertAnyToString(_ value: Any?) -> String? {
        if let value = value {
            do {
                if let value = value as? String {
                    return value
                }
                if let value = value as? Int {
                    return String(value)
                }
                let data : Data? = try JSONSerialization.data(withJSONObject: value, options: [])
                if let data = data {
                    return String(data: data, encoding: .utf8)
                }
            } catch _ {
            }
        }
        return nil
    }

    /// 検索条件の key-value オブジェクトです。
    var query : [String : Any?] {
        get {
            var items : [String : Any?] = [:]
            if 0 < whereItems.count {
                items[NCMBQueryConstants.REQUEST_PARAMETER_WHERE] = whereItems
            }
            if let skip = self.skip {
                items[NCMBQueryConstants.REQUEST_PARAMETER_SKIP] = skip
            }
            if let limit = self.limit {
                items[NCMBQueryConstants.REQUEST_PARAMETER_LIMIT] = limit
            }
            if self.isCount {
                items[NCMBQueryConstants.REQUEST_PARAMETER_COUNT] = 1 as Int
            }
            if 0 < self.order.count {
                items[NCMBQueryConstants.REQUEST_PARAMETER_ORDER] = self.order.joined(separator: ",")
            }
            return items
        }
    }

    /// データストア用の検索条件クラスを生成します。
    ///
    /// - Parameter className: 検索対象のクラス名
    /// - Returns: 検索条件クラス
    public static func getQuery(className: String) -> NCMBQuery<NCMBObject> {
        return NCMBQuery<NCMBObject>(className: className)
    }

    /// データストア用の検索条件クラスを生成します。
    ///
    /// - Parameter className: 検索対象のクラス名
    private init(className: String) {
        self.className = className
        self.service = NCMBObjectService()
    }

    /// イニシャライズです。
    /// 指定されたサービスに対応する検索条件クラスを生成します。
    ///
    /// - Parameter service: 検索リクエスト時に使用するサービス
    init(service: NCMBRequestServiceProtocol) {
        self.className = ""
        self.service = service
    }

    /// イニシャライズです。
    /// 指定されたサービスに対応する検索条件クラスを生成します。
    ///
    /// - Parameters:
    ///   - className: クラス名
    ///   - service: 検索リクエスト時に使用するサービス
    ///   - whereItems: 検索条件
    ///   - isCount: true のときカウントを行う
    ///   - order: 結果のソート順
    ///   - skip: 検索開始位置
    ///   - limit: 取得件数の上限
    init(className: String,
        service: NCMBRequestServiceProtocol,
        whereItems: [String : Any] = [:],
        isCount: Bool = false,
        order: [String] = [],
        skip: Int? = nil,
        limit: Int? = nil) {
        self.className = className
        self.service = service
        self.whereItems = whereItems
        self.isCount = isCount
        self.order = order
        self.skip = skip
        self.limit = limit
    }

    /// 検索を同期処理にて行います。
    ///
    /// - Returns: リクエストが成功した場合は `.success<[T]>` 、 失敗した場合は `.failure<Error>`
    public func find() -> NCMBResult<[T]> {
        var result : NCMBResult<[T]> = NCMBResult.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        findInBackground(callback: {(res: NCMBResult<[T]>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// 検索を非同期処理にて行います。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func findInBackground(callback: @escaping NCMBHandler<[T]> ) -> Void {
        service.find(query: self, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    let objects : [T] = self.getResultObjects(response: response)
                    callback(NCMBResult<[T]>.success(objects))
                    break
                case let .failure(error):
                    callback(NCMBResult<[T]>.failure(error))
                    break
            }
        })
    }

    /// 条件を満たすオブジェクトの数を同期処理にて検索し、返します。
    ///
    /// - Returns: リクエストが成功した場合は `.success<Int>` 、 失敗した場合は `.failure<Error>`
    public func count() -> NCMBResult<Int> {
        var result : NCMBResult<Int> = NCMBResult.failure(NCMBApiErrorCode.genericError)
        let semaphore = DispatchSemaphore(value: 0)
        countInBackground(callback: {(res: NCMBResult<Int>) -> Void in
            result = res
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }

    /// 条件を満たすオブジェクトの数を非同期処理にて検索し、返します。
    ///
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    public func countInBackground(callback: @escaping NCMBHandler<Int> ) -> Void {
        service.find(
                query: self.createCountQuery(),
                callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            switch result {
                case let .success(response):
                    let count : Int = self.getResultCount(response: response)
                    callback(NCMBResult<Int>.success(count))
                    break
                case let .failure(error):
                    callback(NCMBResult<Int>.failure(error))
                    break
            }
        })
    }

    /// レスポンスの内容から、検索結果を生成します。
    ///
    /// - Parameter response: レスポンス
    /// - Returns: 検索結果の配列（条件を満たすオブジェクトが存在しない場合は空の配列）
    func getResultObjects(response: NCMBResponse) -> [T] {
        if let collection = response.contents[NCMBQueryConstants.RESPONSE_PARAMTER_RESULTS] as? [Any] {
            var results : [T] = []
            for item in collection {
                if let item = item as? [String : Any] {
                    results.append(T.init(className: self.className, fields: item))
                }
            }
            return results
        }
        return []
    }

    /// レスポンスの内容から、条件を満たすオブジェクトの数を返します。
    ///
    /// - Parameter response: レスポンス
    /// - Returns: 条件を満たすオブジェクトの数
    func getResultCount(response: NCMBResponse) -> Int {
        if let count = response.contents[NCMBQueryConstants.RESPONSE_PARAMTER_COUNT] as? Int {
            return count
        }
        return 0
    }

    /// 条件を満たすオブジェクトの数を調べるためのクエリを生成します。
    ///
    /// - Returns: 条件を満たすオブジェクトの数を調べるためのクエリ
    func createCountQuery() -> NCMBQuery<T> {
        var countQuery : NCMBQuery<T> = self
        countQuery.isCount = true
        countQuery.limit = 0
        countQuery.order = []
        countQuery.skip = nil
        return countQuery
    }

    /// 条件を追加します。
    ///
    /// - Parameter field: フィールド名
    /// - Parameter operation: オペレータ
    /// - Parameter value: 対応する値
    mutating func addOperation(field: String, operation: String, value: Any) -> Void {
        var item : [String : Any] = getFieldItem(field: field)
        item[operation] = convertToObject(value: value)
        self.whereItems[field] = item
    }

    /// 指定されたフィールドに対応する検索条件を返します。
    ///
    /// - Parameter field: フィールド名
    /// - Returns: フィールドに対応する検索条件
    func getFieldItem(field: String) -> [String : Any] {
        if let item = self.whereItems[field] {
            if let item = item as? [String : Any] {
                return item
            }
        }
        return [:]
    }

    /// 指定された値を mobile backend の検索条件に使用できる値に変換します。
    ///
    /// - Parameter value: 対象の値
    /// - Returns: 変換後の値
    func convertToObject(value: Any) -> Any {
        if let object = NCMBFieldTypeConverter.converToObject(value: value) {
            return object
        }
        return value
    }

    /// 「フィールドの値が指定された値と一致するオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する値
    public mutating func `where`(field: String, equalTo value: Any) -> Void {
        self.whereItems[field] = convertToObject(value: value)
    }

    /// 「フィールドの値が指定された値と一致しないオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する値
    public mutating func `where`(field: String, notEqualTo value: Any) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_NE, value: value)
    }

    /// 「フィールドの値が指定された値より少ないオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する値
    public mutating func `where`(field: String, lessThan value: Any) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_LT, value: value)
    }

    /// 「フィールドの値が指定された値より多いオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する値
    public mutating func `where`(field: String, greaterThan value: Any) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_GT, value: value)
    }

    /// 「フィールドの値が指定された値より少ないか一致するオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する値
    public mutating func `where`(field: String, lessThanOrEqualTo value: Any) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_LTE, value: value)
    }

    /// 「フィールドの値が指定された値より多いか一致するオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する値
    public mutating func `where`(field: String, greaterThanOrEqualTo value: Any) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_GTE, value: value)
    }

    /// 「フィールドの値が指定された配列に含まれるオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する配列
    public mutating func `where`(field: String, containedIn value: [Any]) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_IN, value: value)
    }

    /// 「フィールドの値が指定された配列に含まれないオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する配列
    public mutating func `where`(field: String, notContainedIn value: [Any]) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_NIN, value: value)
    }

    /// 「フィールドの値が指定された値を持つオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する値
    public mutating func `where`(field: String, exists value: Any) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_EXISTS, value: value)
    }

    /// 「フィールドの値が指定されたパターンを満たすオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応するパターン
    public mutating func `where`(field: String, toMatchPattern value: String) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_REGEX, value: value)
    }

    /// 「フィールドの持つ配列が指定された配列にいずれかが含まれるオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する配列
    public mutating func `where`(field: String, containedInArrayTo value: [Any]) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_INARRAY, value: value)
    }

    /// 「フィールドの持つ配列が指定された配列にいずれも含まれないオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する配列
    public mutating func `where`(field: String, notContainedInArrayTo value: [Any]) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_NINARRAY, value: value)
    }

    /// 「フィールドの持つ配列が指定された配列にすべて含まれるオブジェクト」となる検索条件を追加します。
    ///
    /// - Parameter field: 対象のフィールド名
    /// - Parameter value: 対応する配列
    public mutating func `where`(field: String, containsAllObjectsInArrayTo value: [Any]) -> Void {
        self.addOperation(field: field, operation: NCMBQueryConstants.OPERATOR_ALL, value: value)
    }

    /// 指定された条件から、いずれかを満たす条件を生成します。
    ///
    /// - Parameter mainQuery: 条件
    /// - Parameter subQueries: 条件
    /// - Parameter callback: レスポンス取得後に実行されるコールバックです。
    /// - Returns: 指定された条件について、いずれかを満たす条件
    public static func orQuery(_ mainQuery: NCMBQuery, _ subQueries: NCMBQuery...) -> NCMBQuery {
        var items : [Any] = [mainQuery.whereItems]
        for subQuery in subQueries {
            items.append(subQuery.whereItems)
        }
        var query = NCMBQuery(className: mainQuery.className)
        query.whereItems = [NCMBQueryConstants.OPERATOR_OR:items]
        return query
    }


}

/// NCMBQueryで使用するコンスタント値を管理するクラスです。
private class NCMBQueryConstants {
    static let REQUEST_PARAMETER_WHERE : String = "where"
    static let REQUEST_PARAMETER_ORDER : String = "order"
    static let REQUEST_PARAMETER_SKIP : String = "skip"
    static let REQUEST_PARAMETER_LIMIT : String = "limit"
    static let REQUEST_PARAMETER_COUNT : String = "count"
    static let RESPONSE_PARAMTER_RESULTS : String = "results"
    static let RESPONSE_PARAMTER_COUNT : String = "count"
    static let OPERATOR_NE : String = "$ne"
    static let OPERATOR_LT : String = "$lt"
    static let OPERATOR_GT : String = "$gt"
    static let OPERATOR_LTE : String = "$lte"
    static let OPERATOR_GTE : String = "$gte"
    static let OPERATOR_IN : String = "$in"
    static let OPERATOR_NIN : String = "$nin"
    static let OPERATOR_EXISTS : String = "$exists"
    static let OPERATOR_REGEX : String = "$regex"
    static let OPERATOR_INARRAY : String = "$inArray"
    static let OPERATOR_NINARRAY : String = "$ninArray"
    static let OPERATOR_ALL : String = "$all"
    static let OPERATOR_OR : String = "$or"
}
