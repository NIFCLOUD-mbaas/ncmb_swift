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

/// NCMBLogoutService のテストクラスです。
final class NCMBLogoutServiceTests: NCMBTestCase {

    func test_logOut_request() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let expectation : XCTestExpectation? = self.expectation(description: "test_logOut_request")
        let sut = NCMBLogoutService()
        sut.logOut(callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.logout)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.get)
            XCTAssertEqual(executor.requests[0].subpathItems, [])
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            XCTAssertNil(executor.requests[0].body)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/logout"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_logOut_recieveResponse() {
        var contents : [String : Any] = [:]
        contents["test1"] = "value1"
        contents["test2"] = 42
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let expectation : XCTestExpectation? = self.expectation(description: "test_logOut_recieveResponse")
        let sut = NCMBLogoutService()
        sut.logOut(callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.contents.count, 2)
            XCTAssertEqual(response.contents["test1"] as! String, "value1")
            XCTAssertEqual(response.contents["test2"] as! Int, 42)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_logOut_invalidRequest() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let expectation : XCTestExpectation? = self.expectation(description: "test_logOut_invalidRequest")
        let sut = NCMBLogoutService()
        sut.logOut(callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_createGetRequest() {
        let sut = NCMBLogoutService()
        let request : NCMBRequest = sut.createGetRequest()
        XCTAssertEqual(request.apiType, NCMBApiType.logout)
        XCTAssertEqual(request.method, NCMBHTTPMethod.get)
        XCTAssertEqual(request.subpathItems, [])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 0)
        XCTAssertNil(request.body)
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/logout"))
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    static var allTests = [
        ("test_logOut_request", test_logOut_request),
        ("test_logOut_recieveResponse", test_logOut_recieveResponse),
        ("test_logOut_invalidRequest", test_logOut_invalidRequest),
        ("test_createGetRequest", test_createGetRequest),
    ]
}
