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

/// NCMBScript のテストクラスです。
final class NCMBScriptTests: NCMBTestCase {

    func test_default_init() {
        let responseDBody : Data = "xyz12345abc".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: responseDBody, statusCode: 200)
        let executor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBScript = NCMBScript(name: "trialScript.js", method: NCMBHTTPMethod.put)

        _ = sut.execute()
        XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://script.mbaas.api.nifcloud.com/2015-09-01/script/trialScript.js"))
    }

    func test_customize_init() {
        let responseDBody : Data = "xyz12345abc".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: responseDBody, statusCode: 200)
        let executor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBScript = NCMBScript(
            name: "trialScript.js",
            method: NCMBHTTPMethod.put,
            endpoint: "https://piyo.example.com",
            apiVersion: "1986-02-04")

        _ = sut.execute()
        XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://piyo.example.com/1986-02-04/script/trialScript.js"))
    }

    func test_execute_default_request() {
        let responseDBody : Data = "xyz12345abc".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: responseDBody, statusCode: 200)
        let executor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBScript = NCMBScript(name: "trialScript.js", method: NCMBHTTPMethod.put)

        _ = sut.execute()

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.script)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
        XCTAssertEqual(executor.requests[0].contentType, "application/json")
        XCTAssertEqual(executor.requests[0].subpathItems, ["trialScript.js"])
        XCTAssertEqual(executor.requests[0].headerItems.count, 0)
        XCTAssertEqual(executor.requests[0].queryItems.count, 0)
        XCTAssertNil(executor.requests[0].body)
        XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://script.mbaas.api.nifcloud.com/2015-09-01/script/trialScript.js"))
        XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
    }

    func test_execute_customize_request() {
        let responseDBody : Data = "xyz12345abc".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: responseDBody, statusCode: 200)
        let executor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBScript = NCMBScript(name: "trialScript.js", method: NCMBHTTPMethod.post)

        let headers : [String : String?] = ["X-feiled1":"valueA", "X-feiled2":"valueB"]
        let queries : [String : String?] = ["q3":"42", "q1":"def", "q2":nil]
        let requestBody: [String : Any?] = ["b1": 29, "b4": nil, "b3": "takanokun", "b2": true]

        _ = sut.execute(
                headers: headers,
                queries: queries,
                body: requestBody)
        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.script)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
        XCTAssertEqual(executor.requests[0].contentType, "application/json")
        XCTAssertEqual(executor.requests[0].subpathItems, ["trialScript.js"])
        XCTAssertEqual(executor.requests[0].headerItems.count, 2)
        XCTAssertEqual(executor.requests[0].headerItems["X-feiled1"]!!, "valueA")
        XCTAssertEqual(executor.requests[0].headerItems["X-feiled2"]!!, "valueB")
        XCTAssertEqual(executor.requests[0].queryItems.count, 3)
        XCTAssertNil(executor.requests[0].queryItems["q2"]!)
        XCTAssertEqual(executor.requests[0].queryItems["q1"]!!, "def")
        XCTAssertEqual(executor.requests[0].queryItems["q3"]!!, "42")
        XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"b1\":29"))
        XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"b4\":null"))
        XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"b3\":\"takanokun\""))
        XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"b2\":true"))
        XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://script.mbaas.api.nifcloud.com/2015-09-01/script/trialScript.js?q1=def&q2&q3=42"))
        XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
    }

    func test_execute_success() {
        let responseDBody : Data = "xyz12345abc".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: responseDBody, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBScript = NCMBScript(name: "trialScript.js", method: NCMBHTTPMethod.post)

        let result: NCMBResult<Data?> = sut.execute()
        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        let data : Data? = NCMBTestUtil.getResponse(result: result)!
        XCTAssertEqual(data, "xyz12345abc".data(using: .utf8)!)
    }

    func test_execute_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBScript = NCMBScript(name: "trialScript.js", method: NCMBHTTPMethod.post)

        let result: NCMBResult<Data?> = sut.execute()
        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_executeInBackground_default_request() {
        let responseDBody : Data = "xyz12345abc".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: responseDBody, statusCode: 200)
        let executor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBScript = NCMBScript(name: "trialScript.js", method: NCMBHTTPMethod.put)

        let expectation : XCTestExpectation? = self.expectation(description: "test_executeInBackground_default_request")
        sut.executeInBackground(callback: { (result: NCMBResult<Data?>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.script)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
            XCTAssertEqual(executor.requests[0].contentType, "application/json")
            XCTAssertEqual(executor.requests[0].subpathItems, ["trialScript.js"])
            XCTAssertEqual(executor.requests[0].headerItems.count, 0)
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            XCTAssertNil(executor.requests[0].body)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://script.mbaas.api.nifcloud.com/2015-09-01/script/trialScript.js"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_executeInBackground_customize_request() {
        let responseDBody : Data = "xyz12345abc".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: responseDBody, statusCode: 200)
        let executor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBScript = NCMBScript(name: "trialScript.js", method: NCMBHTTPMethod.post)

        let headers : [String : String?] = ["X-feiled1":"valueA", "X-feiled2":"valueB"]
        let queries : [String : String?] = ["q3":"42", "q1":"def", "q2":nil]
        let requestBody: [String : Any?] = ["b1": 29, "b4": nil, "b3": "takanokun", "b2": true]
        let expectation : XCTestExpectation? = self.expectation(description: "test_executeInBackground_customize_request")
        sut.executeInBackground(
                headers: headers,
                queries: queries,
                body: requestBody,
                callback: { (result: NCMBResult<Data?>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.script)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
            XCTAssertEqual(executor.requests[0].contentType, "application/json")
            XCTAssertEqual(executor.requests[0].subpathItems, ["trialScript.js"])
            XCTAssertEqual(executor.requests[0].headerItems.count, 2)
            XCTAssertEqual(executor.requests[0].headerItems["X-feiled1"]!!, "valueA")
            XCTAssertEqual(executor.requests[0].headerItems["X-feiled2"]!!, "valueB")
            XCTAssertEqual(executor.requests[0].queryItems.count, 3)
            XCTAssertNil(executor.requests[0].queryItems["q2"]!)
            XCTAssertEqual(executor.requests[0].queryItems["q1"]!!, "def")
            XCTAssertEqual(executor.requests[0].queryItems["q3"]!!, "42")
            XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"b1\":29"))
            XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"b4\":null"))
            XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"b3\":\"takanokun\""))
            XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"b2\":true"))
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://script.mbaas.api.nifcloud.com/2015-09-01/script/trialScript.js?q1=def&q2&q3=42"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_executeInBackground_success() {
        let responseDBody : Data = "xyz12345abc".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: responseDBody, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBScript = NCMBScript(name: "trialScript.js", method: NCMBHTTPMethod.post)

        let expectation : XCTestExpectation? = self.expectation(description: "test_executeInBackground_success")
        sut.executeInBackground(callback: { (result: NCMBResult<Data?>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let data : Data? = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(data, "xyz12345abc".data(using: .utf8)!)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_executeInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBScript = NCMBScript(name: "trialScript.js", method: NCMBHTTPMethod.post)

        let expectation : XCTestExpectation? = self.expectation(description: "test_executeInBackground_failure")
        sut.executeInBackground(callback: { (result: NCMBResult<Data?>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    static var allTests = [
        ("test_default_init", test_default_init),
        ("test_customize_init", test_customize_init),
        ("test_execute_default_request", test_execute_default_request),
        ("test_execute_customize_request", test_execute_customize_request),
        ("test_execute_success", test_execute_success),
        ("test_execute_failure", test_execute_failure),
        ("test_executeInBackground_default_request", test_executeInBackground_default_request),
        ("test_executeInBackground_customize_request", test_executeInBackground_customize_request),
        ("test_executeInBackground_success", test_executeInBackground_success),
        ("test_executeInBackground_failure", test_executeInBackground_failure),
    ]
}
