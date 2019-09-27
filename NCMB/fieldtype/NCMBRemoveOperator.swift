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

/// フィールドが持つ配列に要素を削除する処理を行うための構造体です。
public struct NCMBRemoveOperator {
    static let TYPENAME : String = "Remove"
    static let OBJECTS_FIELD_NAME : String = "objects"

    /// フィールドへの削除対象の要素配列です。
    public var elements : [Any?]

    /// イニシャライズです。
    ///
    /// - Parameter elements: フィールドへの削除対象の要素配列
    public init(elements: [Any?] = []) {
        self.elements = elements
    }

    static func createInstance(object: Any) -> NCMBRemoveOperator? {
        if let object = object as? [String : Any] {
            if checkType(object: object) {
                if let elements = getElements(object: object) {
                    return NCMBRemoveOperator(elements: elements)
                }
            }
        }
        return nil
    }

    private static func checkType(object: [String : Any]) -> Bool {
        return NCMBFieldTypeUtil.checkOperationField(object: object, typename: TYPENAME)
    }

    private static func getElements(object: [String : Any]) -> [Any?]? {
        return NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: NCMBRemoveOperator.OBJECTS_FIELD_NAME)
    }

    func toObject() -> [String : Any] {
        var object : [String : Any] = NCMBFieldTypeUtil.createOperatorObjectBase(typename: NCMBRemoveOperator.TYPENAME)
        object[NCMBRemoveOperator.OBJECTS_FIELD_NAME] = self.elements
        return object
    }
}