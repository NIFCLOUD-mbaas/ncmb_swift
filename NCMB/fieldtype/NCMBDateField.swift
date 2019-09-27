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

/// 日時型のフィールドを操作するための構造体です。
public struct NCMBDateField {
    static let TYPENAME : String = "Date"
    static let ISO_FIELD_NAME : String = "iso"

    /// 日時です。
    public var date : Date

    /// イニシャライズです。
    ///
    /// - Parameter date: 日時
    public init(date: Date) {
        self.date = date
    }

    static func createInstance(object: Any) -> NCMBDateField? {
        if let object = object as? [String : Any] {
            if checkType(object: object) {
                if let date = getDate(object: object) {
                    return NCMBDateField(date: date)
                }
            }
        }
        return nil
    }

    private static func checkType(object: [String : Any]) -> Bool {
        return NCMBFieldTypeUtil.checkTypeField(object: object, typename: TYPENAME)
    }

    private static func getDate(object: [String : Any]) -> Date? {
        if let dateString : String = NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: NCMBDateField.ISO_FIELD_NAME) {
            return NCMBDateFormatter.getDateFromISO8601Timestamp(from: dateString)
        }
        return nil
    }

    static func convertObject(date: Date) -> [String : Any] {
        var object : [String : Any] = NCMBFieldTypeUtil.createTypeObjectBase(typename: NCMBDateField.TYPENAME)
        object[NCMBDateField.ISO_FIELD_NAME] = NCMBDateFormatter.getISO8601Timestamp(date: date)
        return object
    }
}