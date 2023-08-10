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

/// NCMBAnonymousUtils のテストクラスです。
final class NCMBAnonymousUtilsTests: NCMBTestCase {

    func test_login_success() {
        let body : Data? = "{\"createDate\":\"2013-08-16T11:49:44.991Z\",\"objectId\":\"aTAe6VXd3ZElDtlG\",\"userName\":\"ljmuJgf4ri\",\"authData\":{\"anonymous\":{\"id\":\"3dc72085-911b-4798-9707-d69e879a6185\"}},\"sessionToken\":\"esMM7OVu4PlK5spYNLLrR15io\"}".data(using: .utf8)!
        let response : NCMBResponse = MockResponseBuilder.createResponse(body: body, statusCode : 201)
        let executor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let expectation : XCTestExpectation? = self.expectation(description: "test_login_success")
        NCMBAnonymousUtils.login(callback: { (result: NCMBResult<NCMBUser>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let user : NCMBUser = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(user.objectId, "aTAe6VXd3ZElDtlG")
            XCTAssertEqual(user.userName, "ljmuJgf4ri")
            XCTAssertEqual(user["createDate"], "2013-08-16T11:49:44.991Z")
            XCTAssertEqual(user.sessionToken, "esMM7OVu4PlK5spYNLLrR15io")
            let currentUser = NCMBUser.currentUser
            XCTAssertEqual(currentUser!.objectId, "aTAe6VXd3ZElDtlG")
            XCTAssertEqual(currentUser!.userName, "ljmuJgf4ri")
            XCTAssertEqual(currentUser!["createDate"], "2013-08-16T11:49:44.991Z")
            XCTAssertEqual(currentUser!.sessionToken, "esMM7OVu4PlK5spYNLLrR15io")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_login_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let expectation : XCTestExpectation? = self.expectation(description: "test_login_failure")
        NCMBAnonymousUtils.login(callback: { (result: NCMBResult<NCMBUser>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            XCTAssertNil(NCMBUser.currentUser)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }


    func test_isLinked() {
        let user1 : NCMBUser = NCMBUser()
        user1.removeField(field: "authData")
        user1.password = nil
        XCTAssertFalse(NCMBAnonymousUtils.isLinked(user: user1))

        let user2 : NCMBUser = NCMBUser()
        let authData2 : [String : Any] = ["takanokun" : 42]
        user2["authData"] = authData2
        user2.password = nil
        XCTAssertFalse(NCMBAnonymousUtils.isLinked(user: user2))

        let user3 : NCMBUser = NCMBUser()
        let authData3 : [String : Any] = ["anonymous" : 42]
        user3["authData"] = authData3
        user3.password = "piyopiyo"
        XCTAssertFalse(NCMBAnonymousUtils.isLinked(user: user3))

        let user4 : NCMBUser = NCMBUser()
        let authData4 : [String : Any] = ["anonymous" : 42]
        user4["authData"] = authData4
        user4.password = nil
        XCTAssertTrue(NCMBAnonymousUtils.isLinked(user: user4))
    }

    func test_createAnonymousUser() {
        let user : NCMBUser = NCMBAnonymousUtils.createAnonymousUser()
        XCTAssertEqual(user.authData!.count, 1)
        XCTAssertNotNil(user.authData!["anonymous"])
        let object = user.authData!["anonymous"] as! [String : Any]
        XCTAssertNotNil(object["id"])
    }

    func test_createUUID() {
        let id1 : String = NCMBAnonymousUtils.createUUID()
        let id2 : String = NCMBAnonymousUtils.createUUID()
        XCTAssertNotEqual(id1, id2)
    }

    static var allTests = [
        ("test_login_success", test_login_success),
        ("test_login_failure", test_login_failure),
        ("test_isLinked", test_isLinked),
        ("test_createAnonymousUser", test_createAnonymousUser),
        ("test_createUUID", test_createUUID),
    ]
}
