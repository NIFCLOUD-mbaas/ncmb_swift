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

/// NCMBDeviceSystem のテストクラスです。
final class NCMBDeviceSystemTests: NCMBTestCase {

#if os(OSX)
    func test_osType() {
        XCTAssertEqual(NCMBDeviceSystem.osType, "osx")
    }

    func test_osVersion() {
        let regex = try! NSRegularExpression(pattern: "osx-\\d+\\.\\d+\\.\\d+", options: [])
        let sut : String = NCMBDeviceSystem.osVersion
        XCTAssertEqual(regex.matches(in: sut, range: NSMakeRange(0, sut.count)).count, 1)
    }
#elseif os(iOS)
    func test_osType() {
        XCTAssertEqual(NCMBDeviceSystem.osType, "ios")
    }

    func test_osVersion() {
        let regex = try! NSRegularExpression(pattern: "ios-\\d+(\\.\\d+){1,2}", options: [])
        let sut : String = NCMBDeviceSystem.osVersion
        XCTAssertEqual(regex.matches(in: sut, range: NSMakeRange(0, sut.count)).count, 1)
    }
#elseif os(Linux)
    func test_osType() {
        XCTAssertEqual(NCMBDeviceSystem.osType, "linux")
    }

    func test_osVersion() {
        XCTAssertEqual(NCMBDeviceSystem.osVersion, "linux-")
    }
#endif

    static var allTests = [
        ("test_osType", test_osType),
        ("test_osVersion", test_osVersion),
    ]
}
