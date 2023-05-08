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

/// NCMBFieldTypeUtil のテストクラスです。
final class NCMBFieldTypeUtilTests: NCMBTestCase {

    func test_checkTypeField_success() {
        var object : [String : Any] = [:]
        object["__type"] = "Takanokun"
        object["takano_san"] = "abcdefg"
        object["piyo"] = 12345
        XCTAssertEqual(NCMBFieldTypeUtil.checkTypeField(object: object, typename: "Takanokun"), true)
    }

    func test_checkTypeField_lackingTypeField() {
        var object : [String : Any] = [:]
        object["takano_san"] = "abcdefg"
        object["piyo"] = 12345
        XCTAssertEqual(NCMBFieldTypeUtil.checkTypeField(object: object, typename: "Takanokun"), false)
    }

    func test_checkTypeField_typenameMismatch() {
        var object : [String : Any] = [:]
        object["__type"] = "Takano_san"
        object["takano_san"] = "abcdefg"
        object["piyo"] = 12345
        XCTAssertEqual(NCMBFieldTypeUtil.checkTypeField(object: object, typename: "Takanokun"), false)
    }

    func test_getFieldValue_success() {
        var object : [String : Any] = [:]
        object["__type"] = "Takanokun"
        object["takano_san"] = "abcdefg"
        object["piyo"] = 12345
        let value : String? = NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: "takano_san")
        XCTAssertEqual(value, "abcdefg")
    }

    func test_getFieldValue_fieldNotFound() {
        var object : [String : Any] = [:]
        object["__type"] = "Takanokun"
        object["piyo"] = 12345
        let value : String? = NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: "takano_san")
        XCTAssertNil(value)
    }

    func test_getFieldValue_typeMismatch() {
        var object : [String : Any] = [:]
        object["__type"] = "Takanokun"
        object["takano_san"] = 42
        object["piyo"] = 12345
        let value : String? = NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: "takano_san")
        XCTAssertNil(value)
    }

    func test_createTypeObjectBase() {
        let result = NCMBFieldTypeUtil.createTypeObjectBase(typename: "Takanokun")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result["__type"] as! String, "Takanokun")
    }

    func test_createOperatorObjectBase() {
        let result = NCMBFieldTypeUtil.createOperatorObjectBase(typename: "Takanokun")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result["__op"] as! String, "Takanokun")
    }

    static var allTests = [
        ("test_checkTypeField_success", test_checkTypeField_success),
        ("test_checkTypeField_lackingTypeField", test_checkTypeField_lackingTypeField),
        ("test_checkTypeField_typenameMismatch", test_checkTypeField_typenameMismatch),
        ("test_getFieldValue_success", test_getFieldValue_success),
        ("test_getFieldValue_fieldNotFound", test_getFieldValue_fieldNotFound),
        ("test_getFieldValue_typeMismatch", test_getFieldValue_typeMismatch),
        ("test_createTypeObjectBase", test_createTypeObjectBase),
        ("test_createOperatorObjectBase", test_createOperatorObjectBase),
    ]
}
