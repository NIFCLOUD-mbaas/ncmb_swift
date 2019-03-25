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

import Foundation
import XCTest
@testable import NCMB

/// NCMBFileService のテストクラスです。
final class NCMBFileServiceTests: NCMBTestCase {

    func test_find_request() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        var query = NCMBFile.query
        query.where(field: "takanokun", equalTo: "42")

        let expectation : XCTestExpectation? = self.expectation(description: "test_find_request")
        let sut = NCMBFileService()
        sut.find(query: query, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.files)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.get)
            XCTAssertEqual(executor.requests[0].subpathItems, [])
            XCTAssertEqual(executor.requests[0].headerItems.count, 0)
            XCTAssertEqual(executor.requests[0].queryItems.count, 1)
            XCTAssertEqual(executor.requests[0].queryItems["where"]!, "{\"takanokun\":\"42\"}")
            XCTAssertNil(executor.requests[0].body)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/files?where=%7B%22takanokun%22:%2242%22%7D"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_find_recieveResponse() {
        var contents : [String : Any] = [:]
        contents["test1"] = "value1"
        contents["test2"] = 42
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        var query = NCMBFile.query
        query.where(field: "takanokun", equalTo: "42")

        let expectation : XCTestExpectation? = self.expectation(description: "test_find_recieveResponse")
        let sut = NCMBFileService()
        sut.find(query: query, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.contents.count, 2)
            XCTAssertEqual(response.contents["test1"] as! String, "value1")
            XCTAssertEqual(response.contents["test2"] as! Int, 42)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_find_invalidRequest() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        var query = NCMBFile.query
        query.where(field: "takanokun", equalTo: "42")

        let expectation : XCTestExpectation? = self.expectation(description: "test_find_invalidRequest")
        let sut = NCMBFileService()
        sut.find(query: query, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_fetch_request() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let file = NCMBFile(fileName: "takanokun", acl: NCMBACL.default)

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetch_request")
        let sut = NCMBFileService()
        sut.fetch(file: file, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.files)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.get)
            XCTAssertEqual(executor.requests[0].subpathItems, ["takanokun"])
            XCTAssertEqual(executor.requests[0].headerItems.count, 0)
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            XCTAssertNil(executor.requests[0].body)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/files/takanokun"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 120.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_fetch_recieveResponse() {
        let body : Data = "lkjhgfdsa987654".data(using: .utf8)!
        let mockResponse : NCMBResponse = MockResponseBuilder.createResponse(body: body, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(mockResponse)))

        let file = NCMBFile(fileName: "takanokun", acl: NCMBACL.default)

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetch_recieveResponse")
        let sut = NCMBFileService()
        sut.fetch(file: file, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.body!, "lkjhgfdsa987654".data(using: .utf8)!)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_fetch_invalidRequest() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let file = NCMBFile(fileName: "takanokun", acl: NCMBACL.default)

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetch_invalidRequest")
        let sut = NCMBFileService()
        sut.fetch(file: file, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_save_request_noACL() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let file = NCMBFile(fileName: "takanokun")
        let data : Data = "abcdefg123456".data(using: .utf8)!

        let expectation : XCTestExpectation? = self.expectation(description: "test_save_request_noACL")
        let sut = NCMBFileService()
        sut.save(file: file, data: data, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.files)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
            XCTAssertEqual(executor.requests[0].subpathItems, ["takanokun"])
            XCTAssertEqual(executor.requests[0].headerItems.count, 0)
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            XCTAssertEqual(executor.requests[0].contentType, "multipart/form-data; boundary=_NCMBProjectBoundary")
            XCTAssertEqual(executor.requests[0].contentLength, 136)
            XCTAssertEqual(executor.requests[0].body, "--_NCMBProjectBoundary\r\nContent-Disposition: form-data; name=\"file\"; filename=\"takanokun\"\r\n\r\nabcdefg123456\r\n--_NCMBProjectBoundary--\r\n\r\n".data(using: .utf8)!)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/files/takanokun"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 120.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_save_request_ACL() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let file = NCMBFile(fileName: "takanokun", acl: NCMBACL.empty)
        let data : Data = "abcdefg123456".data(using: .utf8)!

        let expectation : XCTestExpectation? = self.expectation(description: "test_save_request_ACL")
        let sut = NCMBFileService()
        sut.save(file: file, data: data, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.files)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
            XCTAssertEqual(executor.requests[0].subpathItems, ["takanokun"])
            XCTAssertEqual(executor.requests[0].headerItems.count, 0)
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            XCTAssertEqual(executor.requests[0].contentType, "multipart/form-data; boundary=_NCMBProjectBoundary")
            XCTAssertEqual(executor.requests[0].contentLength, 226)
            XCTAssertEqual(executor.requests[0].body, "--_NCMBProjectBoundary\r\nContent-Disposition: form-data; name=\"acl\"; filename=\"acl\"\r\n\r\n{}\r\n--_NCMBProjectBoundary\r\nContent-Disposition: form-data; name=\"file\"; filename=\"takanokun\"\r\n\r\nabcdefg123456\r\n--_NCMBProjectBoundary--\r\n\r\n".data(using: .utf8)!)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/files/takanokun"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 120.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_save_recieveResponse() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdef012345"
        contents["createDate"] = "1986-02-04T12:34:56.123Z"
        contents["updateDate"] = "1986-02-04T12:34:56.789Z"
        contents["acl"] = NCMBACL.default.toObject()
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let file = NCMBFile(fileName: "takanokun", acl: NCMBACL.default)
        let data : Data = "abcdefg123456".data(using: .utf8)!

        let expectation : XCTestExpectation? = self.expectation(description: "test_save_recieveResponse")
        let sut = NCMBFileService()
        sut.save(file: file, data: data, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.contents.count, 4)
            XCTAssertEqual(response.contents["objectId"] as! String, "abcdef012345")
            XCTAssertEqual(response.contents["createDate"] as! String, "1986-02-04T12:34:56.123Z")
            XCTAssertEqual(response.contents["updateDate"] as! String, "1986-02-04T12:34:56.789Z")
            XCTAssertEqual(((response.contents["acl"] as! [String : Any])["*"] as! [String : Bool])["read"], true)
            XCTAssertEqual(((response.contents["acl"] as! [String : Any])["*"] as! [String : Bool])["write"], true)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_save_invalidRequest() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let file = NCMBFile(fileName: "takanokun", acl: NCMBACL.default)
        let data : Data = "abcdefg123456".data(using: .utf8)!

        let expectation : XCTestExpectation? = self.expectation(description: "test_save_invalidRequest")
        let sut = NCMBFileService()
        sut.save(file: file, data: data, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_update_request() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        var acl = NCMBACL.empty
        acl.put(key: "hijk5678", readable: true, writable: false)
        let file = NCMBFile(fileName: "takanokun", acl: acl)

        let expectation : XCTestExpectation? = self.expectation(description: "test_save_request_post")
        let sut = NCMBFileService()
        sut.update(file: file, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.files)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
            XCTAssertEqual(executor.requests[0].subpathItems, ["takanokun"])
            XCTAssertEqual(executor.requests[0].headerItems.count, 0)
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            XCTAssertNotNil(executor.requests[0].body)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/files/takanokun"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_update_recieveResponse() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdef012345"
        contents["createDate"] = "1986-02-04T12:34:56.123Z"
        contents["updateDate"] = "1986-02-04T12:34:56.789Z"
        contents["acl"] = NCMBACL.default.toObject()
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        var acl = NCMBACL.empty
        acl.put(key: "hijk5678", readable: true, writable: false)
        let file = NCMBFile(fileName: "takanokun", acl: acl)

        let expectation : XCTestExpectation? = self.expectation(description: "test_save_recieveResponse")
        let sut = NCMBFileService()
        sut.update(file: file, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.contents.count, 4)
            XCTAssertEqual(response.contents["objectId"] as! String, "abcdef012345")
            XCTAssertEqual(response.contents["createDate"] as! String, "1986-02-04T12:34:56.123Z")
            XCTAssertEqual(response.contents["updateDate"] as! String, "1986-02-04T12:34:56.789Z")
            XCTAssertEqual(((response.contents["acl"] as! [String : Any])["*"] as! [String : Bool])["read"], true)
            XCTAssertEqual(((response.contents["acl"] as! [String : Any])["*"] as! [String : Bool])["write"], true)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_update_invalidRequest() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        var acl = NCMBACL.empty
        acl.put(key: "hijk5678", readable: true, writable: false)
        let file = NCMBFile(fileName: "takanokun", acl: acl)

        let expectation : XCTestExpectation? = self.expectation(description: "test_save_invalidRequest")
        let sut = NCMBFileService()
        sut.update(file: file, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_delete_request() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let file = NCMBFile(fileName: "takanokun")

        let expectation : XCTestExpectation? = self.expectation(description: "test_delete_request")
        let sut = NCMBFileService()
        sut.delete(file: file,  callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.files)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.delete)
            XCTAssertEqual(executor.requests[0].subpathItems, ["takanokun"])
            XCTAssertEqual(executor.requests[0].headerItems.count, 0)
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            XCTAssertNil(executor.requests[0].body)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/files/takanokun"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_delete_recieveResponse() {
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: [:], statusCode : 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let file = NCMBFile(fileName: "takanokun")

        let expectation : XCTestExpectation? = self.expectation(description: "test_delete_recieveResponse")
        let sut = NCMBFileService()
        sut.delete(file: file,  callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.contents.count, 0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_delete_invalidRequest() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let file = NCMBFile(fileName: "takanokun")

        let expectation : XCTestExpectation? = self.expectation(description: "test_delete_invalidRequest")
        let sut = NCMBFileService()
        sut.delete(file: file,  callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_createGetRequest_file() {
        let file = NCMBFile(fileName: "takanokun", acl: NCMBACL.default)
        let sut = NCMBFileService()
        let request : NCMBRequest = sut.createGetRequest(file: file)
        XCTAssertEqual(request.apiType, NCMBApiType.files)
        XCTAssertEqual(request.method, NCMBHTTPMethod.get)
        XCTAssertEqual(request.subpathItems, ["takanokun"])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 0)
        XCTAssertNil(request.body)
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/files/takanokun"))
        XCTAssertEqual(request.timeoutInterval, 120.0)
    }

    func test_createGetRequest_query() {
        var query = NCMBFile.query
        query.where(field: "takanokun", equalTo: "42")
        let sut = NCMBFileService()
        let request : NCMBRequest = sut.createGetRequest(query: query)
        XCTAssertEqual(request.apiType, NCMBApiType.files)
        XCTAssertEqual(request.method, NCMBHTTPMethod.get)
        XCTAssertEqual(request.subpathItems, [])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 1)
        XCTAssertEqual(request.queryItems["where"]!, "{\"takanokun\":\"42\"}")
        XCTAssertNil(request.body)
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/files?where=%7B%22takanokun%22:%2242%22%7D"))
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    func test_createPostRequest() {
        let file = NCMBFile(fileName: "takanokun", acl: NCMBACL.empty)
        let data : Data = "abcdefg123456".data(using: .utf8)!
        let sut = NCMBFileService()
        let request : NCMBRequest = try! sut.createPostRequest(file: file, data: data)
        XCTAssertEqual(request.apiType, NCMBApiType.files)
        XCTAssertEqual(request.method, NCMBHTTPMethod.post)
        XCTAssertEqual(request.subpathItems, ["takanokun"])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 0)
        XCTAssertEqual(request.contentType, "multipart/form-data; boundary=_NCMBProjectBoundary")
        XCTAssertEqual(request.contentLength, 226)
        XCTAssertEqual(request.queryItems.count, 0)
        XCTAssertEqual(request.body, "--_NCMBProjectBoundary\r\nContent-Disposition: form-data; name=\"acl\"; filename=\"acl\"\r\n\r\n{}\r\n--_NCMBProjectBoundary\r\nContent-Disposition: form-data; name=\"file\"; filename=\"takanokun\"\r\n\r\nabcdefg123456\r\n--_NCMBProjectBoundary--\r\n\r\n".data(using: .utf8)!)
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/files/takanokun"))
        XCTAssertEqual(request.timeoutInterval, 120.0)
    }

    func test_createPutRequest() {
        var acl = NCMBACL.empty
        acl.put(key: "hijk5678", readable: true, writable: false)
        let file = NCMBFile(fileName: "takanokun", acl: acl)
        let sut = NCMBFileService()
        let request : NCMBRequest = try! sut.createPutRequest(file: file)
        XCTAssertEqual(request.apiType, NCMBApiType.files)
        XCTAssertEqual(request.method, NCMBHTTPMethod.put)
        XCTAssertEqual(request.subpathItems, ["takanokun"])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 0)
        XCTAssertNotNil(request.body)
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/files/takanokun"))
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    func test_createDeleteRequest() {
        let file = NCMBFile(fileName: "takanokun")
        let sut = NCMBFileService()
        let request : NCMBRequest = sut.createDeleteRequest(file: file)
        XCTAssertEqual(request.apiType, NCMBApiType.files)
        XCTAssertEqual(request.method, NCMBHTTPMethod.delete)
        XCTAssertEqual(request.subpathItems, ["takanokun"])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 0)
        XCTAssertNil(request.body)
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/files/takanokun"))
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    static var allTests = [
        ("test_find_request", test_find_request),
        ("test_find_recieveResponse", test_find_recieveResponse),
        ("test_find_invalidRequest", test_find_invalidRequest),
        ("test_fetch_request", test_fetch_request),
        ("test_fetch_recieveResponse", test_fetch_recieveResponse),
        ("test_fetch_invalidRequest", test_fetch_invalidRequest),
        ("test_save_request", test_save_request_noACL),
        ("test_save_request", test_save_request_ACL),
        ("test_save_recieveResponse", test_save_recieveResponse),
        ("test_save_invalidRequest", test_save_invalidRequest),
        ("test_update_request", test_update_request),
        ("test_update_recieveResponse", test_update_recieveResponse),
        ("test_update_invalidRequest", test_update_invalidRequest),
        ("test_delete_request", test_delete_request),
        ("test_delete_recieveResponse", test_delete_recieveResponse),
        ("test_delete_invalidRequest", test_delete_invalidRequest),
        ("test_createGetRequest_file", test_createGetRequest_file),
        ("test_createGetRequest_query", test_createGetRequest_query),
        ("test_createPostRequest", test_createPostRequest),
        ("test_createPutRequest", test_createPutRequest),
        ("test_createDeleteRequest", test_createDeleteRequest),
    ]
}
