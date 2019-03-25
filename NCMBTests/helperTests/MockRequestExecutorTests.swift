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

/// MockRequestExecutor のテストクラスです。
final class MockRequestExecutorTests: NCMBTestCase {

    func test_init_default() {
        let request = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"])

        let sut = MockRequestExecutor()

        let expectation : XCTestExpectation? = self.expectation(description: "test_init_default")
        sut.exec(request: request, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_init_parameter() {
        var contents : [String : Any] = [:]
        contents["test1"] = "value1"
        contents["test2"] = 42
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let request = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"])

        let sut = MockRequestExecutor(result: .success(response))

        let expectation : XCTestExpectation? = self.expectation(description: "test_init_parameter")
        sut.exec(request: request, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.response.statusCode, 201)
            XCTAssertEqual(response.contents["test1"] as! String, "value1")
            XCTAssertEqual(response.contents["test2"] as! Int, 42)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_requests_0() {

        let sut = MockRequestExecutor()

        XCTAssertEqual(sut.requests.count, 0)
    }

    func test_requests_1() {
        let request = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"])

        let sut = MockRequestExecutor()

        sut.exec(request: request, callback: {result in })
        XCTAssertEqual(sut.requests.count, 1)
        XCTAssertEqual(sut.requests[0].subpathItems, ["TestClass", "abcdef01"])
    }

    func test_requests_3() {
        let request1 = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"])
        let request2 = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.put,
                subpath: ["TestClass", "ghijkm02"])
        let request3 = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.delete,
                subpath: ["TestClass", "nopqrs03"])

        let sut = MockRequestExecutor()

        sut.exec(request: request1, callback: {result in })
        sut.exec(request: request2, callback: {result in })
        sut.exec(request: request3, callback: {result in })
        XCTAssertEqual(sut.requests.count, 3)
        XCTAssertEqual(sut.requests[0].subpathItems, ["TestClass", "abcdef01"])
        XCTAssertEqual(sut.requests[1].subpathItems, ["TestClass", "ghijkm02"])
        XCTAssertEqual(sut.requests[2].subpathItems, ["TestClass", "nopqrs03"])
    }

    static var allTests = [
        ("test_init_default", test_init_default),
        ("test_init_parameter", test_init_parameter),
        ("test_requests_0", test_requests_0),
        ("test_requests_1", test_requests_1),
        ("test_requests_3", test_requests_3),
    ]
}
