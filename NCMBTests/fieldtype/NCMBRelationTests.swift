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

/// NCMBRelation のテストクラスです。
final class NCMBRelationTests: NCMBTestCase {
    
    func test_createInstance_success() {
        var object : [String : Any] = [:]
        object["__type"] = "Relation"
        object["className"] = "TestClass"
        let relation : NCMBRelation? = NCMBRelation.createInstance(object: object)
        XCTAssertEqual(relation!.className, "TestClass")
    }
    
    func test_createInstance_notDictionary() {
        let relation : NCMBRelation?
            = NCMBRelation.createInstance(object: "{\"__type\":\"Relation\",\"className\":139.765607}")
        XCTAssertNil(relation)
    }
    
    func test_createInstance_lackingTypeField() {
        var object : [String : Any] = [:]
        object["className"] = "TestClass"
        let relation : NCMBRelation? = NCMBRelation.createInstance(object: object)
        XCTAssertNil(relation)
    }
    
    func test_createInstance_TypeFieldIsNotRelation() {
        var object : [String : Any] = [:]
        object["__type"] = "Date"
        object["className"] = "TestClass"
        let relation : NCMBRelation? = NCMBRelation.createInstance(object: object)
        XCTAssertNil(relation)
    }
    
    func test_createInstance_lackingClassNameField() {
        var object : [String : Any] = [:]
        object["__type"] = "Relation"
        let relation : NCMBRelation? = NCMBRelation.createInstance(object: object)
        XCTAssertNil(relation)
    }
    
    func test_createInstance_classNameFieldIsNotString() {
        var object : [String : Any] = [:]
        object["__type"] = "Relation"
        object["className"] = 123456
        let relation : NCMBRelation? = NCMBRelation.createInstance(object: object)
        XCTAssertNil(relation)
    }
    
    func test_toObject() {
        let relation = NCMBRelation(className: "TestClass")
        let object : [String : Any] = relation.toObject()
        XCTAssertEqual(object["__type"]! as! String, "Relation")
        XCTAssertEqual(object["className"]! as! String, "TestClass")
    }
    
    static var allTests = [
        ("test_createInstance_success", test_createInstance_success),
        ("test_createInstance_notDictionary", test_createInstance_notDictionary),
        ("test_createInstance_lackingTypeField", test_createInstance_lackingTypeField),
        ("test_createInstance_TypeFieldIsNotRelation", test_createInstance_TypeFieldIsNotRelation),
        ("test_createInstance_lackingClassNameField", test_createInstance_lackingClassNameField),
        ("test_createInstance_classNameFieldIsNotString", test_createInstance_classNameFieldIsNotString),
        ("test_toObject", test_toObject),
        ]
}

