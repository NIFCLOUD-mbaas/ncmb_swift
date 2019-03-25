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

/// NCMBScriptService のテストクラスです。
final class NCMBScriptServiceTests: NCMBTestCase {

    func test_init() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut = NCMBScriptService(method: NCMBHTTPMethod.put, endpoint: "https://piyo.example.com", apiVersion: "1986-02-04")

        let expectation : XCTestExpectation? = self.expectation(description: "test_init")
        sut.executeScript(name: "takanokun.js", headers: [:], queries: [:], body: nil, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://piyo.example.com/1986-02-04/script/takanokun.js"))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_executeScript_request() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut = NCMBScriptService(method: NCMBHTTPMethod.get, endpoint: "https://piyo.example.com", apiVersion: "1986-02-04")

        let expectation : XCTestExpectation? = self.expectation(description: "test_executeScript_request")
        sut.executeScript(
                name: "takanokun.js",
                headers: ["abc4":"def15", "ghi6":nil, "jkl22":"42"],
                queries: ["rst99":nil, "uvw-2":"-16"],
                body: "abcdefghijklmn".data(using: .utf8),
                callback : {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.script)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.get)
            XCTAssertEqual(executor.requests[0].subpathItems, ["takanokun.js"])
            XCTAssertEqual(executor.requests[0].headerItems.count, 3)
            XCTAssertEqual(executor.requests[0].headerItems["abc4"]!!, "def15")
            XCTAssertNil(executor.requests[0].headerItems["ghi6"]!)
            XCTAssertEqual(executor.requests[0].headerItems["jkl22"]!!, "42")
            XCTAssertEqual(executor.requests[0].queryItems.count, 2)
            XCTAssertNil(executor.requests[0].queryItems["rst99"]!)
            XCTAssertEqual(executor.requests[0].queryItems["uvw-2"]!!, "-16")
            XCTAssertEqual(executor.requests[0].body, "abcdefghijklmn".data(using: .utf8))
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://piyo.example.com/1986-02-04/script/takanokun.js?rst99&uvw-2=-16"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_executeScript_recieveResponse() {
        var contents : [String : Any] = [:]
        contents["test1"] = "value1"
        contents["test2"] = 42
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut = NCMBScriptService(method: NCMBHTTPMethod.get, endpoint: "https://piyo.example.com", apiVersion: "1986-02-04")

        let expectation : XCTestExpectation? = self.expectation(description: "test_executeScript_recieveResponse")
        sut.executeScript(
                name: "takanokun.js",
                headers: ["abc4":"def15", "ghi6":nil, "jkl22":"42"],
                queries: ["rst99":nil, "uvw-2":"-16"],
                body: "abcdefghijklmn".data(using: .utf8),
                callback : {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.contents.count, 2)
            XCTAssertEqual(response.contents["test1"] as! String, "value1")
            XCTAssertEqual(response.contents["test2"] as! Int, 42)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_executeScript_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut = NCMBScriptService(method: NCMBHTTPMethod.get, endpoint: "https://piyo.example.com", apiVersion: "1986-02-04")

        let expectation : XCTestExpectation? = self.expectation(description: "test_executeScript_failure")
        sut.executeScript(
                name: "takanokun.js",
                headers: ["abc4":"def15", "ghi6":nil, "jkl22":"42"],
                queries: ["rst99":nil, "uvw-2":"-16"],
                body: "abcdefghijklmn".data(using: .utf8),
                callback : {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_createRequest() {
        let sut = NCMBScriptService(method: NCMBHTTPMethod.get, endpoint: "https://piyo.example.com", apiVersion: "1986-02-04")
        let request : NCMBRequest = sut.createRequest(
            name: "takanokun.js",
            headers: ["abc4":"def15", "ghi6":nil, "jkl22":"42"],
            queries: ["rst99":nil, "uvw-2":"-16"],
            body: "abcdefghijklmn".data(using: .utf8))
        XCTAssertEqual(request.apiType, NCMBApiType.script)
        XCTAssertEqual(request.method, NCMBHTTPMethod.get)
        XCTAssertEqual(request.subpathItems, ["takanokun.js"])
        XCTAssertEqual(request.headerItems.count, 3)
        XCTAssertEqual(request.headerItems["abc4"]!!, "def15")
        XCTAssertNil(request.headerItems["ghi6"]!)
        XCTAssertEqual(request.headerItems["jkl22"]!!, "42")
        XCTAssertEqual(request.queryItems.count, 2)
        XCTAssertNil(request.queryItems["rst99"]!)
        XCTAssertEqual(request.queryItems["uvw-2"]!!, "-16")
        XCTAssertEqual(request.body, "abcdefghijklmn".data(using: .utf8))
        XCTAssertEqual(try! request.getURL(), URL(string: "https://piyo.example.com/1986-02-04/script/takanokun.js?rst99&uvw-2=-16"))
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    static var allTests = [
        ("test_init", test_init),
        ("test_executeScript_request", test_executeScript_request),
        ("test_executeScript_recieveResponse", test_executeScript_recieveResponse),
        ("test_executeScript_failure", test_executeScript_failure),
        ("test_createRequest", test_createRequest),
    ]
}
