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

import Foundation
import XCTest
@testable import NCMB

/// NCMBFacebookParameters のテストクラスです。
final class NCMBFacebookParametersTests: NCMBTestCase {

    func test_type() {
        let expirationDate : Date = NCMBDateFormatter.getDateFromISO8601Timestamp(from: "1986-02-04T12:34:56.789Z")!
        let sut = NCMBFacebookParameters(id: "abcdef123456", accessToken: "ghijklm789012", expirationDate: expirationDate)
        XCTAssertEqual(sut.type, NCMBSNSType.facebook)
    }

    func test_toObject() {
        let expirationDate : Date = NCMBDateFormatter.getDateFromISO8601Timestamp(from: "1986-02-04T12:34:56.789Z")!
        let sut = NCMBFacebookParameters(id: "abcdef123456", accessToken: "ghijklm789012", expirationDate: expirationDate)
        let object : [String : Any] = sut.toObject()
        XCTAssertEqual(object.count, 3)
        XCTAssertEqual(object["id"]! as! String, "abcdef123456")
        XCTAssertEqual(object["access_token"]! as! String, "ghijklm789012")
        let expiration_date = object["expiration_date"] as! [String : Any]
        XCTAssertEqual(expiration_date["__type"]! as! String, "Date")
        XCTAssertEqual(expiration_date["iso"]! as! String, "1986-02-04T12:34:56.789Z")
    }

    static var allTests = [
        ("test_type", test_type),
        ("test_toObject", test_toObject),
    ]
}
