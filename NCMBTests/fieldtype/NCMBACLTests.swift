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

/// NCMBACL のテストクラスです。
final class NCMBACLTests: NCMBTestCase {

    func test_constant_default() {
        let sut = NCMBACL.default

        XCTAssertEqual(sut.getReadable(key: "*"), true)
        XCTAssertEqual(sut.getWritable(key: "*"), true)
    }

    func test_constant_empty() {
        let sut = NCMBACL.empty

        XCTAssertNil(sut.getReadable(key: "*"))
        XCTAssertNil(sut.getWritable(key: "*"))
    }

    func test_init_default() {
        let sut = NCMBACL.default

        XCTAssertEqual(sut.getReadable(key: "*"), true)
        XCTAssertEqual(sut.getWritable(key: "*"), true)
    }

    func test_init_params() {
        var object : [String : Any] = [:]

        var rw1 : [String : Bool] = [:]
        rw1["read"] = true
        rw1["write"] = false
        object["abcd"] = rw1

        var rw2 : [String : String] = [:]
        rw2["read"] = "true"
        rw2["write"] = "false"
        object["efgh"] = rw2

        var rw3 : [String : Bool] = [:]
        rw3["read"] = false
        rw3["write"] = true
        object["ijkl"] = rw3

        let sut = NCMBACL(object: object)

        XCTAssertEqual(sut.getReadable(key: "abcd"), true)
        XCTAssertEqual(sut.getWritable(key: "abcd"), false)
        XCTAssertNil(sut.getReadable(key: "efgh"))
        XCTAssertNil(sut.getWritable(key: "efgh"))
        XCTAssertEqual(sut.getReadable(key: "ijkl"), false)
        XCTAssertEqual(sut.getWritable(key: "ijkl"), true)
        XCTAssertNil(sut.getReadable(key: "*"))
        XCTAssertNil(sut.getWritable(key: "*"))
    }

    func test_put() {
        var object : [String : Any] = [:]

        var rw1 : [String : Bool] = [:]
        rw1["read"] = true
        rw1["write"] = false
        object["abcd"] = rw1

        var rw2 : [String : Bool] = [:]
        rw2["read"] = true
        rw2["write"] = false
        object["efgh"] = rw2

        var sut = NCMBACL(object: object)
        sut.put(key: "ijkl", readable: false, writable: true)
        sut.put(key: "efgh", readable: false, writable: true)

        XCTAssertEqual(sut.getReadable(key: "abcd"), true)
        XCTAssertEqual(sut.getWritable(key: "abcd"), false)
        XCTAssertEqual(sut.getReadable(key: "efgh"), false)
        XCTAssertEqual(sut.getWritable(key: "efgh"), true)
        XCTAssertEqual(sut.getReadable(key: "ijkl"), false)
        XCTAssertEqual(sut.getWritable(key: "ijkl"), true)
        XCTAssertNil(sut.getReadable(key: "*"))
        XCTAssertNil(sut.getWritable(key: "*"))
    }

    func test_remove() {
        var object : [String : Any] = [:]

        var rw1 : [String : Bool] = [:]
        rw1["read"] = true
        rw1["write"] = false
        object["abcd"] = rw1

        var rw2 : [String : Bool] = [:]
        rw2["read"] = true
        rw2["write"] = false
        object["efgh"] = rw2

        var sut = NCMBACL(object: object)
        sut.remove(key: "efgh")
        sut.remove(key: "ijkl")

        XCTAssertEqual(sut.getReadable(key: "abcd"), true)
        XCTAssertEqual(sut.getWritable(key: "abcd"), false)
        XCTAssertNil(sut.getReadable(key: "efgh"))
        XCTAssertNil(sut.getWritable(key: "efgh"))
        XCTAssertNil(sut.getReadable(key: "ijkl"))
        XCTAssertNil(sut.getWritable(key: "ijkl"))
        XCTAssertNil(sut.getReadable(key: "*"))
        XCTAssertNil(sut.getWritable(key: "*"))
    }

    func test_toObject() {
        var object : [String : Any] = [:]

        var rw1 : [String : Bool] = [:]
        rw1["read"] = true
        rw1["write"] = false
        object["abcd"] = rw1

        var rw2 : [String : String] = [:]
        rw2["read"] = "true"
        rw2["write"] = "false"
        object["efgh"] = rw2

        var rw3 : [String : Bool] = [:]
        rw3["read"] = false
        rw3["write"] = true
        object["ijkl"] = rw3

        var rw4 : [String : Bool] = [:]
        rw4["read"] = false
        rw4["write"] = true
        object["mnop"] = rw4

        var sut = NCMBACL(object: object)

        sut.put(key: "ijkl", readable: false, writable: true)
        sut.put(key: "qrst", readable: false, writable: true)
        sut.remove(key: "mnop")
        sut.remove(key: "uvwx")

        let result : [String : [String : Bool]] = sut.toObject()

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result["abcd"]!.count, 2)
        XCTAssertEqual(result["abcd"]!["read"], true)
        XCTAssertEqual(result["abcd"]!["write"], false)
        XCTAssertNil(result["efgh"])
        XCTAssertEqual(result["ijkl"]!.count, 2)
        XCTAssertEqual(result["ijkl"]!["read"], false)
        XCTAssertEqual(result["ijkl"]!["write"], true)
        XCTAssertNil(result["mnop"])
        XCTAssertEqual(result["qrst"]!.count, 2)
        XCTAssertEqual(result["qrst"]!["read"], false)
        XCTAssertEqual(result["qrst"]!["write"], true)
        XCTAssertNil(result["uvwx"])
        XCTAssertNil(result["*"])

    }

    func test_toObject_default() {
        let sut = NCMBACL.default

        let result : [String : [String : Bool]] = sut.toObject()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result["*"]!.count, 2)
        XCTAssertEqual(result["*"]!["read"], true)
        XCTAssertEqual(result["*"]!["write"], true)
    }

    static var allTests = [
        ("test_constant_default", test_constant_default),
        ("test_constant_empty", test_constant_empty),
        ("test_init_default", test_init_default),
        ("test_init_params", test_init_params),
        ("test_put", test_put),
        ("test_remove", test_remove),
        ("test_toObject", test_toObject),
        ("test_toObject_default", test_toObject_default),
    ]
}
