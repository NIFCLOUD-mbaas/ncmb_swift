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

/// NCMBTestUtil のテストクラスです。
final class NCMBTestUtilTests: NCMBTestCase {

    func test_checkResultIsSuccess_NCMBResult_success() {
        let result : NCMBResult<String> = .success("a")
        XCTAssertEqual(NCMBTestUtil.checkResultIsSuccess(result: result), true)
    }

    func test_checkResultIsSuccess_NCMBResult_failure() {
        let result : NCMBResult<String> = .failure(DummyErrors.dummyError)
        XCTAssertEqual(NCMBTestUtil.checkResultIsSuccess(result: result), false)
    }

    func test_checkResultIsFailure_NCMBResult_success() {
        let result : NCMBResult<String> = .success("a")
        XCTAssertEqual(NCMBTestUtil.checkResultIsFailure(result: result), false)
    }

    func test_checkResultIsFailure_NCMBResult_failure() {
        let result : NCMBResult<String> = .failure(DummyErrors.dummyError)
        XCTAssertEqual(NCMBTestUtil.checkResultIsFailure(result: result), true)
    }

    func test_getResponse_NCMBResult_success() {
        let result : NCMBResult<String> = .success("a")
        XCTAssertEqual(NCMBTestUtil.getResponse(result: result), "a")
    }

    func test_getResponse_NCMBResult_failure() {
        let result : NCMBResult<String> = .failure(DummyErrors.dummyError)
        XCTAssertNil(NCMBTestUtil.getResponse(result: result))
    }

    func test_getError_NCMBResult_success() {
        let result : NCMBResult<String> = .success("a")
        XCTAssertNil(NCMBTestUtil.getError(result: result))
    }

    func test_getError_NCMBResult_failure() {
        let result : NCMBResult<String> = .failure(DummyErrors.dummyError)
        XCTAssertEqual(NCMBTestUtil.getError(result: result) as! DummyErrors, DummyErrors.dummyError)
    }

    static var allTests = [
        ("test_checkResultIsSuccess_NCMBResult_success", test_checkResultIsSuccess_NCMBResult_success),
        ("test_checkResultIsSuccess_NCMBResult_failure", test_checkResultIsSuccess_NCMBResult_failure),
        ("test_checkResultIsFailure_NCMBResult_success", test_checkResultIsFailure_NCMBResult_success),
        ("test_checkResultIsFailure_NCMBResult_failure", test_checkResultIsFailure_NCMBResult_failure),
        ("test_getResponse_NCMBResult_success", test_getResponse_NCMBResult_success),
        ("test_getResponse_NCMBResult_failure", test_getResponse_NCMBResult_failure),
        ("test_getError_NCMBResult_success", test_getError_NCMBResult_success),
        ("test_getError_NCMBResult_failure", test_getError_NCMBResult_failure),
    ]
}
