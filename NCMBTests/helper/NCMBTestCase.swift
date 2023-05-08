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

import Foundation
import XCTest
@testable import NCMB

open class NCMBTestCase: XCTestCase {

    open override func setUp() {
        super.setUp()
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111")
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: [:], statusCode : 201)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))
        NCMBLocalFileManagerFactory.setDummy()
        _ = NCMBUser.logOut()
    }

    open override func tearDown() {
        super.tearDown()
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111")
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: [:], statusCode : 201)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(response)))
        NCMBLocalFileManagerFactory.setDummy()
        _ = NCMBUser.logOut()
    }
}