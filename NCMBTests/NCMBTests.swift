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

/// NCMB のテストクラスです。
final class NCMBTests: NCMBTestCase {

    // プロパティのテスト
    func test_properties() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "https://piyo.example.com/",
            apiVersion : "1986-02-04")

        XCTAssertEqual(NCMB.applicationKey, "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
        XCTAssertEqual(NCMB.clientKey, "1111111111111111111111111111111111111111111111111111111111111111")
        XCTAssertEqual(NCMB.domainURL, "https://piyo.example.com/")
        XCTAssertEqual(NCMB.apiVersion, "1986-02-04")
    }

    // プロパティ既定値のテスト
    func test_defaultProperties() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111")

        XCTAssertEqual(NCMB.domainURL, "https://mbaas.api.nifcloud.com/")
        XCTAssertEqual(NCMB.apiVersion, "2013-09-01")
    }

    static var allTests = [
        ("test_properties", test_properties),
        ("test_defaultProperties", test_defaultProperties),
    ]
}
