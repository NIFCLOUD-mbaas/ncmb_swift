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

/// 日時文字列の変換を行うクラスです。
class NCMBDateFormatter {

    /// 日時をISO8601型の文字列に変換します。
    ///
    /// - Parameter date: 変換対象日時
    public class func getISO8601Timestamp(date: Date) -> String {
        return NCMBISO8601DateFormatter.getTimestamp(date: date)
    }

    /// ISO8601型文字列から日時に変換します。
    ///
    /// - Parameter from: 変換対象文字列
    public class func getDateFromISO8601Timestamp(from: String) -> Date? {
        return NCMBISO8601DateFormatter.getDate(from: from)
    }

    /// 日時をファイル名用文字列に変換します。
    ///
    /// - Parameter date: 変換対象日時
    public class func getFileNameTimestamp(date: Date) -> String {
        return NCMBFileNameDateFormatter.getTimestamp(date: date)
    }

}

class NCMBFileNameDateFormatter {
    private let formatter : DateFormatter
    private static let shared : NCMBFileNameDateFormatter = NCMBFileNameDateFormatter()

    private init() {
        let formatter : DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMddHHmmssSSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.formatter = formatter
    }

    class func getTimestamp(date: Date) -> String {
        return shared.formatter.string(from: date)
    }

}

class NCMBISO8601DateFormatter {
    private let formatter : DateFormatter
    private static let shared : NCMBISO8601DateFormatter = NCMBISO8601DateFormatter()

    private init() {
        let formatter : DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.formatter = formatter
    }

    class func getTimestamp(date: Date) -> String {
        return shared.formatter.string(from: date)
    }

    class func getDate(from: String) -> Date? {
        return shared.formatter.date(from: from)

    }
}
