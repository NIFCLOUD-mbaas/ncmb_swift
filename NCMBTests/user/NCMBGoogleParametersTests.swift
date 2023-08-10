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

/// NCMBGoogleParameters のテストクラスです。
final class NCMBGoogleParametersTests: NCMBTestCase {

    func test_type() {
        let sut = NCMBGoogleParameters(id: "abcdef123456", accessToken: "ghijklm789012")
        XCTAssertEqual(sut.type, NCMBSNSType.google)
    }

    func test_toObject() {
        let sut = NCMBGoogleParameters(id: "abcdef123456", accessToken: "ghijklm789012")
        let object : [String : Any] = sut.toObject()
        XCTAssertEqual(object.count, 2)
        XCTAssertEqual(object["id"]! as! String, "abcdef123456")
        XCTAssertEqual(object["access_token"]! as! String, "ghijklm789012")
    }

    static var allTests = [
        ("test_type", test_type),
        ("test_toObject", test_toObject),
    ]
}
