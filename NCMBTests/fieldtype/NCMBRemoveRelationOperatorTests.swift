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


import XCTest
@testable import NCMB

/// NCMBRemoveRelationOperator のテストクラスです。
final class NCMBRemoveRelationOperatorTests: NCMBTestCase {
    
    func test_createInstance_success1() {
        var object : [String : Any] = [:]
        object["__op"] = "RemoveRelation"
        object["className"] = "TestClass"
        
        var pointerJson : [String : Any] = [:]
        pointerJson["__type"] = "Pointer"
        pointerJson["className"] = "TestClass"
        pointerJson["objectId"] = "hogeHOGE12345678"
        
        object["objects"] = [pointerJson]
        
        let removeRelationOperator : NCMBRemoveRelationOperator? = NCMBRemoveRelationOperator.createInstance(object: object)
        XCTAssertEqual(removeRelationOperator!.elements.count, 1)
        XCTAssertEqual(removeRelationOperator!.elements[0] , NCMBPointer(className: "TestClass", objectId: "hogeHOGE12345678"))
    }
    
    func test_createInstance_success0() {
        var object : [String : Any] = [:]
        object["__op"] = "RemoveRelation"
        object["objects"] = []
        let removeRelationOperator : NCMBRemoveRelationOperator? = NCMBRemoveRelationOperator.createInstance(object: object)
        XCTAssertEqual(removeRelationOperator!.elements.count, 0)
    }
    
    func test_createInstance_success3() {
        var object : [String : Any] = [:]
        object["__op"] = "RemoveRelation"
        object["className"] = "TestClass"
        
        var pointerJson1 : [String : Any] = [:]
        pointerJson1["__type"] = "Pointer"
        pointerJson1["className"] = "TestClass"
        pointerJson1["objectId"] = "hogeHOGE12345678"
        
        var pointerJson2 : [String : Any] = [:]
        pointerJson2["__type"] = "Pointer"
        pointerJson2["className"] = "TestClass"
        pointerJson2["objectId"] = "hogeHOGE90123456"
        
        var pointerJson3 : [String : Any] = [:]
        pointerJson3["__type"] = "Pointer"
        pointerJson3["className"] = "TestClass"
        pointerJson3["objectId"] = "hogeFUGA90123456"
        
        object["objects"] = [pointerJson1,pointerJson2,pointerJson3]
        
        let removeRelationOperator : NCMBRemoveRelationOperator? = NCMBRemoveRelationOperator.createInstance(object: object)
        XCTAssertEqual(removeRelationOperator!.elements.count, 3)
        XCTAssertEqual(removeRelationOperator!.elements[0] , NCMBPointer(className: "TestClass", objectId: "hogeHOGE12345678"))
        XCTAssertEqual(removeRelationOperator!.elements[1] , NCMBPointer(className: "TestClass", objectId: "hogeHOGE90123456"))
        XCTAssertEqual(removeRelationOperator!.elements[2] , NCMBPointer(className: "TestClass", objectId: "hogeFUGA90123456"))
    }
    
    func test_createInstance_notDictionary() {
        let removeRelationOperator : NCMBRemoveRelationOperator?
            = NCMBRemoveRelationOperator.createInstance(object: "{\"__op\":\"Add\",\"objects\":[NCMBPointer(className: \"TestClass\", objectId: \"hogeHOGE12345678\")]}")
        XCTAssertNil(removeRelationOperator)
    }
    
    func test_createInstance_lackingOperationField() {
        var object : [String : Any] = [:]
        var pointerJson : [String : Any] = [:]
        pointerJson["__type"] = "Pointer"
        pointerJson["className"] = "TestClass"
        pointerJson["objectId"] = "hogeHOGE12345678"
        
        object["objects"] = [pointerJson]
        
        let removeRelationOperator : NCMBRemoveRelationOperator? = NCMBRemoveRelationOperator.createInstance(object: object)
        XCTAssertNil(removeRelationOperator)
    }
    
    func test_createInstance_OperationFieldIsNotRemoveRelation() {
        var object : [String : Any] = [:]
        object["__op"] = "Date"
        var pointerJson : [String : Any] = [:]
        pointerJson["__type"] = "Pointer"
        pointerJson["className"] = "TestClass"
        pointerJson["objectId"] = "hogeHOGE12345678"
        
        object["objects"] = [pointerJson]
        let removeRelationOperator : NCMBRemoveRelationOperator? = NCMBRemoveRelationOperator.createInstance(object: object)
        XCTAssertNil(removeRelationOperator)
    }
    
    func test_createInstance_lackingObjectsField() {
        var object : [String : Any] = [:]
        object["__op"] = "RemoveRelation"
        let removeRelationOperator : NCMBRemoveRelationOperator? = NCMBRemoveRelationOperator.createInstance(object: object)
        XCTAssertNil(removeRelationOperator)
    }
    
    func test_createInstance_objectsFieldIsNotArray() {
        var object : [String : Any] = [:]
        object["__op"] = "RemoveRelation"
        object["objects"] = "takanokun"
        let removeRelationOperator : NCMBRemoveRelationOperator? = NCMBRemoveRelationOperator.createInstance(object: object)
        XCTAssertNil(removeRelationOperator)
    }
    
    func test_toObject() {
        let removeRelationOperator = NCMBRemoveRelationOperator(elements: [NCMBPointer(className: "TestClass", objectId: "hogeHOGE12345678"), NCMBPointer(className: "TestClass", objectId: "hogeHOGE90123456")])
        var object : [String : Any] = removeRelationOperator.toObject()
        XCTAssertEqual(object["__op"]! as! String, "RemoveRelation")
        XCTAssertEqual((object["objects"]! as! Array<Dictionary<String,Any>>).count, 2)
        
        // 辞書型の配列なので、配列の中の辞書のkeyからvalueを検索して比較する
        XCTAssertEqual((object["objects"]! as! Array<Dictionary<String,Any>>)[0].count, 3)
        XCTAssertEqual((object["objects"]! as! Array<Dictionary<String,Any>>)[0]["__type"] as! String, "Pointer")
        XCTAssertEqual((object["objects"]! as! Array<Dictionary<String,Any>>)[0]["className"] as! String, "TestClass")
        XCTAssertEqual((object["objects"]! as! Array<Dictionary<String,Any>>)[0]["objectId"] as! String, "hogeHOGE12345678")
        
        XCTAssertEqual((object["objects"]! as! Array<Dictionary<String,Any>>)[1].count, 3)
        XCTAssertEqual((object["objects"]! as! Array<Dictionary<String,Any>>)[1]["__type"] as! String, "Pointer")
        XCTAssertEqual((object["objects"]! as! Array<Dictionary<String,Any>>)[1]["className"] as! String, "TestClass")
        XCTAssertEqual((object["objects"]! as! Array<Dictionary<String,Any>>)[1]["objectId"] as! String, "hogeHOGE90123456")
        
    }
    
    
    static var allTests = [
        ("test_createInstance_success1", test_createInstance_success1),
        ("test_createInstance_success0", test_createInstance_success0),
        ("test_createInstance_success3", test_createInstance_success3),
        ("test_createInstance_notDictionary", test_createInstance_notDictionary),
        ("test_createInstance_lackingOperationField", test_createInstance_lackingOperationField),
        ("test_createInstance_OperationFieldIsNotRemoveRelation", test_createInstance_OperationFieldIsNotRemoveRelation),
        ("test_createInstance_lackingObjectsField", test_createInstance_lackingObjectsField),
        ("test_createInstance_objectsFieldIsNotArray", test_createInstance_objectsFieldIsNotArray),
        ("test_toObject", test_toObject),
        ]
}
