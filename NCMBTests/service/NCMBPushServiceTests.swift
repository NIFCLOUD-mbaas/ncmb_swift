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

/// NCMBPushService のテストクラスです。
final class NCMBPushServiceTests: NCMBTestCase {

    func test_find_request() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        var query = NCMBPush.query
        query.where(field: "takanokun", equalTo: "42")

        let expectation : XCTestExpectation? = self.expectation(description: "test_find_request")
        let sut = NCMBPushService()
        sut.find(query: query, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.push)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.get)
            XCTAssertEqual(executor.requests[0].subpathItems, [])
            XCTAssertEqual(executor.requests[0].headerItems.count, 0)
            XCTAssertEqual(executor.requests[0].queryItems.count, 1)
            XCTAssertEqual(executor.requests[0].queryItems["where"]!, "{\"takanokun\":\"42\"}")
            XCTAssertNil(executor.requests[0].body)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/push?where=%7B%22takanokun%22:%2242%22%7D"))
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

        var query = NCMBPush.query
        query.where(field: "takanokun", equalTo: "42")

        let expectation : XCTestExpectation? = self.expectation(description: "test_find_recieveResponse")
        let sut = NCMBPushService()
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

        var query = NCMBPush.query
        query.where(field: "takanokun", equalTo: "42")

        let expectation : XCTestExpectation? = self.expectation(description: "test_find_invalidRequest")
        let sut = NCMBPushService()
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

        let push = NCMBPush()
        push.objectId = "abcdef012345"

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetch_request")
        let sut = NCMBPushService()
        sut.fetch(object: push, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.push)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.get)
            XCTAssertEqual(executor.requests[0].subpathItems, ["abcdef012345"])
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            XCTAssertNil(executor.requests[0].body)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/push/abcdef012345"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_fetch_recieveResponse() {
        var contents : [String : Any] = [:]
        contents["test1"] = "value1"
        contents["test2"] = 42
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let push = NCMBPush()
        push.objectId = "abcdef012345"

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetch_recieveResponse")
        let sut = NCMBPushService()
        sut.fetch(object: push, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.contents.count, 2)
            XCTAssertEqual(response.contents["test1"] as! String, "value1")
            XCTAssertEqual(response.contents["test2"] as! Int, 42)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_fetch_invalidRequest() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let push = NCMBPush()
        push.objectId = "abcdef012345"

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetch_invalidRequest")
        let sut = NCMBPushService()
        sut.fetch(object: push, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_save_request_post() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let push = NCMBPush()
        push.objectId = nil
        push["takanokun"] = 42

        let expectation : XCTestExpectation? = self.expectation(description: "test_save_request_post")
        let sut = NCMBPushService()
        sut.save(object: push, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.push)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
            XCTAssertEqual(executor.requests[0].subpathItems, [])
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            let bodyString : String = String(data: executor.requests[0].body!, encoding: .utf8)!
            XCTAssertTrue(bodyString.contains("\"takanokun\":42"))
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/push"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_save_request_put() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let push = NCMBPush()
        push.objectId = "abcdef012345"
        push["takanokun"] = 42

        let expectation : XCTestExpectation? = self.expectation(description: "test_save_request_put")
        let sut = NCMBPushService()
        sut.save(object: push, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.push)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
            XCTAssertEqual(executor.requests[0].subpathItems, ["abcdef012345"])
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"takanokun\":42"))
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/push/abcdef012345"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
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

        let push = NCMBPush()
        push.objectId = "abcdef012345"

        let expectation : XCTestExpectation? = self.expectation(description: "test_save_recieveResponse")
        let sut = NCMBPushService()
        sut.save(object: push, callback: {result in
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

        let push = NCMBPush()
        push.objectId = "abcdef012345"

        let expectation : XCTestExpectation? = self.expectation(description: "test_save_invalidRequest")
        let sut = NCMBPushService()
        sut.save(object: push, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_delete_request() {
        let executor = MockRequestExecutor()
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let push = NCMBPush()
        push.objectId = "abcdef012345"

        let expectation : XCTestExpectation? = self.expectation(description: "test_delete_request")
        let sut = NCMBPushService()
        sut.delete(object: push, callback: {result in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].apiType, NCMBApiType.push)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.delete)
            XCTAssertEqual(executor.requests[0].subpathItems, ["abcdef012345"])
            XCTAssertEqual(executor.requests[0].queryItems.count, 0)
            XCTAssertNil(executor.requests[0].body)
            XCTAssertEqual(try! executor.requests[0].getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/push/abcdef012345"))
            XCTAssertEqual(executor.requests[0].timeoutInterval, 10.0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_delete_recieveResponse() {
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: [:], statusCode : 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let push = NCMBPush()
        push.objectId = "abcdef012345"

        let expectation : XCTestExpectation? = self.expectation(description: "test_delete_recieveResponse")
        let sut = NCMBPushService()
        sut.delete(object: push, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.contents.count, 0)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_delete_invalidRequest() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let push = NCMBPush()
        push.objectId = "abcdef012345"

        let expectation : XCTestExpectation? = self.expectation(description: "test_delete_invalidRequest")
        let sut = NCMBPushService()
        sut.delete(object: push, callback: {result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout:1.00, handler: nil)
    }

    func test_createGetRequest_emptyObjectId() {
        let push = NCMBPush()
        push.objectId = nil
        let sut = NCMBPushService()
        XCTAssertThrowsError(try sut.createGetRequest(object: push)) { error in
            XCTAssertEqual(error as! NCMBInvalidRequestError, NCMBInvalidRequestError.emptyObjectId)
        }
    }

    func test_createGetRequest_success() {
        let push = NCMBPush()
        push.objectId = "abcdef012345"
        let sut = NCMBPushService()
        let request : NCMBRequest = try! sut.createGetRequest(object: push)
        XCTAssertEqual(request.apiType, NCMBApiType.push)
        XCTAssertEqual(request.method, NCMBHTTPMethod.get)
        XCTAssertEqual(request.subpathItems, ["abcdef012345"])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 0)
        XCTAssertNil(request.body)
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/push/abcdef012345"))
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    func test_createGetRequest_query() {
        var query = NCMBPush.query
        query.where(field: "takanokun", equalTo: "42")
        let sut = NCMBPushService()
        let request : NCMBRequest = sut.createGetRequest(query: query)
        XCTAssertEqual(request.apiType, NCMBApiType.push)
        XCTAssertEqual(request.method, NCMBHTTPMethod.get)
        XCTAssertEqual(request.subpathItems, [])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 1)
        XCTAssertEqual(request.queryItems["where"]!, "{\"takanokun\":\"42\"}")
        XCTAssertNil(request.body)
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/push?where=%7B%22takanokun%22:%2242%22%7D"))
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    func test_createPostRequest_success() {
        var fields : [String : Any] = [:]
        fields["objectId"] = "abcdefg12345"
        fields["takanokun"] = "takano_san"
        fields["createDate"] = "1986-02-04T12:34:56.789Z"
        fields["updateDate"] = "1986-02-04T12:34:56.901Z"
        fields["acl"] = ["abcd": ["read": true, "write": false]]
        let push = NCMBPush(className: NCMBPush.CLASSNAME, fields: fields)
        push.objectId = nil // push have not objectId

        let sut = NCMBPushService()
        let request : NCMBRequest = try! sut.createPostRequest(object: push)
        XCTAssertEqual(request.apiType, NCMBApiType.push)
        XCTAssertEqual(request.method, NCMBHTTPMethod.post)
        XCTAssertEqual(request.subpathItems, [])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 0)
        XCTAssertNotNil(request.body)
        XCTAssertTrue(String(data: request.body!, encoding: .utf8)!.contains("\"takanokun\":\"takano_san\""))
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/push"))
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    func test_createPostRequest_body_dose_not_contain_objectId() {
        var fields : [String : Any] = [:]
        fields["objectId"] = "abcdefg12345"
        fields["takanokun"] = "takano_san"
        fields["createDate"] = "1986-02-04T12:34:56.789Z"
        fields["updateDate"] = "1986-02-04T12:34:56.901Z"
        fields["acl"] = ["abcd": ["read": true, "write": false]]
        let push = NCMBPush(className: NCMBPush.CLASSNAME, fields: fields)
        push.objectId = nil // push have not objectId

        let sut = NCMBPushService()
        let request : NCMBRequest = try! sut.createPostRequest(object: push)
        XCTAssertFalse(String(data: request.body!, encoding: .utf8)!.contains("\"objectId\":"))
    }

    func test_createPostRequest_body_dose_not_contain_createDate() {
        var fields : [String : Any] = [:]
        fields["objectId"] = "abcdefg12345"
        fields["takanokun"] = "takano_san"
        fields["createDate"] = "1986-02-04T12:34:56.789Z"
        fields["updateDate"] = "1986-02-04T12:34:56.901Z"
        fields["acl"] = ["abcd": ["read": true, "write": false]]
        let push = NCMBPush(className: NCMBPush.CLASSNAME, fields: fields)
        push.objectId = nil // push have not objectId

        let sut = NCMBPushService()
        let request : NCMBRequest = try! sut.createPostRequest(object: push)
        XCTAssertFalse(String(data: request.body!, encoding: .utf8)!.contains("\"createDate\":"))
    }

    func test_createPostRequest_body_dose_not_contain_updateDate() {
        var fields : [String : Any] = [:]
        fields["objectId"] = "abcdefg12345"
        fields["takanokun"] = "takano_san"
        fields["createDate"] = "1986-02-04T12:34:56.789Z"
        fields["updateDate"] = "1986-02-04T12:34:56.901Z"
        fields["acl"] = ["abcd": ["read": true, "write": false]]
        let push = NCMBPush(className: NCMBPush.CLASSNAME, fields: fields)

        let sut = NCMBPushService()
        let request : NCMBRequest = try! sut.createPostRequest(object: push)
        XCTAssertFalse(String(data: request.body!, encoding: .utf8)!.contains("\"updateDate\":"))
    }

    func test_createPostRequest_body_dose_contain_acl() {
        var fields : [String : Any] = [:]
        fields["objectId"] = "abcdefg12345"
        fields["takanokun"] = "takano_san"
        fields["createDate"] = "1986-02-04T12:34:56.789Z"
        fields["updateDate"] = "1986-02-04T12:34:56.901Z"
        fields["acl"] = ["abcd": ["read": true, "write": false]]
        let push = NCMBPush(className: NCMBPush.CLASSNAME, fields: fields)

        let sut = NCMBPushService()
        let request : NCMBRequest = try! sut.createPostRequest(object: push)
        XCTAssertTrue(String(data: request.body!, encoding: .utf8)!.contains("\"acl\":"))
        XCTAssertTrue(String(data: request.body!, encoding: .utf8)!.contains("\"abcd\":"))
    }

    func test_createPutRequest_success() {
        let push = NCMBPush()
        push["takanokun"] = "takano_san"
        let sut = NCMBPushService()
        let request : NCMBRequest = try! sut.createPutRequest(object: push, objectId: "abcdef012345")
        XCTAssertEqual(request.apiType, NCMBApiType.push)
        XCTAssertEqual(request.method, NCMBHTTPMethod.put)
        XCTAssertEqual(request.subpathItems, ["abcdef012345"])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 0)
        XCTAssertNotNil(request.body)
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/push/abcdef012345"))
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    func test_createDeleteRequest_emptyObjectId() {
        let push = NCMBPush()
        push.objectId = nil
        let sut = NCMBPushService()
        XCTAssertThrowsError(try sut.createDeleteRequest(object: push)) { error in
            XCTAssertEqual(error as! NCMBInvalidRequestError, NCMBInvalidRequestError.emptyObjectId)
        }
    }

    func test_createDeleteRequest_success() {
        let push = NCMBPush()
        push.objectId = "abcdef012345"
        let sut = NCMBPushService()
        let request : NCMBRequest = try! sut.createDeleteRequest(object: push)
        XCTAssertEqual(request.apiType, NCMBApiType.push)
        XCTAssertEqual(request.method, NCMBHTTPMethod.delete)
        XCTAssertEqual(request.subpathItems, ["abcdef012345"])
        XCTAssertEqual(request.headerItems.count, 0)
        XCTAssertEqual(request.queryItems.count, 0)
        XCTAssertNil(request.body)
        XCTAssertEqual(try! request.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/push/abcdef012345"))
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    static var allTests = [
        ("test_find_request", test_find_request),
        ("test_find_recieveResponse", test_find_recieveResponse),
        ("test_find_invalidRequest", test_find_invalidRequest),
        ("test_fetch_request", test_fetch_request),
        ("test_fetch_recieveResponse", test_fetch_recieveResponse),
        ("test_fetch_invalidRequest", test_fetch_invalidRequest),
        ("test_save_request_post", test_save_request_post),
        ("test_save_request_put", test_save_request_put),
        ("test_save_recieveResponse", test_save_recieveResponse),
        ("test_save_invalidRequest", test_save_invalidRequest),
        ("test_delete_request", test_delete_request),
        ("test_delete_recieveResponse", test_delete_recieveResponse),
        ("test_delete_invalidRequest", test_delete_invalidRequest),
        ("test_createGetRequest_emptyObjectId", test_createGetRequest_emptyObjectId),
        ("test_createGetRequest_success", test_createGetRequest_success),
        ("test_createGetRequest_query", test_createGetRequest_query),
        ("test_createPostRequest_success", test_createPostRequest_success),
        ("test_createPostRequest_body_dose_not_contain_objectId", test_createPostRequest_body_dose_not_contain_objectId),
        ("test_createPostRequest_body_dose_not_contain_createDate", test_createPostRequest_body_dose_not_contain_createDate),
        ("test_createPostRequest_body_dose_not_contain_updateDate", test_createPostRequest_body_dose_not_contain_updateDate),
        ("test_createPostRequest_body_dose_contain_acl", test_createPostRequest_body_dose_contain_acl),
        ("test_createPutRequest_success", test_createPutRequest_success),
        ("test_createDeleteRequest_emptyObjectId", test_createDeleteRequest_emptyObjectId),
        ("test_createDeleteRequest_success", test_createDeleteRequest_success),
    ]
}
