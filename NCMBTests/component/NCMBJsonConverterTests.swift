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

/// NCMBJsonConverter のテストクラスです。
final class NCMBJsonConverterTests: NCMBTestCase {

    func test_convertToKeyValue_nil() {
        let body : Data? = nil
        XCTAssertEqual(try NCMBJsonConverter.convertToKeyValue(body).count, 0)
    }

    func test_convertToKeyValue_empty() {
        let body : Data? = "{}".data(using: .utf8)!
        XCTAssertEqual(try NCMBJsonConverter.convertToKeyValue(body).count, 0)
    }

    func test_convertToKeyValue_invalidJson() {
        let body : Data? = "{\"takanokun\":\"takano_san\"".data(using: .utf8)!
        XCTAssertThrowsError(try NCMBJsonConverter.convertToKeyValue(body))
    }

    func test_convertToKeyValue_notKeyValue() {
        let body : Data? = "[\"takanokun\",\"takano_san\"]".data(using: .utf8)!
        XCTAssertThrowsError(try NCMBJsonConverter.convertToKeyValue(body)){ error in
            XCTAssertEqual(error as! NCMBParseError, NCMBParseError.unsupportJsonFormat)
        }
    }

    func test_convertToKeyValue_normal() {
        let body : Data? = "{\"takanokun\":\"takano_san\"}".data(using: .utf8)!
        let keyvalue = try! NCMBJsonConverter.convertToKeyValue(body)
        XCTAssertEqual(keyvalue.keys.count, 1)
        let value = keyvalue["takanokun"] as? String
        XCTAssertEqual(value, "takano_san")
    }

    func test_convertToJson() {
        let object : [String : Any] = ["a":"b", "c":42]
        let json : Data = try! NCMBJsonConverter.convertToJson(object)!
        let jsonString : String = String(data: json, encoding: .utf8)!
        XCTAssertNotNil(jsonString.range(of: "\"a\":\"b\""))
        XCTAssertNotNil(jsonString.range(of: "\"c\":42"))
    }

    func test_convertToJson_optional() {
        let object : [String : Any?] = ["a":"b", "c":nil, "d":42]
        let json : Data = try! NCMBJsonConverter.convertToJson(object)!
        let jsonString : String = String(data: json, encoding: .utf8)!
        XCTAssertNotNil(jsonString.range(of: "\"a\":\"b\""))
        XCTAssertNotNil(jsonString.range(of: "\"c\":null"))
        XCTAssertNotNil(jsonString.range(of: "\"d\":42"))
    }

    static var allTests = [
        ("test_convertToKeyValue_nil", test_convertToKeyValue_nil),
        ("test_convertToKeyValue_empty", test_convertToKeyValue_empty),
        ("test_convertToKeyValue_invalidJson", test_convertToKeyValue_invalidJson),
        ("test_convertToKeyValue_notKeyValue", test_convertToKeyValue_notKeyValue),
        ("test_convertToKeyValue_normal", test_convertToKeyValue_normal),
        ("test_convertToJson", test_convertToJson),
        ("test_convertToJson_optional", test_convertToJson_optional),
    ]
}
