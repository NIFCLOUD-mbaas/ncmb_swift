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

/// NCMBExpirationTime のテストクラスです。
final class NCMBExpirationTimeTests: NCMBTestCase {
    
    func test_init() {
        let sut: NCMBExpirationTime = NCMBExpirationTime(volume: 3, unitType: .hour)
        XCTAssertEqual(sut.volume, 3)
        XCTAssertEqual(sut.unitType.rawValue, "hour")
    }
    
    func test_init_day() {
        let sut: NCMBExpirationTime? = NCMBExpirationTime(string: "4 day")
        XCTAssertEqual(sut!.volume, 4)
        XCTAssertEqual(sut!.unitType.rawValue, "day")
    }
    
    func test_init_hour() {
        let sut: NCMBExpirationTime? = NCMBExpirationTime(string: "10 hour")
        XCTAssertEqual(sut!.volume, 10)
        XCTAssertEqual(sut!.unitType.rawValue, "hour")
    }
    
    func test_init_invalid() {
        let sut1: NCMBExpirationTime? = NCMBExpirationTime(string: "5hour")
        XCTAssertNil(sut1)
        let sut2: NCMBExpirationTime? = NCMBExpirationTime(string: "5 hour hour")
        XCTAssertNil(sut2)
    }
    
    func test_init_invalid_number() {
        let sut: NCMBExpirationTime? = NCMBExpirationTime(string: "a day")
        XCTAssertNil(sut)
    }
    
    func test_init_invalid_unitType() {
        let sut: NCMBExpirationTime? = NCMBExpirationTime(string: "2 month")
        XCTAssertNil(sut)
    }
    
    func test_equal() {
        let a: NCMBExpirationTime = NCMBExpirationTime(volume: 3, unitType: .hour)
        let b: NCMBExpirationTime = NCMBExpirationTime(volume: 3, unitType: .hour)
        let c: NCMBExpirationTime = NCMBExpirationTime(volume: 3, unitType: .day)
        let d: NCMBExpirationTime = NCMBExpirationTime(volume: 10, unitType: .hour)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(a, d)
    }
    
    func test_getString_hour() {
        let sut: NCMBExpirationTime = NCMBExpirationTime(volume: 3, unitType: .hour)
        XCTAssertEqual(sut.getString(), "3 hour")
    }
    
    func test_getString_day() {
        let sut: NCMBExpirationTime = NCMBExpirationTime(volume: 15, unitType: .day)
        XCTAssertEqual(sut.getString(), "15 day")
    }
    
    static var allTests = [
        ("test_init", test_init),
        ("test_init_day", test_init_day),
        ("test_init_hour", test_init_hour),
        ("test_init_invalid", test_init_invalid),
        ("test_init_invalid_number", test_init_invalid_number),
        ("test_init_invalid_unitType", test_init_invalid_unitType),
        ("test_equal", test_equal),
        ("test_getString_hour", test_getString_hour),
        ("test_getString_day", test_getString_day),
    ]
}
