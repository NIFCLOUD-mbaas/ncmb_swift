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

/// フィールドが持つ配列に要素を追加する処理を行うための構造体です。
public struct NCMBAddRelationOperator {
    static let TYPENAME : String = "AddRelation"
    static let CLASSNAME_FIELD_NAME : String = "className"
    static let CLASSNAME_OBJECTID : String = "objects"

    /// フィールドへの追加対象の要素配列を定義
    public var elements : [NCMBPointer]

    /// イニシャライズです。
    ///
    /// - Parameter elements: フィールドへの追加対象の要素配列。ポインタの配列
    public init(elements: [NCMBPointer] = []) {
        self.elements = elements
    }

    // 渡されたJsonオブジェクトをNCMBAddRelationOperatorに変換する
    static func createInstance(object: Any) -> NCMBAddRelationOperator? {
        if let object = object as? [String : Any] {
            if checkType(object: object) {
            // AddRelationか確認
                if let elements = getElements(object: object) {
                    return NCMBAddRelationOperator(elements: elements)
                }
            }
        }
        return nil
    }
    
    // 渡されたJsonオブジェクトがcreateInstanceで変換可能かチェック
    private static func checkType(object: [String : Any]) -> Bool {
        return NCMBFieldTypeUtil.checkOperationField(object: object, typename: TYPENAME)
    }
        
    // 渡されたJsonオブジェクトから使用するメンバ変数elementsを取得
    private static func getElements(object : [String : Any]) -> [NCMBPointer]? {
        if let elements = object["objects"]{
            if let elements = elements as? Array<Any>{
                var pointers : Array<NCMBPointer> = []
                for data in elements{
                    if let element = NCMBPointer.createInstance(object: data){
                        pointers.append(element)
                    }
                }
                return pointers
            }
            
        }
        return nil
    }

    // Jsonオブジェクトを返す。辞書型にする。
    func toObject() -> [String : Any] {
        var object : [String : Any] = NCMBFieldTypeUtil.createOperatorObjectBase(typename: NCMBAddRelationOperator.TYPENAME)
        // オブジェクト内のポインタをStringにする
        var values : [[String : Any]] = []
        for data in elements{
                values.append(data.toObject())
        }
        object[NCMBAddRelationOperator.CLASSNAME_OBJECTID] = values
        return object
    }

}
