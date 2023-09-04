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

/// NCMBDateFormatter のテストクラスです。
final class NCMBDateFormatterTests: NCMBTestCase {

    func test_getISO8601Timestamp_0sec() {
        let originDate = Date(timeIntervalSince1970: 0)
        XCTAssertEqual(NCMBDateFormatter.getISO8601Timestamp(date: originDate), "1970-01-01T00:00:00.000Z")
    }

    func test_getISO8601Timestamp_507904496789msec() {
        let testDate = Date(timeIntervalSince1970: 507904496.789)
        XCTAssertEqual(NCMBDateFormatter.getISO8601Timestamp(date: testDate), "1986-02-04T12:34:56.789Z")
    }

    func test_getDateFromISO8601Timestamp_0sec() {
        let date : Date? = NCMBDateFormatter.getDateFromISO8601Timestamp(from: "1970-01-01T00:00:00.000Z")
        XCTAssertEqual(date!.timeIntervalSince1970, 0)
    }

    func test_getDateFromISO8601Timestamp_507904496789msec() {
        let date : Date? = NCMBDateFormatter.getDateFromISO8601Timestamp(from: "1986-02-04T12:34:56.789Z")
        XCTAssertEqual(date!.timeIntervalSince1970, 507904496.789)
    }

    func test_getFileNameTimestamp_0sec() {
        let originDate = Date(timeIntervalSince1970: 0)
        XCTAssertEqual(NCMBDateFormatter.getFileNameTimestamp(date: originDate), "19700101000000000")
    }

    func test_getFileNameTimestamp_507904496789msec() {
        let testDate = Date(timeIntervalSince1970: 507904496.789)
        XCTAssertEqual(NCMBDateFormatter.getFileNameTimestamp(date: testDate), "19860204123456789")
    }

    static var allTests = [
        ("test_getISO8601Timestamp_0sec", test_getISO8601Timestamp_0sec),
        ("test_getISO8601Timestamp_507904496789msec", test_getISO8601Timestamp_507904496789msec),
        ("test_getDateFromISO8601Timestamp_0sec", test_getDateFromISO8601Timestamp_0sec),
        ("test_getDateFromISO8601Timestamp_507904496789msec", test_getDateFromISO8601Timestamp_507904496789msec),
        ("test_getFileNameTimestamp_0sec", test_getFileNameTimestamp_0sec),
        ("test_getFileNameTimestamp_507904496789msec", test_getFileNameTimestamp_507904496789msec),
    ]
}
