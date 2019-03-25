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

/// NCMBAddUniqueOperator のテストクラスです。
final class NCMBAddUniqueOperatorTests: NCMBTestCase {

    func test_createInstance_success1() {
        var object : [String : Any] = [:]
        object["__op"] = "AddUnique"
        object["objects"] = ["takanokun"]
        let addUniqueOperator : NCMBAddUniqueOperator? = NCMBAddUniqueOperator.createInstance(object: object)
        XCTAssertEqual(addUniqueOperator!.elements.count, 1)
        XCTAssertEqual(addUniqueOperator!.elements[0] as! String, "takanokun")
    }

    func test_createInstance_success0() {
        var object : [String : Any] = [:]
        object["__op"] = "AddUnique"
        object["objects"] = []
        let addUniqueOperator : NCMBAddUniqueOperator? = NCMBAddUniqueOperator.createInstance(object: object)
        XCTAssertEqual(addUniqueOperator!.elements.count, 0)
    }

    func test_createInstance_success3() {
        var object : [String : Any] = [:]
        object["__op"] = "AddUnique"
        object["objects"] = ["takanokun", "takano_san", "piyo"]
        let addUniqueOperator : NCMBAddUniqueOperator? = NCMBAddUniqueOperator.createInstance(object: object)
        XCTAssertEqual(addUniqueOperator!.elements.count, 3)
        XCTAssertEqual(addUniqueOperator!.elements[0] as! String, "takanokun")
        XCTAssertEqual(addUniqueOperator!.elements[1] as! String, "takano_san")
        XCTAssertEqual(addUniqueOperator!.elements[2] as! String, "piyo")
    }

    func test_createInstance_notDictionary() {
        let addUniqueOperator : NCMBAddUniqueOperator?
            = NCMBAddUniqueOperator.createInstance(object: "{\"__op\":\"AddUnique\",\"objects\":[\"takanokun\"]}")
        XCTAssertNil(addUniqueOperator)
    }

    func test_createInstance_lackingOperationField() {
        var object : [String : Any] = [:]
        object["objects"] = ["takanokun"]
        let addUniqueOperator : NCMBAddUniqueOperator? = NCMBAddUniqueOperator.createInstance(object: object)
        XCTAssertNil(addUniqueOperator)
    }

    func test_createInstance_OperationFieldIsNotAddUnique() {
        var object : [String : Any] = [:]
        object["__op"] = "Date"
        object["objects"] = ["takanokun"]
        let addUniqueOperator : NCMBAddUniqueOperator? = NCMBAddUniqueOperator.createInstance(object: object)
        XCTAssertNil(addUniqueOperator)
    }

    func test_createInstance_lackingObjectsField() {
        var object : [String : Any] = [:]
        object["__op"] = "Date"
        let addUniqueOperator : NCMBAddUniqueOperator? = NCMBAddUniqueOperator.createInstance(object: object)
        XCTAssertNil(addUniqueOperator)
    }

    func test_createInstance_objectsFieldIsNotArray() {
        var object : [String : Any] = [:]
        object["__op"] = "AddUnique"
        object["objects"] = "takanokun"
        let addUniqueOperator : NCMBAddUniqueOperator? = NCMBAddUniqueOperator.createInstance(object: object)
        XCTAssertNil(addUniqueOperator)
    }

    func test_toObject() {
        let addUniqueOperator = NCMBAddUniqueOperator(elements: ["takanokun", "takano_san"])
        var object : [String : Any] = addUniqueOperator.toObject()
        XCTAssertEqual(object["__op"]! as! String, "AddUnique")
        XCTAssertEqual((object["objects"]! as! Array<String>).count, 2)
        XCTAssertEqual((object["objects"]! as! Array<String>)[0], "takanokun")
        XCTAssertEqual((object["objects"]! as! Array<String>)[1], "takano_san")
    }

    func test_toObject_nilArray() {
        let addUniqueOperator = NCMBAddUniqueOperator(elements: [nil,"takanokun",nil])
        var object : [String : Any] = addUniqueOperator.toObject()
        XCTAssertEqual(object["__op"]! as! String, "AddUnique")
        XCTAssertEqual((object["objects"]! as! Array<Any?>).count, 3)
        XCTAssertNil((object["objects"]! as! Array<Any?>)[0])
        XCTAssertEqual((object["objects"]! as! Array<Any?>)[1] as! String, "takanokun")
        XCTAssertNil((object["objects"]! as! Array<Any?>)[2])
    }

    static var allTests = [
        ("test_createInstance_success1", test_createInstance_success1),
        ("test_createInstance_success0", test_createInstance_success0),
        ("test_createInstance_success3", test_createInstance_success3),
        ("test_createInstance_notDictionary", test_createInstance_notDictionary),
        ("test_createInstance_lackingOperationField", test_createInstance_lackingOperationField),
        ("test_createInstance_OperationFieldIsNotAddUnique", test_createInstance_OperationFieldIsNotAddUnique),
        ("test_createInstance_lackingObjectsField", test_createInstance_lackingObjectsField),
        ("test_createInstance_objectsFieldIsNotArray", test_createInstance_objectsFieldIsNotArray),
        ("test_toObject", test_toObject),
        ("test_toObject_nilArray", test_toObject_nilArray),
    ]
}
