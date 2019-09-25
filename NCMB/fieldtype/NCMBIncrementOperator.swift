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

/// 数値フィールドに対してインクリメント・デクリメントを行うための構造体です。
public struct NCMBIncrementOperator {
    static let TYPENAME : String = "Increment"
    static let AMOUNT_FIELD_NAME : String = "amount"
    private var _amount : Any

    /// インクリメント・デクリメント量です。
    public var amount : Any {
        get {
            return self._amount
        }
    }

    /// イニシャライズです。
    ///
    /// - Parameter amount: インクリメント・デクリメント量
    public init(amount: Int) {
        self._amount = amount
    }

    /// イニシャライズです。
    ///
    /// - Parameter amount: インクリメント・デクリメント量
    public init(amount: Double) {
        self._amount = amount
    }

    static func createInstance(object: Any) -> NCMBIncrementOperator? {
        if let object = object as? [String : Any] {
            if checkType(object: object) {
                if let amount = getAmountInt(object: object) {
                    return NCMBIncrementOperator(amount: amount)
                }
                if let amount = getAmountDouble(object: object) {
                    return NCMBIncrementOperator(amount: amount)
                }
            }
        }
        return nil
    }

    private static func checkType(object: [String : Any]) -> Bool {
        return NCMBFieldTypeUtil.checkOperationField(object: object, typename: TYPENAME)
    }

    private static func getAmountInt(object: [String : Any]) -> Int? {
        return NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: NCMBIncrementOperator.AMOUNT_FIELD_NAME)
    }

    private static func getAmountDouble(object: [String : Any]) -> Double? {
        return NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: NCMBIncrementOperator.AMOUNT_FIELD_NAME)
    }

    func toObject() -> [String : Any] {
        var object : [String : Any] = NCMBFieldTypeUtil.createOperatorObjectBase(typename: NCMBIncrementOperator.TYPENAME)
        object[NCMBIncrementOperator.AMOUNT_FIELD_NAME] = self._amount
        return object
    }
}