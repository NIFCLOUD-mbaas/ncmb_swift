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

//import Foundation

/// プッシュ通知 配信期限時間を表すための構造体です。
public struct NCMBExpirationTime: Equatable {
    
    /// 時間／日数の数値です
    public var volume: Int

    /// 時間／日数の単位です
    public var unitType: NCMBExpirationTimeUnitType

    /// イニシャライズです。
    /// 
    /// - Parameter volume: 時間／日数の数値
    /// - Parameter unitType: 時間／日数の単位です。 `.hour` または `.day` を指定します。
    public init(volume: Int, unitType: NCMBExpirationTimeUnitType) {
        self.volume = volume
        self.unitType = unitType
    }
    
    /// イニシャライズです。
    /// 引数が不正な場合は、オブジェクトが生成されず `nil` が返されます。
    /// 
    /// - Parameter string: 配信期限時間を表す文字列。 `NN hour` または `NN day` を指定します（ `NN` は整数値）。
    init?(string: String) {
        let array: [String] = string.components(separatedBy: " ");
        if (array.count != 2) {
            return nil
        }
        if let volume: Int = Int(array[0]) {
            if let unitType: NCMBExpirationTimeUnitType
                = NCMBExpirationTimeUnitType(string: array[1]) {
                self.volume = volume
                self.unitType = unitType
                return
            }
        }
        return nil
    }

    /// 同値であるかの判定をします。
    /// 同値である場合は `true` 、 同値でない場合は `false` を返します。
    /// 
    /// - Parameter lhs: 左辺の値
    /// - Parameter rhs: 右辺の値
    static public func ==(lhs: NCMBExpirationTime, rhs: NCMBExpirationTime) -> Bool{
        return ((lhs.volume == rhs.volume) && (lhs.unitType == rhs.unitType))
    }
    
    func getString() -> String {
        return "\(volume) \(unitType.rawValue)"
    }
}

