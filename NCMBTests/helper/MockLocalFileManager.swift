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

/// テストコード内で使用するファイルマネージャークラスのモックです。
public class MockLocalFileManager : NCMBLocalFileManagerProtocol {

    /// ファイル読込のログです。読込ファイルの種類を格納します。
    public var loadLog : [NCMBLocalFileType] = []

    /// ファイル保存のログです。保存データとファイルの種類を格納します。
    public var saveLog : [(data: Data, type: NCMBLocalFileType)] = []

    /// ファイル削除のログです。削除ファイルの種類を格納します。
    public var deleteLog : [NCMBLocalFileType] = []

    /// ファイル読込時に返されるデータです。
    public var loadResponse : Data?

    /// イニシャライズです。
    ///
    /// - Parameter loadResponse: ファイル読込時に返されるデータ
    public init(loadResponse: Data?){
        self.loadResponse = loadResponse
    }

    /// 指定された対象ファイルを読み込みます。
    ///
    /// - Parameter target: 読込ファイルの種類
    /// - Returns: 返されるデータ（ `loadResponse` に登録した内容）    
    public func loadFromFile(target: NCMBLocalFileType) -> Data? {
        self.loadLog.append(target)
        return self.loadResponse
    }

    /// データを指定された対象ファイルに保存します。
    ///
    /// - Parameter data: 保存データ
    /// - Parameter target: 保存ファイルの種類
    public func saveToFile(data: Data, target: NCMBLocalFileType) -> Void {
        self.saveLog.append((data: data, type: target))
    }

    /// 指定された対象ファイルを削除します。
    ///
    /// - Parameter target: 削除ファイルの種類
    public func deleteFile(target: NCMBLocalFileType) -> Void {
        self.deleteLog.append(target)
    }
}
