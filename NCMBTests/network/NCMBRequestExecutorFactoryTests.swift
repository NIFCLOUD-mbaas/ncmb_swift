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

/// NCMBRequestExecutorFactory のテストクラスです。
final class NCMBRequestExecutorFactoryTests: NCMBTestCase {

    func test_getInstance() {
        NCMBRequestExecutorFactory.setInstance(executor: DummyRequestExecutor())
        let dummy_executor : NCMBRequestExecutorProtocol = NCMBRequestExecutorFactory.getInstance()
        XCTAssertNotNil(dummy_executor as? DummyRequestExecutor)
    }

    static var allTests = [
        ("test_getInstance", test_getInstance),
    ]

    private class DummyRequestExecutor : NCMBRequestExecutorProtocol {

        required init() {
        }

        func exec(request: NCMBRequest, callback: @escaping (NCMBResult<NCMBResponse>) -> Void) -> Void {
        }

    }
}

