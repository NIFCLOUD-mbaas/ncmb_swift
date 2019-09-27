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

/// ポインタ型のフィールドを操作するための構造体です。
public struct NCMBPointer : Equatable {
    static let TYPENAME : String = "Pointer"
    static let CLASSNAME_FIELD_NAME : String = "className"
    static let OBJECTID_FIELD_NAME : String = "objectId"

    /// ポインタ指示先のクラス名
    public var className : String

    /// ポインタ指示先のオブジェクトID
    public var objectId : String

    /// イニシャライズです。
    ///
    /// - Parameter className: ポインタ指示先のクラス名
    /// - Parameter objectId: ポインタ指示先のオブジェクトID
    public init(className: String, objectId: String) {
        self.className = className
        self.objectId = objectId
    }
    
    /// イニシャライズです。
    /// objectIdが無いものを引数として渡すとnilが返る
    ///
    /// - Parameter dataobject: ポインタ指示先のオブジェクト
    public init?(dataobject: NCMBBase){
        if let objectIdInitializar:String = dataobject.objectId  {
            self.className = dataobject.className
            self.objectId = objectIdInitializar
        }
        else {
            return nil
        }
    }

    static func createInstance(object: Any) -> NCMBPointer? {
        if let object = object as? [String : Any] {
            if checkType(object: object) {
                if let className = getClassName(object: object) {
                    if let objectId = getObjectId(object: object) {
                        return NCMBPointer(className: className, objectId: objectId)
                    }
                }
            }
        }
        return nil
    }

    private static func checkType(object: [String : Any]) -> Bool {
        return NCMBFieldTypeUtil.checkTypeField(object: object, typename: TYPENAME)
    }

    private static func getClassName(object: [String : Any]) -> String? {
        return NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: NCMBPointer.CLASSNAME_FIELD_NAME)
    }

    private static func getObjectId(object: [String : Any]) -> String? {
        return NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: NCMBPointer.OBJECTID_FIELD_NAME)
    }

    func toObject() -> [String : Any] {
        var object : [String : Any] = NCMBFieldTypeUtil.createTypeObjectBase(typename: NCMBPointer.TYPENAME)
        object[NCMBPointer.CLASSNAME_FIELD_NAME] = self.className
        object[NCMBPointer.OBJECTID_FIELD_NAME] = self.objectId
        return object
    }
    
    // 同値であるかチェック
    public static func == (lhs: NCMBPointer, rhs: NCMBPointer) -> Bool{
        return
            lhs.className == rhs.className &&
            lhs.objectId == rhs.objectId
    }
    
}
