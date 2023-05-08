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

import Foundation
import XCTest
@testable import NCMB
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// NCMBRequestExecutor のテストクラスです。
final class NCMBRequestExecutorTests: NCMBTestCase {

    func test_exec_invalidRequest() {
        NCMBSessionFactory.setInstance(session: SuccessSessionMock())
        let sut = NCMBRequestExecutor()

        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "") // invalid Domain URL

        let request = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"])

        let expectation : XCTestExpectation? = self.expectation(description: "testExec_invalidRequest")

        sut.exec(request: request, callback: { result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! NCMBInvalidRequestError, NCMBInvalidRequestError.invalidDomainName)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_exec_sessionThrowError() {
        NCMBSessionFactory.setInstance(session: SessionThrowErrorSessionMock())
        let sut = NCMBRequestExecutor()

        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111")

        let request = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"])

        let expectation : XCTestExpectation? = self.expectation(description: "testExec_sessionThrowError")

        sut.exec(request: request, callback: { result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_exec_invalidResponse() {
        NCMBSessionFactory.setInstance(session: InvalidResponseSessionMock())
        let sut = NCMBRequestExecutor()

        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111")

        let request = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"])

        let expectation : XCTestExpectation? = self.expectation(description: "testExec_invalidResponse")

        sut.exec(request: request, callback: { result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_exec_responseIsError() {
        NCMBSessionFactory.setInstance(session: ResponseIsErrorSessionMock())
        let sut = NCMBRequestExecutor()

        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111")

        let request = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"])

        let expectation : XCTestExpectation? = self.expectation(description: "testExec_responseIsError")

        sut.exec(request: request, callback: { result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual((NCMBTestUtil.getError(result: result)! as! NCMBApiError).errorCode, NCMBApiErrorCode.noneService)
            XCTAssertEqual((NCMBTestUtil.getError(result: result)! as! NCMBApiError).message, "None service.")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_exec_success() {
        NCMBSessionFactory.setInstance(session: SuccessSessionMock())
        let sut = NCMBRequestExecutor()

        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111")

        let request = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"])

        let expectation : XCTestExpectation? = self.expectation(description: "testExec_success")

        sut.exec(request: request, callback: { result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    private class func createSuccessResponse() -> NCMBResponse {
        let body : Data? = "{}".data(using: .utf8)!
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [:])!
        return try! NCMBResponse(body: body, response: response)
    }

    static var allTests = [
        ("test_exec_invalidRequest", test_exec_invalidRequest),
        ("test_exec_sessionThrowError", test_exec_sessionThrowError),
        ("test_exec_invalidResponse", test_exec_invalidResponse),
        ("test_exec_responseIsError", test_exec_responseIsError),
        ("test_exec_success", test_exec_success),
    ]

    private class SessionThrowErrorSessionDataTaskMock : URLSessionDataTask {

        private let handler : (Data?, URLResponse?, Error?) -> Void

        init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
            self.handler = completionHandler
        }

        override func resume() -> Void {
            self.handler(nil, nil, DummyErrors.dummyError) // session throw error
        }
    }

    private class SessionThrowErrorSessionMock : NCMBSessionProtocol {

        required init() {
        }

        func dataTask(
            with: URLRequest,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
            ) -> URLSessionDataTask {
                return SessionThrowErrorSessionDataTaskMock(completionHandler: completionHandler)
        }
    }

    private class InvalidResponseSessionDataTaskMock : URLSessionDataTask {

        private let handler : (Data?, URLResponse?, Error?) -> Void

        init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
            self.handler = completionHandler
        }

        override func resume() -> Void {
            let body : Data? = "{\"takanokun\", \"takano_san\"}".data(using: .utf8)! // invalid body
            // response is not HTTPURLResponse
            // let response = HTTPURLResponse(
            //         url: URL(string: "https://takanokun.takano_san.example.com")!,
            //         statusCode: 200,
            //         httpVersion: nil,
            //         headerFields: [:])!
            let response = URLResponse(
                    url: URL(string: "https://takanokun.takano_san.example.com")!,
                    mimeType: nil,
                    expectedContentLength: 1,
                    textEncodingName: nil)
            self.handler(body, response, nil)
        }
    }

    private class InvalidResponseSessionMock : NCMBSessionProtocol {

        required init() {
        }

        func dataTask(
            with: URLRequest,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
            ) -> URLSessionDataTask {
                return InvalidResponseSessionDataTaskMock(completionHandler: completionHandler)
        }
    }

    private class ResponseIsErrorSessionDataTaskMock : URLSessionDataTask {

        private let handler : (Data?, URLResponse?, Error?) -> Void

        init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
            self.handler = completionHandler
        }

        override func resume() -> Void {
            let body : Data? = "{\"code\":\"E404002\",\"error\":\"None service.\",\"field1\":\"value1\"}".data(using: .utf8)!
            let response = HTTPURLResponse(
                    url: URL(string: "https://takanokun.takano_san.example.com")!,
                    statusCode: 404,
                    httpVersion: nil,
                    headerFields: [:])!
            self.handler(body, response, nil)
        }
    }

    private class ResponseIsErrorSessionMock : NCMBSessionProtocol {

        required init() {
        }

        func dataTask(
            with: URLRequest,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
            ) -> URLSessionDataTask {
                return ResponseIsErrorSessionDataTaskMock(completionHandler: completionHandler)
        }
    }

    private class SuccessSessionDataTaskMock : URLSessionDataTask {

        private let handler : (Data?, URLResponse?, Error?) -> Void

        init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
            self.handler = completionHandler
        }

        override func resume() -> Void {
            let body : Data? = "{\"takanokun\" : \"takano_san\"}".data(using: .utf8)!
            let response = HTTPURLResponse(
                    url: URL(string: "https://takanokun.takano_san.example.com")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: [:])!
            self.handler(body, response, nil)
        }
    }

    private class SuccessSessionMock : NCMBSessionProtocol {

        required init() {
        }

        func dataTask(
            with: URLRequest,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
            ) -> URLSessionDataTask {
                return SuccessSessionDataTaskMock(completionHandler: completionHandler)
        }
    }

}
