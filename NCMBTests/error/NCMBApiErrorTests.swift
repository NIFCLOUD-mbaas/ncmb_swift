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

/// NCMBApiError のテストクラスです。
final class NCMBApiErrorTests: NCMBTestCase {

    func test_init_normal() {
        var body : [String : Any] = [:]
        body["code"] = "E404002"
        body["error"] = "None service."
        XCTAssertNotNil(body)
        let sut = NCMBApiError(body: body)
        XCTAssertEqual(sut.errorCode, NCMBApiErrorCode.noneService)
        XCTAssertEqual(sut.message, "None service.")
    }

    func test_init_lackingCode() {
        var body : [String : Any] = [:]
        body["error"] = "None service."
        XCTAssertNotNil(body)
        let sut = NCMBApiError(body: body)
        XCTAssertEqual(sut.errorCode, NCMBApiErrorCode.genericError)
        XCTAssertEqual(sut.message, "None service.")
    }

    func test_init_invalidCode() {
        var body : [String : Any] = [:]
        body["code"] = 404002
        body["error"] = "None service."
        XCTAssertNotNil(body)
        let sut = NCMBApiError(body: body)
        XCTAssertEqual(sut.errorCode, NCMBApiErrorCode.genericError)
        XCTAssertEqual(sut.message, "None service.")
    }

    func test_init_lackingMessage() {
        var body : [String : Any] = [:]
        body["code"] = "E404002"
        XCTAssertNotNil(body)
        let sut = NCMBApiError(body: body)
        XCTAssertEqual(sut.errorCode, NCMBApiErrorCode.noneService)
        XCTAssertEqual(sut.message, "")
    }

    func test_init_invalidMessage() {
        var body : [String : Any] = [:]
        body["code"] = "E404002"
        body["error"] = "None service.".data(using: .utf8)!
        XCTAssertNotNil(body)
        let sut = NCMBApiError(body: body)
        XCTAssertEqual(sut.errorCode, NCMBApiErrorCode.noneService)
        XCTAssertEqual(sut.message, "")
    }

    static var allTests = [
        ("test_init_normal", test_init_normal),
        ("test_init_lackingCode", test_init_lackingCode),
        ("test_init_invalidCode", test_init_invalidCode),
        ("test_init_lackingMessage", test_init_lackingMessage),
        ("test_init_invalidMessage", test_init_invalidMessage),
    ]
}
