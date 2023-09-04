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

/// NCMBPointer のテストクラスです。
final class NCMBPointerTests: NCMBTestCase {

    func test_createInstance_success() {
        var object : [String : Any] = [:]
        object["__type"] = "Pointer"
        object["className"] = "TestClass"
        object["objectId"] = "abcde12345"
        let pointer : NCMBPointer? = NCMBPointer.createInstance(object: object)
        XCTAssertEqual(pointer!.className, "TestClass")
        XCTAssertEqual(pointer!.objectId, "abcde12345")
    }

    func test_createInstance_notDictionary() {
        let pointer : NCMBPointer?
            = NCMBPointer.createInstance(object: "{\"__type\":\"Pointer\",\"objectId\":35.6666269,\"className\":139.765607}")
        XCTAssertNil(pointer)
    }

    func test_createInstance_lackingTypeField() {
        var object : [String : Any] = [:]
        object["className"] = "TestClass"
        object["objectId"] = "abcde12345"
        let pointer : NCMBPointer? = NCMBPointer.createInstance(object: object)
        XCTAssertNil(pointer)
    }

    func test_createInstance_TypeFieldIsNotPointer() {
        var object : [String : Any] = [:]
        object["__type"] = "Date"
        object["className"] = "TestClass"
        object["objectId"] = "abcde12345"
        let pointer : NCMBPointer? = NCMBPointer.createInstance(object: object)
        XCTAssertNil(pointer)
    }

    func test_createInstance_lackingClassNameField() {
        var object : [String : Any] = [:]
        object["__type"] = "Pointer"
        object["objectId"] = "abcde12345"
        let pointer : NCMBPointer? = NCMBPointer.createInstance(object: object)
        XCTAssertNil(pointer)
    }

    func test_createInstance_classNameFieldIsNotString() {
        var object : [String : Any] = [:]
        object["__type"] = "Pointer"
        object["className"] = 123456
        object["objectId"] = "abcde12345"
        let pointer : NCMBPointer? = NCMBPointer.createInstance(object: object)
        XCTAssertNil(pointer)
    }

    func test_createInstance_lackingObjectIdField() {
        var object : [String : Any] = [:]
        object["__type"] = "Pointer"
        object["className"] = "TestClass"
        let pointer : NCMBPointer? = NCMBPointer.createInstance(object: object)
        XCTAssertNil(pointer)
    }

    func test_createInstance_objectIdFieldIsNotString() {
        var object : [String : Any] = [:]
        object["__type"] = "Pointer"
        object["className"] = "TestClass"
        object["objectId"] = 123456
        let pointer : NCMBPointer? = NCMBPointer.createInstance(object: object)
        XCTAssertNil(pointer)
    }

    func test_initialize_success() {
        let object : NCMBObject = NCMBObject(className: "TestClass")
        object.objectId = "abcde12345"
        let pointer : NCMBPointer? = NCMBPointer(dataobject: object)
        XCTAssertEqual(pointer!.className, "TestClass")
        XCTAssertEqual(pointer!.objectId, "abcde12345")
    }
    
    func test_initialize_lackingObjectIdField() {
        let object : NCMBObject = NCMBObject(className: "TestClass")
        object.objectId = nil
        let pointer : NCMBPointer? = NCMBPointer(dataobject: object)
        XCTAssertNil(pointer)
    }
    
    func test_initialize_Installation(){
        let installation : NCMBInstallation = NCMBInstallation()
        installation.objectId = "abcde12345"
        let pointer : NCMBPointer? = NCMBPointer(dataobject: installation)
        XCTAssertEqual(pointer!.className, "installation")
        XCTAssertEqual(pointer!.objectId, "abcde12345")
    }

    func test_initialize_User(){
        let user : NCMBUser = NCMBUser()
        user.objectId = "abcde12345"
        let pointer : NCMBPointer? = NCMBPointer(dataobject: user)
        XCTAssertEqual(pointer!.className, "user")
        XCTAssertEqual(pointer!.objectId, "abcde12345")
    }
    
    func test_toObject() {
        let pointer = NCMBPointer(className: "TestClass", objectId: "abcde12345")
        let object : [String : Any] = pointer.toObject()
        XCTAssertEqual(object["__type"]! as! String, "Pointer")
        XCTAssertEqual(object["className"]! as! String, "TestClass")
        XCTAssertEqual(object["objectId"]! as! String, "abcde12345")
    }
    
    func test_equatable() {
        let lhs : NCMBPointer = NCMBPointer(className: "test", objectId: "hogehoge12345678")
        let rhs1 : NCMBPointer = NCMBPointer(className: "test", objectId: "hogehoge12345678")
        
        XCTAssertEqual(lhs, rhs1)
    }

    func test_NO_equatable_className() {
        let lhs : NCMBPointer = NCMBPointer(className: "test", objectId: "hogehoge12345678")
        let rhs1 : NCMBPointer = NCMBPointer(className: "hoge", objectId: "hogehoge12345678")
        XCTAssertNotEqual(lhs, rhs1)
    }
    
    func test_NO_equatable_objectId() {
        let lhs : NCMBPointer = NCMBPointer(className: "test", objectId: "hogehoge12345678")
        let rhs2 : NCMBPointer = NCMBPointer(className: "test", objectId: "hogehoge1234hoge")
        XCTAssertNotEqual(lhs, rhs2)
    }
    
    func test_NO_equatable_all() {
        let lhs : NCMBPointer = NCMBPointer(className: "test", objectId: "hogehoge12345678")
        let rhs3 : NCMBPointer = NCMBPointer(className: "hoge", objectId: "hogehoge1234hoge")
        XCTAssertNotEqual(lhs, rhs3)
    }
    

    static var allTests = [
        ("test_createInstance_success", test_createInstance_success),
        ("test_createInstance_notDictionary", test_createInstance_notDictionary),
        ("test_createInstance_lackingTypeField", test_createInstance_lackingTypeField),
        ("test_createInstance_TypeFieldIsNotPointer", test_createInstance_TypeFieldIsNotPointer),
        ("test_createInstance_lackingClassNameField", test_createInstance_lackingClassNameField),
        ("test_createInstance_classNameFieldIsNotString", test_createInstance_classNameFieldIsNotString),
        ("test_createInstance_lackingObjectIdField", test_createInstance_lackingObjectIdField),
        ("test_createInstance_objectIdFieldIsNotString", test_createInstance_objectIdFieldIsNotString),
        ("test_toObject", test_toObject),
    ]
}
