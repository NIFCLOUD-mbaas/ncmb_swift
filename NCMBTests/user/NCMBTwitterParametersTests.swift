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

/// NCMBTwitterParameters のテストクラスです。
final class NCMBTwitterParametersTests: NCMBTestCase {

    func test_type() {
        let sut = NCMBTwitterParameters(
            id: "abcdef123456",
            screenName: "takanokun",
            oauthConsumerKey: "ghijklm789012",
            consumerSecret: "nopqrs345678",
            oauthToken: "tuvwx9012345",
            oauthTokenSecret: "yzab987654")
        XCTAssertEqual(sut.type, NCMBSNSType.twitter)
    }

    func test_toObject() {
        let sut = NCMBTwitterParameters(
            id: "abcdef123456",
            screenName: "takanokun",
            oauthConsumerKey: "ghijklm789012",
            consumerSecret: "nopqrs345678",
            oauthToken: "tuvwx9012345",
            oauthTokenSecret: "yzab987654")
        let object : [String : Any] = sut.toObject()
        XCTAssertEqual(object.count, 6)
        XCTAssertEqual(object["id"]! as! String, "abcdef123456")
        XCTAssertEqual(object["screen_name"]! as! String, "takanokun")
        XCTAssertEqual(object["oauth_consumer_key"]! as! String, "ghijklm789012")
        XCTAssertEqual(object["consumer_secret"]! as! String, "nopqrs345678")
        XCTAssertEqual(object["oauth_token"]! as! String, "tuvwx9012345")
        XCTAssertEqual(object["oauth_token_secret"]! as! String, "yzab987654")
    }

    static var allTests = [
        ("test_type", test_type),
        ("test_toObject", test_toObject),
    ]
}
