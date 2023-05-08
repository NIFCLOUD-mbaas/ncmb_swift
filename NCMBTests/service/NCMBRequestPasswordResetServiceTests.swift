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

/// NCMBRequestPasswordResetService のテストクラスです。
final class NCMBRequestPasswordResetServiceTests: NCMBTestCase {

    func test_send_request() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        var object : [String : Any] = [:]
        object["mail"] = "takanokun@example.com"

        let expectation : XCTestExpectation? = self.expectation(description: "test_send_request")
        let sut = NCMBRequestPasswordResetService()
        sut.send(object: object, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.requestPasswordReset)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
            XCTAssertEqual(executor.requests[0].subpathItems, [])
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            XCTAssertEqual(executor.requests[0].body, "{\"mail\":\"takanokun@example.com\"}".data(using: .utf8))
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/requestPasswordReset"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_send_recieveResponse() {
        var contents : [String : Any] = [:]
        contents["test1"] = "value1"
        contents["test2"] = 42
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        var object : [String : Any] = [:]
        object["mail"] = "takanokun@example.com"

        let expectation : XCTestExpectation? = self.expectation(description: "test_send_recieveResponse")
        let sut = NCMBRequestPasswordResetService()
        sut.send(object: object, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.contents.count, 2)
            XCTAssertEqual(response.contents["test1"] as! String, "value1")
            XCTAssertEqual(response.contents["test2"] as! Int, 42)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_send_invalidRequest() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        var object : [String : Any] = [:]
        object["mail"] = "takanokun@example.com"

        let expectation : XCTestExpectation? = self.expectation(description: "test_send_invalidRequest")
        let sut = NCMBRequestPasswordResetService()
        sut.send(object: object, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_createPostRequest() {
        var object : [String : Any] = [:]
        object["mail"] = "takanokun@example.com"
        let sut = NCMBRequestPasswordResetService()
        let request : NCMBRequest = try! sut.createPostRequest(object: object)
        XCTAssertEqual(request.apiType, NCMBApiType.requestPasswordReset)
        XCTAssertEqual(request.method, NCMBHTTPMethod.post)
        XCTAssertEqual(request.subpathItems, [])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 0)
        XCTAssertEqual(request.body, "{\"mail\":\"takanokun@example.com\"}".data(using: .utf8))
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/requestPasswordReset"))
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    static var allTests = [
        ("test_send_request", test_send_request),
        ("test_send_recieveResponse", test_send_recieveResponse),
        ("test_send_invalidRequest", test_send_invalidRequest),
        ("test_createPostRequest", test_createPostRequest),
    ]
}
