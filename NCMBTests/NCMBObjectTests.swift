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

/// NCMBObject のテストクラスです。
final class NCMBObjectTests: NCMBTestCase {

    func test_fetch_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["field2"] = "value2"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBObject = NCMBObject(className: "TestClass")
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

        let sut : NCMBObject = NCMBObject(className: "TestClass")
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

        let sut : NCMBObject = NCMBObject(className: "TestClass")
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

        let sut : NCMBObject = NCMBObject(className: "TestClass")
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

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetchInBackground_reset_modifiedFields")
        sut.fetchInBackground(callback: { (result: NCMBResult<Void>) in
            sut.saveInBackground(callback: { (result: NCMBResult<Void>) in
                XCTAssertEqual(executor.requests.count, 2)
                XCTAssertEqual(String(data: executor.requests[1].body!, encoding: .utf8)!, "{}")
                expectation?.fulfill()
            })
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_save_success_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut["field1"] = "value1"

        let result : NCMBResult<Void> = sut.save()

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
        XCTAssertEqual(sut.objectId, "abcdefg12345")
        XCTAssertEqual(sut["field1"], "value1")
        XCTAssertEqual(sut["createDate"], "1986-02-04T12:34:56.789Z")
    }

    func test_save_success_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"
        XCTAssertEqual(sut.needUpdate, true)

        let result : NCMBResult<Void> = sut.save()

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
        XCTAssertEqual(String(data: executor.requests[0].body!, encoding: .utf8)!, "{\"field1\":\"value1\"}")
        XCTAssertEqual(sut.objectId, "abcdefg12345")
        XCTAssertEqual(sut["field1"], "value1")
        XCTAssertEqual(sut["createDate"], "1986-02-04T12:34:56.789Z")
        XCTAssertEqual(sut.needUpdate, false)
    }

    func test_save_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut["field1"] = "value1"

        let result : NCMBResult<Void> = sut.save()

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
        XCTAssertEqual(sut["field1"], "value1")
    }

    func test_saveInBackground_success_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_success_insert")
        sut.saveInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))

            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

            XCTAssertEqual(sut.objectId, "abcdefg12345")
            XCTAssertEqual(sut["field1"], "value1")
            XCTAssertEqual(sut["createDate"], "1986-02-04T12:34:56.789Z")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_saveInBackground_success_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"
        XCTAssertEqual(sut.needUpdate, true)

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_success_update")
        sut.saveInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))

            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
            XCTAssertEqual(String(data: executor.requests[0].body!, encoding: .utf8)!, "{\"field1\":\"value1\"}")

            XCTAssertEqual(sut.objectId, "abcdefg12345")
            XCTAssertEqual(sut["field1"], "value1")
            XCTAssertEqual(sut["createDate"], "1986-02-04T12:34:56.789Z")
            XCTAssertEqual(sut.needUpdate, false)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_saveInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_failure")
        sut.saveInBackground(callback: { result in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            XCTAssertEqual(sut["field1"], "value1")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_saveInBackground_reset_modifiedFields() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_reset_modifiedFields")
        sut.saveInBackground(callback: { (result: NCMBResult<Void>) in
            sut["field2"] = "value2"
            sut.saveInBackground(callback: { (result: NCMBResult<Void>) in
                XCTAssertEqual(executor.requests.count, 2)
                XCTAssertEqual(String(data: executor.requests[1].body!, encoding: .utf8)!, "{\"field2\":\"value2\"}")
                expectation?.fulfill()
            })
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_saveInBackground_modifiedFields_null() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_modifiedFields_null")
        sut.saveInBackground(callback: { (result: NCMBResult<Void>) in
            sut.removeField(field: "field1")
            sut.saveInBackground(callback: { (result: NCMBResult<Void>) in
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

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let result : NCMBResult<Void> = sut.delete()

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        XCTAssertNil(sut.objectId)
        XCTAssertNil(sut["field1"])
    }

    func test_delete_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBObject = NCMBObject(className: "TestClass")
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

        let sut : NCMBObject = NCMBObject(className: "TestClass")
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

        let sut : NCMBObject = NCMBObject(className: "TestClass")
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

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_deleteInBackground_reset_modifiedFields")
        sut.deleteInBackground(callback: { (result: NCMBResult<Void>) in
            sut.saveInBackground(callback: { (result: NCMBResult<Void>) in
                XCTAssertEqual(executor.requests.count, 2)
                XCTAssertEqual(String(data: executor.requests[1].body!, encoding: .utf8)!, "{}")
                expectation?.fulfill()
            })
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }
    
    func test_saveInBackground_async_success_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_async_success_insert")
        Task(priority: .background) {
            let result = await sut.saveInBackground_async()
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))

            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

            XCTAssertEqual(sut.objectId, "abcdefg12345")
            XCTAssertEqual(sut["field1"], "value1")
            XCTAssertEqual(sut["createDate"], "1986-02-04T12:34:56.789Z")
            expectation?.fulfill()
        }
        self.waitForExpectations(timeout: 10.00, handler: nil)
    }

    func test_saveInBackground_async_success_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"
        XCTAssertEqual(sut.needUpdate, true)

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_async_success_update")
        Task(priority: .background) {
            let result = await sut.saveInBackground_async()
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))

            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
            XCTAssertEqual(String(data: executor.requests[0].body!, encoding: .utf8)!, "{\"field1\":\"value1\"}")

            XCTAssertEqual(sut.objectId, "abcdefg12345")
            XCTAssertEqual(sut["field1"], "value1")
            XCTAssertEqual(sut["createDate"], "1986-02-04T12:34:56.789Z")
            XCTAssertEqual(sut.needUpdate, false)
            expectation?.fulfill()
        }
        self.waitForExpectations(timeout: 10.00, handler: nil)
    }

    func test_saveInBackground_async_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_async_failure")
        Task(priority: .background) {
            let result = await sut.saveInBackground_async()
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            XCTAssertEqual(sut["field1"], "value1")
            expectation?.fulfill()
        }
        self.waitForExpectations(timeout: 10.00, handler: nil)
    }

    func test_saveInBackground_async_reset_modifiedFields() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_async_reset_modifiedFields")
        Task(priority: .background) {
            let _ = await sut.saveInBackground_async()
            sut["field2"] = "value2"
            
            let _ = await sut.saveInBackground_async()
            XCTAssertEqual(executor.requests.count, 2)
            XCTAssertEqual(String(data: executor.requests[1].body!, encoding: .utf8)!, "{\"field2\":\"value2\"}")
            expectation?.fulfill()
        }
        self.waitForExpectations(timeout: 10.00, handler: nil)
    }

    func test_saveInBackground_async_modifiedFields_null() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_async_modifiedFields_null")
        Task(priority: .background) {
            let _ = await sut.saveInBackground_async()
            sut.removeField(field: "field1")
            
            let _ = await sut.saveInBackground_async()
            XCTAssertEqual(executor.requests.count, 2)
            XCTAssertEqual(String(data: executor.requests[1].body!, encoding: .utf8)!, "{\"field1\":null}")
            expectation?.fulfill()
        }
        self.waitForExpectations(timeout: 10.00, handler: nil)
    }

    static var allTests = [
        ("test_fetch_success", test_fetch_success),
        ("test_fetch_failure", test_fetch_failure),
        ("test_fetchInBackground_success", test_fetchInBackground_success),
        ("test_fetchInBackground_failure", test_fetchInBackground_failure),
        ("test_fetchInBackground_reset_modifiedFields", test_fetchInBackground_reset_modifiedFields),
        ("test_save_success_insert", test_save_success_insert),
        ("test_save_success_update", test_save_success_update),
        ("test_save_failure", test_save_failure),
        ("test_saveInBackground_success_insert", test_saveInBackground_success_insert),
        ("test_saveInBackground_success_update", test_saveInBackground_success_update),
        ("test_saveInBackground_failure", test_saveInBackground_failure),
        ("test_saveInBackground_reset_modifiedFields", test_saveInBackground_reset_modifiedFields),
        ("test_saveInBackground_modifiedFields_null", test_saveInBackground_modifiedFields_null),
        ("test_delete_success", test_delete_success),
        ("test_delete_failure", test_delete_failure),
        ("test_deleteInBackground_success", test_deleteInBackground_success),
        ("test_deleteInBackground_failure", test_deleteInBackground_failure),
        ("test_deleteInBackground_reset_modifiedFields", test_deleteInBackground_reset_modifiedFields),
        ("test_saveInBackground_async_success_insert", test_saveInBackground_async_success_insert),
        ("test_saveInBackground_async_success_update", test_saveInBackground_async_success_update),
        ("test_saveInBackground_async_failure", test_saveInBackground_async_failure),
        ("test_saveInBackground_async_reset_modifiedFields", test_saveInBackground_async_reset_modifiedFields),
        ("test_saveInBackground_async_modifiedFields_null", test_saveInBackground_async_modifiedFields_null),
    ]

}
