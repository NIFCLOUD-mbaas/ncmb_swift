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

/// NCMBFile のテストクラスです。
final class NCMBFileTests: NCMBTestCase {

    func test_fileName() {
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")
        XCTAssertEqual(sut.fileName,"takano_san.js")
        sut.fileName = "takanokun.rb"
        XCTAssertEqual(sut.fileName,"takanokun.rb")
    }

    func test_init_no_acl() {
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")
        XCTAssertNil(sut.acl)
    }

    func test_init_acl() {
        var acl : NCMBACL = NCMBACL.empty
        acl.put(key: "piyo", readable: true, writable: false)
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js", acl: acl)
        XCTAssertEqual(sut.acl!.getReadable(key: "*"), nil)
        XCTAssertEqual(sut.acl!.getWritable(key: "*"), nil)
        XCTAssertEqual(sut.acl!.getReadable(key: "piyo"), true)
        XCTAssertEqual(sut.acl!.getWritable(key: "piyo"), false)
    }

    func test_isIgnoredKey() {
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")
        sut["takanokun"] = 42
        XCTAssertTrue(sut.isIgnoredKey(field: "objectId"))
        XCTAssertTrue(sut.isIgnoredKey(field: "acl"))
        XCTAssertTrue(sut.isIgnoredKey(field: "createDate"))
        XCTAssertTrue(sut.isIgnoredKey(field: "updateDate"))
        XCTAssertTrue(sut.isIgnoredKey(field: "fileName"))
        XCTAssertTrue(sut.isIgnoredKey(field: "mimeType"))
        XCTAssertTrue(sut.isIgnoredKey(field: "fileSize"))
        XCTAssertTrue(sut.isIgnoredKey(field: "takanokun"))
    }

    func test_isIgnoredKey_setFieldValue() {
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")
        sut["objectId"] = "abc"
        sut["acl"] = NCMBACL.default
        sut["createDate"] = "def"
        sut["updateDate"] = "ghi"
        sut["fileName"] = "jkl"
        sut["mimeType"] = "mno"
        sut["fileSize"] = "pqr"
        sut["takanokun"] = "stu"
        XCTAssertNil(sut["objectId"])
        XCTAssertNil(sut["acl"])
        XCTAssertNil(sut["createDate"])
        XCTAssertNil(sut["updateDate"])
        XCTAssertNil(sut["fileName"])
        XCTAssertNil(sut["mimeType"])
        XCTAssertNil(sut["fileSize"])
        XCTAssertNil(sut["takanokun"])
    }

    func test_fetch_success() {
        let body : Data = "lkjhgfdsa987654".data(using: .utf8)!
        let mockResponse : NCMBResponse = MockResponseBuilder.createResponse(body: body, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(mockResponse)))

        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")

        let result : NCMBResult<Data?> = sut.fetch()
        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        let response : Data = NCMBTestUtil.getResponse(result: result)!!
        XCTAssertEqual(String(data: response, encoding: .utf8), "lkjhgfdsa987654")
    }

    func test_fetch_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")

        let result : NCMBResult<Data?> = sut.fetch()
        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_fetchInBackground_success() {
        let body : Data = "lkjhgfdsa987654".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: body, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetchInBackground_success")
        sut.fetchInBackground(callback: { (result: NCMBResult<Data?>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response : Data = NCMBTestUtil.getResponse(result: result)!!
            XCTAssertEqual(String(data: response, encoding: .utf8), "lkjhgfdsa987654")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_fetchInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")

        let expectation : XCTestExpectation? = self.expectation(description: "test_fetchInBackground_failure")
        sut.fetchInBackground(callback: { (result: NCMBResult<Data?>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_save_success() {
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: "".data(using: .utf8)!, statusCode: 200)
        let executor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        var acl : NCMBACL = NCMBACL.empty
        acl.put(key: "piyo", readable: true, writable: false)
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js", acl: acl)
        let data : Data = "abcdefg".data(using: .utf8)!

        let result : NCMBResult<Void> = sut.save(data: data)

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
    }

    func test_save_failure() {
        let executor = MockRequestExecutor(result: .failure(DummyErrors.dummyError))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        var acl : NCMBACL = NCMBACL.empty
        acl.put(key: "piyo", readable: true, writable: false)
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js", acl: acl)
        let data : Data = "abcdefg".data(using: .utf8)!

        let result : NCMBResult<Void> = sut.save(data: data)

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
    }

    func test_saveInBackground_success() {
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: "".data(using: .utf8)!, statusCode: 200)
        let executor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        var acl : NCMBACL = NCMBACL.empty
        acl.put(key: "piyo", readable: true, writable: false)
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js", acl: acl)
        let data : Data = "abcdefg".data(using: .utf8)!

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_success")
        sut.saveInBackground(data: data, callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_saveInBackground_failure() {
        let executor = MockRequestExecutor(result: .failure(DummyErrors.dummyError))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        var acl : NCMBACL = NCMBACL.empty
        acl.put(key: "piyo", readable: true, writable: false)
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js", acl: acl)
        let data : Data = "abcdefg".data(using: .utf8)!

        let expectation : XCTestExpectation? = self.expectation(description: "test_saveInBackground_failure")
        sut.saveInBackground(data: data, callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_update_success() {
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: "".data(using: .utf8)!, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        var acl : NCMBACL = NCMBACL.empty
        acl.put(key: "piyo", readable: true, writable: false)
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js", acl: acl)

        let result : NCMBResult<Void> = sut.update()
        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
    }

    func test_update_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        var acl : NCMBACL = NCMBACL.empty
        acl.put(key: "piyo", readable: true, writable: false)
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js", acl: acl)

        let result : NCMBResult<Void> = sut.update()
        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_updateInBackground_success() {
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: "".data(using: .utf8)!, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        var acl : NCMBACL = NCMBACL.empty
        acl.put(key: "piyo", readable: true, writable: false)
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js", acl: acl)

        let expectation : XCTestExpectation? = self.expectation(description: "test_updateInBackground_success")
        sut.updateInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_updateInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        var acl : NCMBACL = NCMBACL.empty
        acl.put(key: "piyo", readable: true, writable: false)
        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js", acl: acl)

        let expectation : XCTestExpectation? = self.expectation(description: "test_updateInBackground_failure")
        sut.updateInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_delete_success() {
        let body : Data = "".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: body, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")

        let result : NCMBResult<Void> = sut.delete()
        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
    }

    func test_delete_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")

        let result : NCMBResult<Void> = sut.delete()
        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_deleteInBackground_success() {
        let body : Data = "".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: body, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")

        let expectation : XCTestExpectation? = self.expectation(description: "test_deleteInBackground_success")
        sut.deleteInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_deleteInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBFile = NCMBFile(fileName: "takano_san.js")

        let expectation : XCTestExpectation? = self.expectation(description: "test_deleteInBackground_failure")
        sut.deleteInBackground(callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    static var allTests = [
        ("test_fileName", test_fileName),
        ("test_init_no_acl", test_init_no_acl),
        ("test_init_acl", test_init_acl),
        ("test_isIgnoredKey", test_isIgnoredKey),
        ("test_isIgnoredKey_setFieldValue", test_isIgnoredKey_setFieldValue),
        ("test_fetch_success", test_fetch_success),
        ("test_fetch_failure", test_fetch_failure),
        ("test_fetchInBackground_success", test_fetchInBackground_success),
        ("test_fetchInBackground_failure", test_fetchInBackground_failure),
        ("test_save_success", test_save_success),
        ("test_save_failure", test_save_failure),
        ("test_saveInBackground_success", test_saveInBackground_success),
        ("test_saveInBackground_failure", test_saveInBackground_failure),
        ("test_update_success", test_update_success),
        ("test_update_failure", test_update_failure),
        ("test_updateInBackground_success", test_updateInBackground_success),
        ("test_updateInBackground_failure", test_updateInBackground_failure),
        ("test_delete_success", test_delete_success),
        ("test_delete_failure", test_delete_failure),
        ("test_deleteInBackground_success", test_deleteInBackground_success),
        ("test_deleteInBackground_failure", test_deleteInBackground_failure),
    ]
}
