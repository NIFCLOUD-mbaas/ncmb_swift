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

/// NCMBRole のテストクラスです。
final class NCMBRoleTests: NCMBTestCase {

    func test_isIgnoredKey() {
        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut["takanokun"] = 42
        XCTAssertTrue(sut.isIgnoredKey(field: "objectId"))
        XCTAssertTrue(sut.isIgnoredKey(field: "acl"))
        XCTAssertTrue(sut.isIgnoredKey(field: "createDate"))
        XCTAssertTrue(sut.isIgnoredKey(field: "updateDate"))
        XCTAssertFalse(sut.isIgnoredKey(field: "roleName"))
        XCTAssertFalse(sut.isIgnoredKey(field: "belongRole"))
        XCTAssertFalse(sut.isIgnoredKey(field: "belongUser"))
        XCTAssertFalse(sut.isIgnoredKey(field: "takanokun"))
    }

    func test_isIgnoredKey_setFieldValue() {
        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut["objectId"] = "abc"
        sut["acl"] = NCMBACL.default
        sut["createDate"] = "def"
        sut["updateDate"] = "ghi"
        sut["roleName"] = "jkl"
        sut["belongRole"] = "mno"
        sut["belongUser"] = "pqr"
        sut["takanokun"] = "stu"
        XCTAssertNil(sut["objectId"])
        XCTAssertNil(sut["acl"])
        XCTAssertNil(sut["createDate"])
        XCTAssertNil(sut["updateDate"])
        XCTAssertEqual(sut["roleName"], "jkl")
        XCTAssertEqual(sut["belongRole"], "mno")
        XCTAssertEqual(sut["belongUser"], "pqr")
        XCTAssertEqual(sut["takanokun"], "stu")
    }

    func test_roleName() {
        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.roleName = "takanokun"
        XCTAssertEqual(sut.roleName, "takanokun")
    }

    func test_query() {
        XCTAssertEqual(String(describing: type(of: NCMBRole.query.service)), "NCMBRoleService")
    }

    func test_init() {
        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        XCTAssertEqual(sut.roleName, "Testrole")
    }

    func test_addUser_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        _ = sut.addUser(user: userA)

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
        let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
        XCTAssertEqual(belongUser["__op"] as! String, "AddRelation")
        XCTAssertNotNil(belongUser["objects"] as! [Any])
        let objects = belongUser["objects"] as! [Any]
        XCTAssertEqual(objects.count, 1)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "user")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
    }

    func test_addUser_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        _ = sut.addUser(user: userA)

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
        let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
        XCTAssertEqual(belongUser["__op"] as! String, "AddRelation")
        XCTAssertNotNil(belongUser["objects"] as! [Any])
        let objects = belongUser["objects"] as! [Any]
        XCTAssertEqual(objects.count, 1)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "user")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
    }

    func test_addUser_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.addUser(user: userA)

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
    }

    func test_addUser_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.addUser(user: userA)

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_addUserInBackground_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_addUserInBackground_request_insert")
        sut.addUserInBackground(user: userA, callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
            let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
            XCTAssertEqual(belongUser["__op"] as! String, "AddRelation")
            XCTAssertNotNil(belongUser["objects"] as! [Any])
            let objects = belongUser["objects"] as! [Any]
            XCTAssertEqual(objects.count, 1)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "user")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addUserInBackground_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_addUserInBackground_request_update")
        sut.addUserInBackground(user: userA, callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
            let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
            XCTAssertEqual(belongUser["__op"] as! String, "AddRelation")
            XCTAssertNotNil(belongUser["objects"] as! [Any])
            let objects = belongUser["objects"] as! [Any]
            XCTAssertEqual(objects.count, 1)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "user")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addUserInBackground_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_addUserInBackground_success")
        sut.addUserInBackground(user: userA, callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addUserInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_addUserInBackground_failure")
        sut.addUserInBackground(user: userA, callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addUsers_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        _ = sut.addUsers(users: [userA, userB, userC])

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
        let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
        XCTAssertEqual(belongUser["__op"] as! String, "AddRelation")
        XCTAssertNotNil(belongUser["objects"] as! [Any])
        let objects = belongUser["objects"] as! [Any]
        XCTAssertEqual(objects.count, 2)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "user")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
        let object1 = objects[1] as! [String:Any]
        XCTAssertEqual(object1["__type"] as! String, "Pointer")
        XCTAssertEqual(object1["className"] as! String, "user")
        XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
    }

    func test_addUsers_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        _ = sut.addUsers(users: [userA, userB, userC])

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
        let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
        XCTAssertEqual(belongUser["__op"] as! String, "AddRelation")
        XCTAssertNotNil(belongUser["objects"] as! [Any])
        let objects = belongUser["objects"] as! [Any]
        XCTAssertEqual(objects.count, 2)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "user")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
        let object1 = objects[1] as! [String:Any]
        XCTAssertEqual(object1["__type"] as! String, "Pointer")
        XCTAssertEqual(object1["className"] as! String, "user")
        XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
    }

    func test_addUsers_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.addUsers(users: [userA, userB, userC])

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
    }

    func test_addUsers_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.addUsers(users: [userA, userB, userC])

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_addUsersInBackground_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_addUsersInBackground_request_insert")
        sut.addUsersInBackground(users: [userA, userB, userC], callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
            let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
            XCTAssertEqual(belongUser["__op"] as! String, "AddRelation")
            XCTAssertNotNil(belongUser["objects"] as! [Any])
            let objects = belongUser["objects"] as! [Any]
            XCTAssertEqual(objects.count, 2)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "user")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            let object1 = objects[1] as! [String:Any]
            XCTAssertEqual(object1["__type"] as! String, "Pointer")
            XCTAssertEqual(object1["className"] as! String, "user")
            XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addUsersInBackground_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_addUsersInBackground_request_update")
        sut.addUsersInBackground(users: [userA, userB, userC], callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
            let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
            XCTAssertEqual(belongUser["__op"] as! String, "AddRelation")
            XCTAssertNotNil(belongUser["objects"] as! [Any])
            let objects = belongUser["objects"] as! [Any]
            XCTAssertEqual(objects.count, 2)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "user")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            let object1 = objects[1] as! [String:Any]
            XCTAssertEqual(object1["__type"] as! String, "Pointer")
            XCTAssertEqual(object1["className"] as! String, "user")
            XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addUsersInBackground_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_addUsersInBackground_success")
        sut.addUsersInBackground(users: [userA, userB, userC], callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addUsersInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_addUsersInBackground_failure")
        sut.addUsersInBackground(users: [userA, userB, userC], callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeUser_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        _ = sut.removeUser(user: userA)

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
        let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
        XCTAssertEqual(belongUser["__op"] as! String, "RemoveRelation")
        XCTAssertNotNil(belongUser["objects"] as! [Any])
        let objects = belongUser["objects"] as! [Any]
        XCTAssertEqual(objects.count, 1)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "user")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
    }

    func test_removeUser_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        _ = sut.removeUser(user: userA)

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
        let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
        XCTAssertEqual(belongUser["__op"] as! String, "RemoveRelation")
        XCTAssertNotNil(belongUser["objects"] as! [Any])
        let objects = belongUser["objects"] as! [Any]
        XCTAssertEqual(objects.count, 1)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "user")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
    }

    func test_removeUser_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.removeUser(user: userA)

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
    }

    func test_removeUser_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.removeUser(user: userA)

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_removeUserInBackground_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeUserInBackground_request_insert")
        sut.removeUserInBackground(user: userA, callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
            let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
            XCTAssertEqual(belongUser["__op"] as! String, "RemoveRelation")
            XCTAssertNotNil(belongUser["objects"] as! [Any])
            let objects = belongUser["objects"] as! [Any]
            XCTAssertEqual(objects.count, 1)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "user")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeUserInBackground_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeUserInBackground_request_update")
        sut.removeUserInBackground(user: userA, callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
            let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
            XCTAssertEqual(belongUser["__op"] as! String, "RemoveRelation")
            XCTAssertNotNil(belongUser["objects"] as! [Any])
            let objects = belongUser["objects"] as! [Any]
            XCTAssertEqual(objects.count, 1)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "user")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeUserInBackground_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeUserInBackground_success")
        sut.removeUserInBackground(user: userA, callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeUserInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeUserInBackground_failure")
        sut.removeUserInBackground(user: userA, callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeUsers_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        _ = sut.removeUsers(users: [userA, userB, userC])

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
        let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
        XCTAssertEqual(belongUser["__op"] as! String, "RemoveRelation")
        XCTAssertNotNil(belongUser["objects"] as! [Any])
        let objects = belongUser["objects"] as! [Any]
        XCTAssertEqual(objects.count, 2)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "user")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
        let object1 = objects[1] as! [String:Any]
        XCTAssertEqual(object1["__type"] as! String, "Pointer")
        XCTAssertEqual(object1["className"] as! String, "user")
        XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
    }

    func test_removeUsers_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        _ = sut.removeUsers(users: [userA, userB, userC])

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
        let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
        XCTAssertEqual(belongUser["__op"] as! String, "RemoveRelation")
        XCTAssertNotNil(belongUser["objects"] as! [Any])
        let objects = belongUser["objects"] as! [Any]
        XCTAssertEqual(objects.count, 2)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "user")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
        let object1 = objects[1] as! [String:Any]
        XCTAssertEqual(object1["__type"] as! String, "Pointer")
        XCTAssertEqual(object1["className"] as! String, "user")
        XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
    }

    func test_removeUsers_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.removeUsers(users: [userA, userB, userC])

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
    }

    func test_removeUsers_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.removeUsers(users: [userA, userB, userC])

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_removeUsersInBackground_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeUsersInBackground_request_insert")
        sut.removeUsersInBackground(users: [userA, userB, userC], callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
            let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
            XCTAssertEqual(belongUser["__op"] as! String, "RemoveRelation")
            XCTAssertNotNil(belongUser["objects"] as! [Any])
            let objects = belongUser["objects"] as! [Any]
            XCTAssertEqual(objects.count, 2)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "user")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            let object1 = objects[1] as! [String:Any]
            XCTAssertEqual(object1["__type"] as! String, "Pointer")
            XCTAssertEqual(object1["className"] as! String, "user")
            XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeUsersInBackground_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeUsersInBackground_request_update")
        sut.removeUsersInBackground(users: [userA, userB, userC], callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongUser"] as! [String:Any])
            let belongUser = requestBodyKeyValue["belongUser"] as! [String:Any]
            XCTAssertEqual(belongUser["__op"] as! String, "RemoveRelation")
            XCTAssertNotNil(belongUser["objects"] as! [Any])
            let objects = belongUser["objects"] as! [Any]
            XCTAssertEqual(objects.count, 2)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "user")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            let object1 = objects[1] as! [String:Any]
            XCTAssertEqual(object1["__type"] as! String, "Pointer")
            XCTAssertEqual(object1["className"] as! String, "user")
            XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeUsersInBackground_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeUsersInBackground_success")
        sut.removeUsersInBackground(users: [userA, userB, userC], callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeUsersInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "hijklmn67890"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeUsersInBackground_failure")
        sut.removeUsersInBackground(users: [userA, userB, userC], callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addRole_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        _ = sut.addRole(role: roleA)

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
        let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
        XCTAssertEqual(belongRole["__op"] as! String, "AddRelation")
        XCTAssertNotNil(belongRole["objects"] as! [Any])
        let objects = belongRole["objects"] as! [Any]
        XCTAssertEqual(objects.count, 1)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "role")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
    }

    func test_addRole_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        _ = sut.addRole(role: roleA)

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
        let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
        XCTAssertEqual(belongRole["__op"] as! String, "AddRelation")
        XCTAssertNotNil(belongRole["objects"] as! [Any])
        let objects = belongRole["objects"] as! [Any]
        XCTAssertEqual(objects.count, 1)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "role")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
    }

    func test_addRole_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.addRole(role: roleA)

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
    }

    func test_addRole_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.addRole(role: roleA)

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_addRoleInBackground_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_addRoleInBackground_request_insert")
        sut.addRoleInBackground(role: roleA, callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
            let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
            XCTAssertEqual(belongRole["__op"] as! String, "AddRelation")
            XCTAssertNotNil(belongRole["objects"] as! [Any])
            let objects = belongRole["objects"] as! [Any]
            XCTAssertEqual(objects.count, 1)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "role")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addRoleInBackground_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_addRoleInBackground_request_update")
        sut.addRoleInBackground(role: roleA, callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
            let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
            XCTAssertEqual(belongRole["__op"] as! String, "AddRelation")
            XCTAssertNotNil(belongRole["objects"] as! [Any])
            let objects = belongRole["objects"] as! [Any]
            XCTAssertEqual(objects.count, 1)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "role")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addRoleInBackground_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_addRoleInBackground_success")
        sut.addRoleInBackground(role: roleA, callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addRoleInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_addRoleInBackground_failure")
        sut.addRoleInBackground(role: roleA, callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addRoles_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        _ = sut.addRoles(roles: [roleA, roleB, roleC])

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
        let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
        XCTAssertEqual(belongRole["__op"] as! String, "AddRelation")
        XCTAssertNotNil(belongRole["objects"] as! [Any])
        let objects = belongRole["objects"] as! [Any]
        XCTAssertEqual(objects.count, 2)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "role")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
        let object1 = objects[1] as! [String:Any]
        XCTAssertEqual(object1["__type"] as! String, "Pointer")
        XCTAssertEqual(object1["className"] as! String, "role")
        XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
    }

    func test_addRoles_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        _ = sut.addRoles(roles: [roleA, roleB, roleC])

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
        let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
        XCTAssertEqual(belongRole["__op"] as! String, "AddRelation")
        XCTAssertNotNil(belongRole["objects"] as! [Any])
        let objects = belongRole["objects"] as! [Any]
        XCTAssertEqual(objects.count, 2)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "role")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
        let object1 = objects[1] as! [String:Any]
        XCTAssertEqual(object1["__type"] as! String, "Pointer")
        XCTAssertEqual(object1["className"] as! String, "role")
        XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
    }

    func test_addRoles_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let result : NCMBResult<Void> = sut.addRoles(roles: [roleA, roleB, roleC])

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
    }

    func test_addRoles_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let result : NCMBResult<Void> = sut.addRoles(roles: [roleA, roleB, roleC])

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_addRolesInBackground_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_addRolesInBackground_request_insert")
        sut.addRolesInBackground(roles: [roleA, roleB, roleC], callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
            let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
            XCTAssertEqual(belongRole["__op"] as! String, "AddRelation")
            XCTAssertNotNil(belongRole["objects"] as! [Any])
            let objects = belongRole["objects"] as! [Any]
            XCTAssertEqual(objects.count, 2)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "role")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            let object1 = objects[1] as! [String:Any]
            XCTAssertEqual(object1["__type"] as! String, "Pointer")
            XCTAssertEqual(object1["className"] as! String, "role")
            XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addRolesInBackground_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_addRolesInBackground_request_update")
        sut.addRolesInBackground(roles: [roleA, roleB, roleC], callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
            let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
            XCTAssertEqual(belongRole["__op"] as! String, "AddRelation")
            XCTAssertNotNil(belongRole["objects"] as! [Any])
            let objects = belongRole["objects"] as! [Any]
            XCTAssertEqual(objects.count, 2)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "role")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            let object1 = objects[1] as! [String:Any]
            XCTAssertEqual(object1["__type"] as! String, "Pointer")
            XCTAssertEqual(object1["className"] as! String, "role")
            XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addRolesInBackground_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_addRolesInBackground_success")
        sut.addRolesInBackground(roles: [roleA, roleB, roleC], callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_addRolesInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_addRolesInBackground_failure")
        sut.addRolesInBackground(roles: [roleA, roleB, roleC], callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeRole_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        _ = sut.removeRole(role: roleA)

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
        let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
        XCTAssertEqual(belongRole["__op"] as! String, "RemoveRelation")
        XCTAssertNotNil(belongRole["objects"] as! [Any])
        let objects = belongRole["objects"] as! [Any]
        XCTAssertEqual(objects.count, 1)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "role")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
    }

    func test_removeRole_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        _ = sut.removeRole(role: roleA)

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
        let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
        XCTAssertEqual(belongRole["__op"] as! String, "RemoveRelation")
        XCTAssertNotNil(belongRole["objects"] as! [Any])
        let objects = belongRole["objects"] as! [Any]
        XCTAssertEqual(objects.count, 1)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "role")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
    }

    func test_removeRole_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.removeRole(role: roleA)

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
    }

    func test_removeRole_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let result : NCMBResult<Void> = sut.removeRole(role: roleA)

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_removeRoleInBackground_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeRoleInBackground_request_insert")
        sut.removeRoleInBackground(role: roleA, callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
            let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
            XCTAssertEqual(belongRole["__op"] as! String, "RemoveRelation")
            XCTAssertNotNil(belongRole["objects"] as! [Any])
            let objects = belongRole["objects"] as! [Any]
            XCTAssertEqual(objects.count, 1)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "role")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeRoleInBackground_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeRoleInBackground_request_update")
        sut.removeRoleInBackground(role: roleA, callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
            let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
            XCTAssertEqual(belongRole["__op"] as! String, "RemoveRelation")
            XCTAssertNotNil(belongRole["objects"] as! [Any])
            let objects = belongRole["objects"] as! [Any]
            XCTAssertEqual(objects.count, 1)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "role")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeRoleInBackground_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeRoleInBackground_success")
        sut.removeRoleInBackground(role: roleA, callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeRoleInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeRoleInBackground_failure")
        sut.removeRoleInBackground(role: roleA, callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeRoles_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        _ = sut.removeRoles(roles: [roleA, roleB, roleC])

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
        let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
        XCTAssertEqual(belongRole["__op"] as! String, "RemoveRelation")
        XCTAssertNotNil(belongRole["objects"] as! [Any])
        let objects = belongRole["objects"] as! [Any]
        XCTAssertEqual(objects.count, 2)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "role")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
        let object1 = objects[1] as! [String:Any]
        XCTAssertEqual(object1["__type"] as! String, "Pointer")
        XCTAssertEqual(object1["className"] as! String, "role")
        XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
    }

    func test_removeRoles_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        _ = sut.removeRoles(roles: [roleA, roleB, roleC])

        XCTAssertEqual(executor.requests.count, 1)
        XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

        let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
        XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
        let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
        XCTAssertEqual(belongRole["__op"] as! String, "RemoveRelation")
        XCTAssertNotNil(belongRole["objects"] as! [Any])
        let objects = belongRole["objects"] as! [Any]
        XCTAssertEqual(objects.count, 2)
        let object0 = objects[0] as! [String:Any]
        XCTAssertEqual(object0["__type"] as! String, "Pointer")
        XCTAssertEqual(object0["className"] as! String, "role")
        XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
        let object1 = objects[1] as! [String:Any]
        XCTAssertEqual(object1["__type"] as! String, "Pointer")
        XCTAssertEqual(object1["className"] as! String, "role")
        XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
    }

    func test_removeRoles_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let result : NCMBResult<Void> = sut.removeRoles(roles: [roleA, roleB, roleC])

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
    }

    func test_removeRoles_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let result : NCMBResult<Void> = sut.removeRoles(roles: [roleA, roleB, roleC])

        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_removeRolesInBackground_request_insert() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeRolesInBackground_request_insert")
        sut.removeRolesInBackground(roles: [roleA, roleB, roleC], callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.post)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
            let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
            XCTAssertEqual(belongRole["__op"] as! String, "RemoveRelation")
            XCTAssertNotNil(belongRole["objects"] as! [Any])
            let objects = belongRole["objects"] as! [Any]
            XCTAssertEqual(objects.count, 2)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "role")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            let object1 = objects[1] as! [String:Any]
            XCTAssertEqual(object1["__type"] as! String, "Pointer")
            XCTAssertEqual(object1["className"] as! String, "role")
            XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeRolesInBackground_request_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeRolesInBackground_request_update")
        sut.removeRolesInBackground(roles: [roleA, roleB, roleC], callback: { (result: NCMBResult<Void>) in
            XCTAssertEqual(executor.requests.count, 1)
            XCTAssertEqual(executor.requests[0].method, NCMBHTTPMethod.put)

            let requestBodyKeyValue = try! NCMBJsonConverter.convertToKeyValue(executor.requests[0].body!)
            XCTAssertNotNil(requestBodyKeyValue["belongRole"] as! [String:Any])
            let belongRole = requestBodyKeyValue["belongRole"] as! [String:Any]
            XCTAssertEqual(belongRole["__op"] as! String, "RemoveRelation")
            XCTAssertNotNil(belongRole["objects"] as! [Any])
            let objects = belongRole["objects"] as! [Any]
            XCTAssertEqual(objects.count, 2)
            let object0 = objects[0] as! [String:Any]
            XCTAssertEqual(object0["__type"] as! String, "Pointer")
            XCTAssertEqual(object0["className"] as! String, "role")
            XCTAssertEqual(object0["objectId"] as! String, "hijklmn67890")
            let object1 = objects[1] as! [String:Any]
            XCTAssertEqual(object1["__type"] as! String, "Pointer")
            XCTAssertEqual(object1["className"] as! String, "role")
            XCTAssertEqual(object1["objectId"] as! String, "opqrstu24680")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeRolesInBackground_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeRolesInBackground_success")
        sut.removeRolesInBackground(roles: [roleA, roleB, roleC], callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_removeRolesInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let roleA: NCMBRole = NCMBRole(roleName: "role a")
        roleA.objectId = "hijklmn67890"
        let roleB: NCMBRole = NCMBRole(roleName: "role b")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "role c")
        roleC.objectId = "opqrstu24680"

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        let expectation : XCTestExpectation? = self.expectation(description: "test_removeRolesInBackground_failure")
        sut.removeRolesInBackground(roles: [roleA, roleB, roleC], callback: { (result: NCMBResult<Void>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_fetch_success() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["field2"] = "value2"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "value1"

        let result : NCMBResult<Void> = sut.delete()

        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        XCTAssertNil(sut.objectId)
        XCTAssertNil(sut["field1"])
    }

    func test_delete_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

        let sut : NCMBRole = NCMBRole(roleName: "Testrole")
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

    func test_createBelongItems_add_one() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = "abcdefg12345"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let object = sut.createBelongItems(
                className: "takanokun",
                add: [roleA],
                remove: [])

        XCTAssertEqual((object as! NCMBAddRelationOperator).elements.count, 1)
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[0].className, "takanokun")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[0].objectId, "abcdefg12345")
    }

    func test_createBelongItems_add_multiple() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = "abcdefg12345"
        let roleB: NCMBRole = NCMBRole(roleName: "Testrole")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "Testrole")
        roleC.objectId = "opqrstu24680"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let object = sut.createBelongItems(
                className: "takanokun",
                add: [roleA, roleB, roleC],
                remove: [])

        XCTAssertEqual((object as! NCMBAddRelationOperator).elements.count, 2)
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[0].className, "takanokun")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[0].objectId, "abcdefg12345")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[1].className, "takanokun")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[1].objectId, "opqrstu24680")
    }

    func test_createBelongItems_remove_one() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = "abcdefg12345"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let object = sut.createBelongItems(
                className: "takanokun",
                add: [],
                remove: [roleA])

        XCTAssertEqual((object as! NCMBRemoveRelationOperator).elements.count, 1)
        XCTAssertEqual((object as! NCMBRemoveRelationOperator).elements[0].className, "takanokun")
        XCTAssertEqual((object as! NCMBRemoveRelationOperator).elements[0].objectId, "abcdefg12345")
    }

    func test_createBelongItems_remove_multiple() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = "abcdefg12345"
        let roleB: NCMBRole = NCMBRole(roleName: "Testrole")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "Testrole")
        roleC.objectId = "opqrstu24680"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let object = sut.createBelongItems(
                className: "takanokun",
                add: [],
                remove: [roleA, roleB, roleC])

        XCTAssertEqual((object as! NCMBRemoveRelationOperator).elements.count, 2)
        XCTAssertEqual((object as! NCMBRemoveRelationOperator).elements[0].className, "takanokun")
        XCTAssertEqual((object as! NCMBRemoveRelationOperator).elements[0].objectId, "abcdefg12345")
        XCTAssertEqual((object as! NCMBRemoveRelationOperator).elements[1].className, "takanokun")
        XCTAssertEqual((object as! NCMBRemoveRelationOperator).elements[1].objectId, "opqrstu24680")
    }

    func test_createBelongItems_both_empty() {
        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let object = sut.createBelongItems(
                className: "takanokun",
                add: [],
                remove: [])

        XCTAssertNil(object)
    }

    func test_createBelongItems_both_not_empty() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = "abcdefg12345"
        let roleB: NCMBRole = NCMBRole(roleName: "Testrole")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "Testrole")
        roleC.objectId = "hijklmn67890"
        let roleD: NCMBRole = NCMBRole(roleName: "Testrole")
        roleD.objectId = "opqrstu24680"
        let roleE: NCMBRole = NCMBRole(roleName: "Testrole")
        roleE.objectId = nil
        let roleF: NCMBRole = NCMBRole(roleName: "Testrole")
        roleF.objectId = "vwxyz1357913"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let object = sut.createBelongItems(
                className: "takanokun",
                add: [roleA, roleB, roleC],
                remove: [roleD, roleE, roleF])

        XCTAssertEqual((object as! NCMBAddRelationOperator).elements.count, 2)
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[0].className, "takanokun")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[0].objectId, "abcdefg12345")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[1].className, "takanokun")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[1].objectId, "hijklmn67890")
    }

    func test_createBelongItems_both_not_empty_invalidObjectId() {
        let roleB: NCMBRole = NCMBRole(roleName: "Testrole")
        roleB.objectId = nil
        let roleD: NCMBRole = NCMBRole(roleName: "Testrole")
        roleD.objectId = "opqrstu24680"
        let roleE: NCMBRole = NCMBRole(roleName: "Testrole")
        roleE.objectId = nil
        let roleF: NCMBRole = NCMBRole(roleName: "Testrole")
        roleF.objectId = "vwxyz1357913"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let object = sut.createBelongItems(
                className: "takanokun",
                add: [roleB],
                remove: [roleD, roleE, roleF])

        XCTAssertEqual((object as! NCMBAddRelationOperator).elements.count, 0)
    }

    func test_createBelongItems_role() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = "abcdefg12345"
        let roleB: NCMBRole = NCMBRole(roleName: "Testrole")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "Testrole")
        roleC.objectId = "opqrstu24680"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let object = sut.createBelongItems(
                className: "role",
                add: [roleA, roleB, roleC],
                remove: [])

        XCTAssertEqual((object as! NCMBAddRelationOperator).elements.count, 2)
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[0].className, "role")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[0].objectId, "abcdefg12345")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[1].className, "role")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[1].objectId, "opqrstu24680")
    }

    func test_createBelongItems_user() {
        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "abcdefg12345"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let object = sut.createBelongItems(
                className: "user",
                add: [userA, userB, userC],
                remove: [])

        XCTAssertEqual((object as! NCMBAddRelationOperator).elements.count, 2)
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[0].className, "user")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[0].objectId, "abcdefg12345")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[1].className, "user")
        XCTAssertEqual((object as! NCMBAddRelationOperator).elements[1].objectId, "opqrstu24680")
    }

    func test_getPointers_className() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = "abcdefg12345"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let elements = sut.getPointers(className: "takanokun", objects: [roleA])

        XCTAssertEqual(elements[0].className, "takanokun")
    }

    func test_getPointers_objectId() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = "abcdefg12345"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let elements = sut.getPointers(className: "role", objects: [roleA])

        XCTAssertEqual(elements[0].objectId, "abcdefg12345")
    }

    func test_getPointers_nil_objectId() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = nil

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let elements = sut.getPointers(className: "role", objects: [roleA])

        XCTAssertEqual(elements.count, 0)
    }

    func test_getPointers_no_element() {
        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let elements = sut.getPointers(className: "role", objects: [])

        XCTAssertEqual(elements.count, 0)
    }

    func test_getPointers_one_element() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = "abcdefg12345"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let elements = sut.getPointers(className: "role", objects: [roleA])

        XCTAssertEqual(elements.count, 1)
        XCTAssertEqual(elements[0].className, "role")
        XCTAssertEqual(elements[0].objectId, "abcdefg12345")
    }

    func test_getPointers_multiple_elements() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = "abcdefg12345"
        let roleB: NCMBRole = NCMBRole(roleName: "Testrole")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "Testrole")
        roleC.objectId = "opqrstu24680"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let elements = sut.getPointers(className: "role", objects: [roleA, roleB, roleC])

        XCTAssertEqual(elements.count, 2)
        XCTAssertEqual(elements[0].className, "role")
        XCTAssertEqual(elements[0].objectId, "abcdefg12345")
        XCTAssertEqual(elements[1].className, "role")
        XCTAssertEqual(elements[1].objectId, "opqrstu24680")
    }

    func test_getPointers_role() {
        let roleA: NCMBRole = NCMBRole(roleName: "Testrole")
        roleA.objectId = "abcdefg12345"
        let roleB: NCMBRole = NCMBRole(roleName: "Testrole")
        roleB.objectId = nil
        let roleC: NCMBRole = NCMBRole(roleName: "Testrole")
        roleC.objectId = "opqrstu24680"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let elements = sut.getPointers(className: "role", objects: [roleA, roleB, roleC])

        XCTAssertEqual(elements.count, 2)
        XCTAssertEqual(elements[0].className, "role")
        XCTAssertEqual(elements[0].objectId, "abcdefg12345")
        XCTAssertEqual(elements[1].className, "role")
        XCTAssertEqual(elements[1].objectId, "opqrstu24680")
    }

    func test_getPointers_user() {
        let userA: NCMBUser = NCMBUser()
        userA.userName = "user a"
        userA.objectId = "abcdefg12345"
        let userB: NCMBUser = NCMBUser()
        userB.userName = "user b"
        userB.objectId = nil
        let userC: NCMBUser = NCMBUser()
        userC.userName = "user c"
        userC.objectId = "opqrstu24680"

        let sut: NCMBRole = NCMBRole(roleName: "SUT")
        let elements = sut.getPointers(className: "user", objects: [userA, userB, userC])

        XCTAssertEqual(elements.count, 2)
        XCTAssertEqual(elements[0].className, "user")
        XCTAssertEqual(elements[0].objectId, "abcdefg12345")
        XCTAssertEqual(elements[1].className, "user")
        XCTAssertEqual(elements[1].objectId, "opqrstu24680")
    }

    static var allTests = [
        ("test_isIgnoredKey", test_isIgnoredKey),
        ("test_isIgnoredKey_setFieldValue", test_isIgnoredKey_setFieldValue),
        ("test_roleName", test_roleName),
        ("test_query", test_query),
        ("test_init", test_init),


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
        ("test_createBelongItems_add_one", test_createBelongItems_add_one),
        ("test_createBelongItems_add_multiple", test_createBelongItems_add_multiple),
        ("test_createBelongItems_remove_one", test_createBelongItems_remove_one),
        ("test_createBelongItems_remove_multiple", test_createBelongItems_remove_multiple),
        ("test_createBelongItems_both_empty", test_createBelongItems_both_empty),
        ("test_createBelongItems_both_not_empty", test_createBelongItems_both_not_empty),
        ("test_createBelongItems_role", test_createBelongItems_role),
        ("test_createBelongItems_user", test_createBelongItems_user),
        ("test_getPointers_className", test_getPointers_className),
        ("test_getPointers_objectId", test_getPointers_objectId),
        ("test_getPointers_nil_objectId", test_getPointers_nil_objectId),
        ("test_getPointers_no_element", test_getPointers_no_element),
        ("test_getPointers_one_element", test_getPointers_one_element),
        ("test_getPointers_multiple_elements", test_getPointers_multiple_elements),
        ("test_getPointers_role", test_getPointers_role),
        ("test_getPointers_user", test_getPointers_user),
    ]
}
