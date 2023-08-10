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

/// NCMBInstallation のテストクラスです。
final class NCMBInstallationTests: NCMBTestCase {

    func test_isIgnoredKey() {
        let sut : NCMBInstallation = NCMBInstallation()
        sut["takanokun"] = 42
        XCTAssertTrue(sut.isIgnoredKey(field: "objectId"))
        XCTAssertTrue(sut.isIgnoredKey(field: "acl"))
        XCTAssertTrue(sut.isIgnoredKey(field: "createDate"))
        XCTAssertTrue(sut.isIgnoredKey(field: "updateDate"))
        XCTAssertFalse(sut.isIgnoredKey(field: "deviceType"))
        XCTAssertFalse(sut.isIgnoredKey(field: "deviceToken"))
        XCTAssertFalse(sut.isIgnoredKey(field: "applicationName"))
        XCTAssertFalse(sut.isIgnoredKey(field: "appVersion"))
        XCTAssertFalse(sut.isIgnoredKey(field: "timeZone"))
        XCTAssertFalse(sut.isIgnoredKey(field: "sdkVersion"))
        XCTAssertFalse(sut.isIgnoredKey(field: "badge"))
        XCTAssertFalse(sut.isIgnoredKey(field: "channels"))
        XCTAssertFalse(sut.isIgnoredKey(field: "takanokun"))
    }

    func test_isIgnoredKey_setFieldValue() {
        let sut : NCMBInstallation = NCMBInstallation()
        sut["objectId"] = "abc"
        sut["acl"] = NCMBACL.default
        sut["createDate"] = "def"
        sut["updateDate"] = "ghi"
        sut["deviceType"] = "jkl"
        sut["deviceToken"] = "mno"
        sut["applicationName"] = "pqr"
        sut["appVersion"] = "stu"
        sut["timeZone"] = "vwx"
        sut["sdkVersion"] = "yza"
        sut["badge"] = "bcd"
        sut["channels"] = "efg"
        sut["takanokun"] = "hij"
        XCTAssertNil(sut["objectId"])
        XCTAssertNil(sut["acl"])
        XCTAssertNil(sut["createDate"])
        XCTAssertNil(sut["updateDate"])
        XCTAssertEqual(sut["deviceType"], "jkl")
        XCTAssertEqual(sut["deviceToken"], "mno")
        XCTAssertEqual(sut["applicationName"], "pqr")
        XCTAssertEqual(sut["appVersion"], "stu")
        XCTAssertEqual(sut["timeZone"], "vwx")
        XCTAssertEqual(sut["sdkVersion"], "yza")
        XCTAssertEqual(sut["badge"], "bcd")
        XCTAssertEqual(sut["channels"], "efg")
        XCTAssertEqual(sut["takanokun"], "hij")
    }

    func test_init() {
        let sut : NCMBInstallation = NCMBInstallation()
        XCTAssertEqual(sut["deviceType"], NCMB.DEVICE_TYPE)
        XCTAssertEqual(sut["sdkVersion"], NCMB.SDK_VERSION)
        XCTAssertEqual((sut["channels"]! as [String]).count, 0)

    }

    func test_deviceType() {
        let sut : NCMBInstallation = NCMBInstallation()
        XCTAssertNotNil(sut.deviceType)
    }

    func test_deviceToken() {
        let sut : NCMBInstallation = NCMBInstallation()
        XCTAssertNotNil(sut.deviceType)
        sut.deviceToken = "takanokun"
        XCTAssertEqual(sut.deviceToken, "takanokun")
    }

    func test_badge() {
        let sut : NCMBInstallation = NCMBInstallation()
        XCTAssertNil(sut.badge)
        sut.badge = 42
        XCTAssertEqual(sut.badge, 42)
    }

    func test_timeZone() {
        let sut : NCMBInstallation = NCMBInstallation()
        XCTAssertNotNil(sut.timeZone)
        sut.timeZone = "takanokun"
        XCTAssertEqual(sut.timeZone, "takanokun")
    }

    func test_channels() {
        let sut : NCMBInstallation = NCMBInstallation()
        XCTAssertEqual(sut.channels!.count, 0)
        sut.channels = ["takanokun", "takano_san", "piyo"]
        XCTAssertEqual(sut.channels!.count, 3)
        XCTAssertEqual(sut.channels![0], "takanokun")
        XCTAssertEqual(sut.channels![1], "takano_san")
        XCTAssertEqual(sut.channels![2], "piyo")
    }

    func test_fetch_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["field2"] = "value2"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetchInBackground_reset_modifiedFields")
        sut.fetchInBackground(callback: { (result: NCMBResult<Void>) in
            sut.saveInBackground(callback: { (result: NCMBResult<Void>) in
                XCTAssertEqual(executor.requests.count, 2)
                XCTAssertNotEqual(String(data: executor.requests[1].body!, encoding: .utf8)!, "{}")
                XCTAssertTrue(String(data: executor.requests[1].body!, encoding: .utf8)!.contains("\"sdkVersion\""))
                XCTAssertTrue(String(data: executor.requests[1].body!, encoding: .utf8)!.contains("\"appVersion\""))
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

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"
        XCTAssertEqual(sut.needUpdate, true)

        let result : NCMBResult<Void> = sut.save()

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
        XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"field1\":\"value1\""))
        XCTAssertEqual(sut.objectId, "abcdefg12345")
        XCTAssertEqual(sut["field1"], "value1")
        XCTAssertEqual(sut["createDate"], "1986-02-04T12:34:56.789Z")
        XCTAssertEqual(sut.needUpdate, false)
    }

    func test_save_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"
        XCTAssertEqual(sut.needUpdate, true)

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_success_update")
        sut.saveInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))

            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)
            XCTAssertTrue(String(data: executor.requests[0].body!, encoding: .utf8)!.contains("\"field1\":\"value1\""))

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

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
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

    func test_saveInBackground_saveToLocalFile() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse: "{\"deviceType\":\"beos\",\"deviceToken\":\"abcdefghijk0123456789\",\"applicationName\":\"takanokun\",\"appVersion\":\"-2.7.18\",\"timeZone\":\"Moon/MareTranquillitatis\",\"sdkVersion\":\"-3.1.4\",\"channels\":[\"fuag\",\"piyo\"]}".data(using: .utf8)!)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)

        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBInstallation = NCMBInstallation()
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_saveToLocalFile")
        sut.saveInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))

            XCTAssertEqual(manager.saveLog.count, 1)
            XCTAssertTrue(String(data: manager.saveLog[0].data, encoding: .utf8)!.contains("\"field1\":\"value1\""))
            XCTAssertEqual(manager.saveLog[0].type, NCMBLocalFileType.currentInstallation)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_delete_success() {
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: [:], statusCode : 201)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBInstallation = NCMBInstallation()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let result : NCMBResult<Void> = sut.delete()

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        XCTAssertNil(sut.objectId)
        XCTAssertNil(sut["field1"])
    }

    func test_delete_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
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

        let sut : NCMBInstallation = NCMBInstallation()
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

    func test_deleteInBackground_deleteLocalFile() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse: nil)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)

        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: [:], statusCode : 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBInstallation = NCMBInstallation()
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let expectation : XCTestExpectation? = self.expectation(description: "test_deleteInBackground_deleteLocalFile")
        sut.deleteInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(manager.deleteLog.count, 1)
            XCTAssertEqual(manager.deleteLog[0], NCMBLocalFileType.currentInstallation)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_currentInstallation_exists_localfile() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse: "{\"deviceType\":\"beos\",\"deviceToken\":\"abcdefghijk0123456789\",\"applicationName\":\"takanokun\",\"appVersion\":\"-2.7.18\",\"timeZone\":\"Moon/MareTranquillitatis\",\"sdkVersion\":\"-3.1.4\",\"channels\":[\"fuag\",\"piyo\"]}".data(using: .utf8)!)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)
        let currentInstallation = NCMBInstallation.currentInstallation
        XCTAssertEqual(currentInstallation["applicationName"], "takanokun")
        XCTAssertEqual(currentInstallation["timeZone"], "Moon/MareTranquillitatis")
    }

    func test_currentInstallation_not_exists_localfile() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse: nil)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)
        let currentInstallation = NCMBInstallation.currentInstallation
        XCTAssertNotEqual(currentInstallation["applicationName"], "takanokun")
        XCTAssertNotEqual(currentInstallation["timeZone"], "Moon/MareTranquillitatis")
    }

    func test_currentInstallation_update_version() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse:"{\"deviceType\":\"beos\",\"deviceToken\":\"abcdefghijk0123456789\",\"applicationName\":\"takanokun\",\"appVersion\":\"-2.7.18\",\"timeZone\":\"Moon/MareTranquillitatis\",\"sdkVersion\":\"-3.1.4\",\"channels\":[\"fuag\",\"piyo\"]}".data(using: .utf8)!)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)
        let currentInstallation = NCMBInstallation.currentInstallation
        XCTAssertEqual(currentInstallation["sdkVersion"], NCMB.SDK_VERSION)
        XCTAssertNotEqual(currentInstallation["appVersion"], "-2.7.18")
    }

    func test_currentInstallation_saveto_localfile() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse: "{\"deviceType\":\"beos\",\"deviceToken\":\"abcdefghijk0123456789\",\"applicationName\":\"takanokun\",\"appVersion\":\"-2.7.18\",\"timeZone\":\"Moon/MareTranquillitatis\",\"sdkVersion\":\"-3.1.4\",\"channels\":[\"fuag\",\"piyo\"]}".data(using: .utf8)!)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)
        _ = NCMBInstallation.currentInstallation
        XCTAssertEqual(manager.saveLog.count, 1)
        XCTAssertTrue(String(data: manager.saveLog[0].data, encoding: .utf8)!.contains("\"sdkVersion\":\"1.4.0\""))
        XCTAssertEqual(manager.saveLog[0].type, NCMBLocalFileType.currentInstallation)
    }

    func test_currentInstallation_without_sharing() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse: "{\"deviceType\":\"beos\",\"deviceToken\":\"abcdefghijk0123456789\",\"applicationName\":\"takanokun\",\"appVersion\":\"-2.7.18\",\"timeZone\":\"Moon/MareTranquillitatis\",\"sdkVersion\":\"-3.1.4\",\"channels\":[\"fuag\",\"piyo\"]}".data(using: .utf8)!)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)
        let currentInstallation1 = NCMBInstallation.currentInstallation
        currentInstallation1.deviceToken = "wxzy012345abcdef"
        let currentInstallation2 = NCMBInstallation.currentInstallation
        XCTAssertEqual(currentInstallation1.deviceToken, "wxzy012345abcdef")
        XCTAssertEqual(currentInstallation2.deviceToken, "abcdefghijk0123456789")
    }

    func test_setDeviceTokenFromData() {
        let sut : NCMBInstallation = NCMBInstallation()
        let data : Data = Data([45, 61, 140, 92, 49, 156, 160, 9, 174, 36, 215, 213, 66, 228, 94, 36, 169, 156, 39, 217, 90, 44, 173, 63, 215, 152, 12, 22, 213, 227, 248, 180])
        sut.setDeviceTokenFromData(data: data)
        XCTAssertEqual(sut.deviceToken, "2d3d8c5c319ca009ae24d7d542e45e24a99c27d95a2cad3fd7980c16d5e3f8b4")
    }

    func test_loadFromFile_success() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse: "{\"deviceType\":\"beos\",\"deviceToken\":\"abcdefghijk0123456789\",\"applicationName\":\"takanokun\",\"appVersion\":\"-2.7.18\",\"timeZone\":\"Moon/MareTranquillitatis\",\"sdkVersion\":\"-3.1.4\",\"channels\":[\"fuag\",\"piyo\"]}".data(using: .utf8)!)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)

        let installation : NCMBInstallation? = NCMBInstallation.loadFromFile()
        XCTAssertEqual(installation!.deviceToken, "abcdefghijk0123456789")
    }

    func test_loadFromFile_noData() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse: nil)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)

        let installation : NCMBInstallation? = NCMBInstallation.loadFromFile()
        XCTAssertNil(installation)
    }

    func test_loadFromFile_invalidJson() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse: "\"deviceType\":\"beos\",\"deviceToken\":\"abcdefghijk0123456789\",\"applicationName\":\"takanokun\",\"appVersion\":\"-2.7.18\",\"timeZone\":\"Moon/MareTranquillitatis\",\"sdkVersion\":\"-3.1.4\",\"channels\":[\"fuag\",\"piyo\"]}".data(using: .utf8)!)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)

        let installation : NCMBInstallation? = NCMBInstallation.loadFromFile()
        XCTAssertNil(installation)
    }

    func test_saveToFile() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse: nil)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)

        let sut : NCMBInstallation = NCMBInstallation()
        sut.objectId = "hijklmn789"
        sut.deviceToken = "abcdefghijk0123456789"

        sut.saveToFile()

        XCTAssertEqual(manager.saveLog.count, 1)
        XCTAssertTrue(String(data: manager.saveLog[0].data, encoding: .utf8)!.contains("\"objectId\":\"hijklmn789\""))
        XCTAssertTrue(String(data: manager.saveLog[0].data, encoding: .utf8)!.contains("\"deviceToken\":\"abcdefghijk0123456789\""))
    }

    func test_deleteFile() {
        let manager : MockLocalFileManager = MockLocalFileManager(loadResponse: nil)
        NCMBLocalFileManagerFactory.setInstance(manager: manager)

        NCMBInstallation.deleteFile()

        XCTAssertEqual(manager.deleteLog.count, 1)
        XCTAssertEqual(manager.deleteLog[0], NCMBLocalFileType.currentInstallation)
    }

    static var allTests = [
        ("test_isIgnoredKey", test_isIgnoredKey),
        ("test_isIgnoredKey_setFieldValue", test_isIgnoredKey_setFieldValue),
        ("test_init", test_init),
        ("test_deviceType", test_deviceType),
        ("test_deviceToken", test_deviceToken),
        ("test_badge", test_badge),
        ("test_timeZone", test_timeZone),
        ("test_channels", test_channels),
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
        ("test_saveInBackground_saveToLocalFile", test_saveInBackground_saveToLocalFile),
        ("test_delete_success", test_delete_success),
        ("test_delete_failure", test_delete_failure),
        ("test_deleteInBackground_success", test_deleteInBackground_success),
        ("test_deleteInBackground_failure", test_deleteInBackground_failure),
        ("test_deleteInBackground_reset_modifiedFields", test_deleteInBackground_reset_modifiedFields),
        ("test_deleteInBackground_deleteLocalFile", test_deleteInBackground_deleteLocalFile),
        ("test_currentInstallation_exists_localfile", test_currentInstallation_exists_localfile),
        ("test_currentInstallation_not_exists_localfile", test_currentInstallation_not_exists_localfile),
        ("test_currentInstallation_update_version", test_currentInstallation_update_version),
        ("test_currentInstallation_saveto_localfile", test_currentInstallation_saveto_localfile),
        ("test_currentInstallation_without_sharing", test_currentInstallation_without_sharing),
        ("test_setDeviceTokenFromData", test_setDeviceTokenFromData),
        ("test_loadFromFile_success", test_loadFromFile_success),
        ("test_loadFromFile_noData", test_loadFromFile_noData),
        ("test_loadFromFile_invalidJson", test_loadFromFile_invalidJson),
        ("test_saveToFile", test_saveToFile),
        ("test_deleteFile", test_deleteFile),    ]
}
