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

/// NCMBIncrementOperator のテストクラスです。
final class NCMBIncrementOperatorTests: NCMBTestCase {

    func test_createInstance_success_int() {
        var object : [String : Any] = [:]
        object["__op"] = "Increment"
        object["amount"] = 42
        let incrementOperator : NCMBIncrementOperator? = NCMBIncrementOperator.createInstance(object: object)
        XCTAssertEqual(incrementOperator!.amount as! Int, 42)
    }

    func test_createInstance_success_double() {
        var object : [String : Any] = [:]
        object["__op"] = "Increment"
        object["amount"] = 1.23
        let incrementOperator : NCMBIncrementOperator? = NCMBIncrementOperator.createInstance(object: object)
        XCTAssertEqual(incrementOperator!.amount as! Double, 1.23)
    }

    func test_createInstance_notDictionary() {
        let incrementOperator : NCMBIncrementOperator?
            = NCMBIncrementOperator.createInstance(object: "{\"__op\":\"Increment\",\"objects\":[\"takanokun\"]}")
        XCTAssertNil(incrementOperator)
    }


    func test_createInstance_lackingOperationField() {
        var object : [String : Any] = [:]
        object["amount"] = 42
        let incrementOperator : NCMBIncrementOperator? = NCMBIncrementOperator.createInstance(object: object)
        XCTAssertNil(incrementOperator)
    }

    func test_createInstance_OperationFieldIsNotIncrement() {
        var object : [String : Any] = [:]
        object["__op"] = "Date"
        object["amount"] = 42
        let incrementOperator : NCMBIncrementOperator? = NCMBIncrementOperator.createInstance(object: object)
        XCTAssertNil(incrementOperator)
    }

    func test_createInstance_lackingObjectsField() {
        var object : [String : Any] = [:]
        object["__op"] = "Date"
        let incrementOperator : NCMBIncrementOperator? = NCMBIncrementOperator.createInstance(object: object)
        XCTAssertNil(incrementOperator)
    }

    func test_createInstance_objectsFieldIsNotNumeric() {
        var object : [String : Any] = [:]
        object["__op"] = "Increment"
        object["amount"] = "takanokun"
        let incrementOperator : NCMBIncrementOperator? = NCMBIncrementOperator.createInstance(object: object)
        XCTAssertNil(incrementOperator)
    }

    func test_toObject_int() {
        let incrementOperator = NCMBIncrementOperator(amount: 42)
        let object : [String : Any] = incrementOperator.toObject()
        XCTAssertEqual(object["__op"]! as! String, "Increment")
        XCTAssertEqual(object["amount"]! as! Int, 42)
    }

    func test_toObject_double() {
        let incrementOperator = NCMBIncrementOperator(amount: 1.23)
        let object : [String : Any] = incrementOperator.toObject()
        XCTAssertEqual(object["__op"]! as! String, "Increment")
        XCTAssertEqual(object["amount"]! as! Double, 1.23)
    }

    static var allTests = [
        ("test_createInstance_success_int", test_createInstance_success_int),
        ("test_createInstance_success_double", test_createInstance_success_double),
        ("test_createInstance_notDictionary", test_createInstance_notDictionary),
        ("test_createInstance_lackingOperationField", test_createInstance_lackingOperationField),
        ("test_createInstance_OperationFieldIsNotIncrement", test_createInstance_OperationFieldIsNotIncrement),
        ("test_createInstance_lackingObjectsField", test_createInstance_lackingObjectsField),
        ("test_createInstance_objectsFieldIsNotNumeric", test_createInstance_objectsFieldIsNotNumeric),
        ("test_toObject_int", test_toObject_int),
        ("test_toObject_double", test_toObject_double),
    ]
}
