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

/// NCMBDateField のテストクラスです。
final class NCMBDateFieldTests: NCMBTestCase {

    func test_init() {
        let sut = NCMBDateField(date: Date(timeIntervalSince1970: 507904496.789))
        XCTAssertEqual(sut.date, Date(timeIntervalSince1970: 507904496.789))
    }

    func test_createInstance_success() {
        var object : [String : Any] = [:]
        object["__type"] = "Date"
        object["iso"] = "1986-02-04T12:34:56.789Z"
        let dateField : NCMBDateField? = NCMBDateField.createInstance(object: object)
        XCTAssertEqual(dateField!.date, Date(timeIntervalSince1970: 507904496.789))
    }

    func test_createInstance_notDictionary() {
        let dateField : NCMBDateField?
            = NCMBDateField.createInstance(object: "{\"__type\":\"Date\",\"iso\":\"1986-02-04T12:34:56.789Z\"}")
        XCTAssertNil(dateField)
    }

    func test_createInstance_lackingTypeField() {
        var object : [String : Any] = [:]
        object["iso"] = "1986-02-04T12:34:56.789Z"
        let dateField : NCMBDateField? = NCMBDateField.createInstance(object: object)
        XCTAssertNil(dateField)
    }

    func test_createInstance_TypeFieldIsNotDate() {
        var object : [String : Any] = [:]
        object["__type"] = "Pointer"
        object["iso"] = "1986-02-04T12:34:56.789Z"
        let dateField : NCMBDateField? = NCMBDateField.createInstance(object: object)
        XCTAssertNil(dateField)
    }

    func test_createInstance_lackingIsoField() {
        var object : [String : Any] = [:]
        object["__type"] = "Date"
        let dateField : NCMBDateField? = NCMBDateField.createInstance(object: object)
        XCTAssertNil(dateField)
    }

    func test_createInstance_invalidIsoField() {
        var object : [String : Any] = [:]
        object["__type"] = "Date"
        object["iso"] = "1986_02_04_12_34_56_789A"
        let dateField : NCMBDateField? = NCMBDateField.createInstance(object: object)
        XCTAssertNil(dateField)
    }

    func test_convertObject() {
        let object : [String : Any] = NCMBDateField.convertObject(date: Date(timeIntervalSince1970: 507904496.789))
        XCTAssertEqual(object["__type"]! as! String, "Date")
        XCTAssertEqual(object["iso"]! as! String, "1986-02-04T12:34:56.789Z")
    }

    static var allTests = [
        ("test_init", test_init),
        ("test_createInstance_success", test_createInstance_success),
        ("test_createInstance_notDictionary", test_createInstance_notDictionary),
        ("test_createInstance_lackingTypeField", test_createInstance_lackingTypeField),
        ("test_createInstance_TypeFieldIsNotDate", test_createInstance_TypeFieldIsNotDate),
        ("test_createInstance_lackingIsoField", test_createInstance_lackingIsoField),
        ("test_createInstance_invalidIsoField", test_createInstance_invalidIsoField),
        ("test_convertObject", test_convertObject),
    ]
}
