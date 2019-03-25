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

/// NCMBSignatureCalculator のテストクラスです。
final class NCMBSignatureCalculatorTests: NCMBTestCase {

    func test_calculate_success() {
        NCMB.initialize(
            applicationKey:"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56",
            clientKey:"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75")
        let method : NCMBHTTPMethod = .get
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let date : Date = dateFormatter.date(from: "2013-12-02T02:44:35.452Z")!
        let url : URL = URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/TestClass?where=%7B%22testKey%22%3A%22testValue%22%7D")!
        XCTAssertEqual(try! NCMBSignatureCalculator.calculate(method: method, date: date, url: url), "AltGkQgXurEV7u0qMd+87ud7BKuueldoCjaMgVc9Bes=")

    }

    func test_calculate_invalidDomainName() {
        NCMB.initialize(
            applicationKey:"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56",
            clientKey:"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75")
        let method : NCMBHTTPMethod = .get
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let date : Date = dateFormatter.date(from: "2013-12-02T02:44:35.452Z")!
        let url : URL = URL(string: "https://")!
        XCTAssertThrowsError(try NCMBSignatureCalculator.calculate(method: method, date: date, url: url)) { error in
            XCTAssertEqual(error as! NCMBInvalidRequestError, NCMBInvalidRequestError.invalidDomainName)
        }
    }

    func test_calculate_emptyApplicationKey() {
        NCMB.initialize(
            applicationKey:"",
            clientKey:"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75")
        let method : NCMBHTTPMethod = .get
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let date : Date = dateFormatter.date(from: "2013-12-02T02:44:35.452Z")!
        let url : URL = URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/TestClass?where=%7B%22testKey%22%3A%22testValue%22%7D")!
        XCTAssertThrowsError(try NCMBSignatureCalculator.calculate(method: method, date: date, url: url)) { error in
            XCTAssertEqual(error as! NCMBInvalidRequestError, NCMBInvalidRequestError.emptyApplicationKey)
        }
    }

    func test_calculate_emptyClientKey() {
        NCMB.initialize(
            applicationKey:"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56",
            clientKey:"")
        let method : NCMBHTTPMethod = .get
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let date : Date = dateFormatter.date(from: "2013-12-02T02:44:35.452Z")!
        let url : URL = URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/TestClass?where=%7B%22testKey%22%3A%22testValue%22%7D")!
        XCTAssertThrowsError(try NCMBSignatureCalculator.calculate(method: method, date: date, url: url)) { error in
            XCTAssertEqual(error as! NCMBInvalidRequestError, NCMBInvalidRequestError.emptyClientKey)
        }
    }

    // 平文からのシグニチャ生成
    func test_calculateSignature() {
        let plaintext : String = """
            GET
            mbaas.api.nifcloud.com
            /2013-09-01/classes/TestClass
            SignatureMethod=HmacSHA256&SignatureVersion=2&X-NCMB-Application-Key=6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56&X-NCMB-Timestamp=2013-12-02T02:44:35.452Z&where=%7B%22testKey%22%3A%22testValue%22%7D
            """
        let clientKey : String = "1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75"
        let sign = try! NCMBSignatureCalculator.calculateSignature(plaintext: plaintext, clientKey: clientKey)
        XCTAssertEqual(sign, "AltGkQgXurEV7u0qMd+87ud7BKuueldoCjaMgVc9Bes=")
    }

    static var allTests = [
        ("test_calculate_success", test_calculate_success),
        ("test_calculate_invalidDomainName", test_calculate_invalidDomainName),
        ("test_calculate_emptyApplicationKey", test_calculate_emptyApplicationKey),
        ("test_calculate_emptyClientKey", test_calculate_emptyClientKey),
        ("test_calculateSignature", test_calculateSignature),
    ]

}
