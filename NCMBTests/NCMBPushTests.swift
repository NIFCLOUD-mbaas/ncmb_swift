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

/// NCMBPush のテストクラスです。
final class NCMBPushTests: NCMBTestCase {

    func test_init_default() {
        let sut : NCMBPush = NCMBPush()
        XCTAssertNil(sut["deliveryTime"])        
        XCTAssertEqual(sut["immediateDeliveryFlag"], true)        
        XCTAssertEqual(sut["target"] as [String]?, [])        
    }

    func test_deliveryTime() {
        let sut : NCMBPush = NCMBPush()
        sut.deliveryTime = Date(timeIntervalSince1970: 507904496.789)

        XCTAssertEqual(sut["deliveryTime"]! as Date, Date(timeIntervalSince1970: 507904496.789))
        XCTAssertEqual(sut.deliveryTime, Date(timeIntervalSince1970: 507904496.789))
        XCTAssertEqual(sut["immediateDeliveryFlag"], false)
        XCTAssertEqual(sut.immediateDeliveryFlag, false)
    }

    func test_setImmediateDelivery() {
        let sut : NCMBPush = NCMBPush()
        sut.deliveryTime = Date(timeIntervalSince1970: 507904496.789)
        sut.setImmediateDelivery()

        XCTAssertNil(sut["deliveryTime"])
        XCTAssertNil(sut.deliveryTime)
        XCTAssertEqual(sut["immediateDeliveryFlag"], true)
        XCTAssertEqual(sut.immediateDeliveryFlag, true)
    }

    func test_target() {
        let sut : NCMBPush = NCMBPush()

        XCTAssertEqual(sut.isSendToIOS, false)
        XCTAssertEqual(sut.isSendToAndroid, false)
        XCTAssertEqual(sut.target!.count, 0)

        sut.isSendToIOS = true

        XCTAssertEqual(sut.isSendToIOS, true)
        XCTAssertEqual(sut.isSendToAndroid, false)
        XCTAssertEqual(sut.target!.count, 1)
        XCTAssertEqual(sut.target!.contains("ios"), true)

        sut.isSendToAndroid = true

        XCTAssertEqual(sut.isSendToIOS, true)
        XCTAssertEqual(sut.isSendToAndroid, true)
        XCTAssertEqual(sut.target!.count, 2)
        XCTAssertEqual(sut.target!.contains("ios"), true)
        XCTAssertEqual(sut.target!.contains("android"), true)

        sut.isSendToIOS = false

        XCTAssertEqual(sut.isSendToIOS, false)
        XCTAssertEqual(sut.isSendToAndroid, true)
        XCTAssertEqual(sut.target!.count, 1)
        XCTAssertEqual(sut.target!.contains("android"), true)

        sut.isSendToAndroid = false

        XCTAssertEqual(sut.isSendToIOS, false)
        XCTAssertEqual(sut.isSendToAndroid, false)
        XCTAssertEqual(sut.target!.count, 0)
    }

    func test_fetch_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["field2"] = "value2"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let result : NCMBResult<Void> = sut.fetch()

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        XCTAssertEqual(sut.objectId, "abcdefg12345")
        XCTAssertNil(sut["field1"])
        XCTAssertEqual(sut["field2"], "value2")
    }

    func test_fetch_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let result : NCMBResult<Void> = sut.fetch()

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
        XCTAssertEqual(sut.objectId, "abcdefg12345")
        XCTAssertEqual(sut["field1"], "value1")
    }

    func test_fetchInBackground_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["field2"] = "value2"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetchInBackground_success")
        sut.fetchInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            XCTAssertEqual(sut.objectId, "abcdefg12345")
            XCTAssertNil(sut["field1"])
            XCTAssertEqual(sut["field2"], "value2")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_fetchInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetchInBackground_failure")
        sut.fetchInBackground(callback: { result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            XCTAssertEqual(sut.objectId, "abcdefg12345")
            XCTAssertEqual(sut["field1"], "value1")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_fetchInBackground_reset_modifiedFields() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["field2"] = "value2"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetchInBackground_reset_modifiedFields")
        sut.fetchInBackground(callback: { (result: NCMBResult<Void>) in
            sut.sendInBackground(callback: { (result: NCMBResult<Void>) in
                XCTAssertEqual(executor.requests.count, 2)
                XCTAssertEqual(String(data: executor.requests[1].body!, encoding: .utf8)!, "{}")
                expectation?.fulfill()
            })
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_send_success_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["craeteDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBPush = NCMBPush()
        sut["field1"] = "value1"

        let result : NCMBResult<Void> = sut.send()

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
        XCTAssertEqual(sut.objectId, "abcdefg12345")
        XCTAssertEqual(sut["field1"], "value1")
        XCTAssertEqual(sut["craeteDate"], "1986-02-04T12:34:56.789Z")
    }

    func test_send_success_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["craeteDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"
        XCTAssertEqual(sut.needUpdate, true)

        let result : NCMBResult<Void> = sut.send()

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
        XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"field1\":\"value1\""))
        XCTAssertEqual(sut.objectId, "abcdefg12345")
        XCTAssertEqual(sut["field1"], "value1")
        XCTAssertEqual(sut["craeteDate"], "1986-02-04T12:34:56.789Z")
        XCTAssertEqual(sut.needUpdate, false)
    }

    func test_send_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBPush = NCMBPush()
        sut["field1"] = "value1"

        let result : NCMBResult<Void> = sut.send()

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
        XCTAssertEqual(sut["field1"], "value1")
    }

    func test_sendInBackground_success_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["craeteDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBPush = NCMBPush()
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_sendInBackground_success_insert")
        sut.sendInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))

            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

            XCTAssertEqual(sut.objectId, "abcdefg12345")
            XCTAssertEqual(sut["field1"], "value1")
            XCTAssertEqual(sut["craeteDate"], "1986-02-04T12:34:56.789Z")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_sendInBackground_success_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["craeteDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"
        XCTAssertEqual(sut.needUpdate, true)

        let expectation : XCTestExpectation? = self.expectation(description: "test_sendInBackground_success_update")
        sut.sendInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))

            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
            XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"field1\":\"value1\""))

            XCTAssertEqual(sut.objectId, "abcdefg12345")
            XCTAssertEqual(sut["field1"], "value1")
            XCTAssertEqual(sut["craeteDate"], "1986-02-04T12:34:56.789Z")
            XCTAssertEqual(sut.needUpdate, false)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_sendInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBPush = NCMBPush()
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_sendInBackground_failure")
        sut.sendInBackground(callback: { result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            XCTAssertEqual(sut["field1"], "value1")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_sendInBackground_reset_modifiedFields() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["craeteDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_sendInBackground_reset_modifiedFields")
        sut.sendInBackground(callback: { (result: NCMBResult<Void>) in
            sut["field2"] = "value2"
            sut.sendInBackground(callback: { (result: NCMBResult<Void>) in
                XCTAssertEqual(executor.requests.count, 2)
                XCTAssertEqual(String(data: executor.requests[1].body!, encoding: .utf8)!, "{\"field2\":\"value2\"}")
                expectation?.fulfill()
            })
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_sendInBackground_modifiedFields_null() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["craeteDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBPush = NCMBPush()
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_sendInBackground_modifiedFields_null")
        sut.sendInBackground(callback: { (result: NCMBResult<Void>) in
            sut.removeField(field: "field1")
            sut.sendInBackground(callback: { (result: NCMBResult<Void>) in
                XCTAssertEqual(executor.requests.count, 2)
                XCTAssertEqual(String(data: executor.requests[1].body!, encoding: .utf8)!, "{\"field1\":null}")
                expectation?.fulfill()
            })
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_delete_success() {
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: [:], statusCode : 201)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let result : NCMBResult<Void> = sut.delete()

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        XCTAssertNil(sut.objectId)
        XCTAssertNil(sut["field1"])
    }

    func test_delete_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let result : NCMBResult<Void> = sut.delete()

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
        XCTAssertEqual(sut.objectId, "abcdefg12345")
        XCTAssertEqual(sut["field1"], "value1")
    }

    func test_deleteInBackground_success() {
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: [:], statusCode : 201)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_deleteInBackground_success")
        sut.deleteInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            XCTAssertNil(sut.objectId)
            XCTAssertNil(sut["field1"])
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_deleteInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_deleteInBackground_failure")
        sut.deleteInBackground(callback: { result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            XCTAssertEqual(sut.objectId, "abcdefg12345")
            XCTAssertEqual(sut["field1"], "value1")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_deleteInBackground_reset_modifiedFields() {
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: [:], statusCode : 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBPush = NCMBPush()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_deleteInBackground_reset_modifiedFields")
        sut.deleteInBackground(callback: { (result: NCMBResult<Void>) in
            sut.sendInBackground(callback: { (result: NCMBResult<Void>) in
                XCTAssertEqual(executor.requests.count, 2)
                XCTAssertEqual(String(data: executor.requests[1].body!, encoding: .utf8)!, "{}")
                expectation?.fulfill()
            })
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    static var allTests = [
        ("test_init_default", test_init_default),
        ("test_deliveryTime", test_deliveryTime),
        ("test_setImmediateDelivery", test_setImmediateDelivery),
        ("test_target", test_target),
        ("test_fetch_success", test_fetch_success),
        ("test_fetch_failure", test_fetch_failure),
        ("test_fetchInBackground_success", test_fetchInBackground_success),
        ("test_fetchInBackground_failure", test_fetchInBackground_failure),
        ("test_fetchInBackground_reset_modifiedFields", test_fetchInBackground_reset_modifiedFields),
        ("test_send_success_insert", test_send_success_insert),
        ("test_send_success_update", test_send_success_update),
        ("test_send_failure", test_send_failure),
        ("test_sendInBackground_success_insert", test_sendInBackground_success_insert),
        ("test_sendInBackground_success_update", test_sendInBackground_success_update),
        ("test_sendInBackground_failure", test_sendInBackground_failure),
        ("test_sendInBackground_reset_modifiedFields", test_sendInBackground_reset_modifiedFields),
        ("test_sendInBackground_modifiedFields_null", test_sendInBackground_modifiedFields_null),
        ("test_delete_success", test_delete_success),
        ("test_delete_failure", test_delete_failure),
        ("test_deleteInBackground_success", test_deleteInBackground_success),
        ("test_deleteInBackground_failure", test_deleteInBackground_failure),
        ("test_deleteInBackground_reset_modifiedFields", test_deleteInBackground_reset_modifiedFields),
    ]
}
