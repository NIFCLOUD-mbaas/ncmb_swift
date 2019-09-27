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

/// リレーション型のフィールドを出力するための構造体です。
public struct NCMBRelation {
    static let TYPENAME : String = "Relation"
    static let CLASSNAME_FIELD_NAME : String = "className"
    
    /// リレーション型のクラス名
    public var className : String
    
    /// イニシャライズです。
    ///
    /// - Parameter className: リレーション型のクラス名
    public init(className: String) {
        self.className = className
    }
    
    static func createInstance(object: Any) -> NCMBRelation? {
        if let object = object as? [String : Any] {
            if checkType(object: object) {
                if let className = getClassName(object: object) {
                        return NCMBRelation(className: className)
                }
            }
        }
        return nil
    }
    
    private static func checkType(object: [String : Any]) -> Bool {
        return NCMBFieldTypeUtil.checkTypeField(object: object, typename: TYPENAME)
    }
    
    private static func getClassName(object: [String : Any]) -> String? {
        return NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: NCMBRelation.CLASSNAME_FIELD_NAME)
    }
    
    func toObject() -> [String : Any] {
        var object : [String : Any] = NCMBFieldTypeUtil.createTypeObjectBase(typename: NCMBRelation.TYPENAME)
        object[NCMBRelation.CLASSNAME_FIELD_NAME] = self.className
        return object
    }
    
}

