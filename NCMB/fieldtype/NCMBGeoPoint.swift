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

/// 地理座標型のフィールドを操作するための構造体です。
public struct NCMBGeoPoint {
    static let TYPENAME : String = "GeoPoint"
    static let LATITUDE_FIELD_NAME : String = "latitude"
    static let LONGITUDE_FIELD_NAME : String = "longitude"

    /// 緯度です。
    public var latitude : Double

    /// 経度です。
    public var longitude : Double

    /// イニシャライズです。
    ///
    /// - Parameter latitude: 緯度
    /// - Parameter longitude: 経度
    public init(latitude: Double = 0.0, longitude: Double = 0.0) {
        self.latitude = latitude
        self.longitude = longitude
    }

    static func createInstance(object: Any) -> NCMBGeoPoint? {
        if let object = object as? [String : Any] {
            if checkTypeIsGeoPoint(object: object) {
                if let latitude = getLatitude(object: object) {
                    if let longitude = getLongitude(object: object) {
                        return NCMBGeoPoint(latitude: latitude, longitude: longitude)
                    }
                }
            }
        }
        return nil
    }

    private static func checkTypeIsGeoPoint(object: [String : Any]) -> Bool {
        return NCMBFieldTypeUtil.checkTypeField(object: object, typename: TYPENAME)
    }

    private static func getLatitude(object: [String : Any]) -> Double? {
        return NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: NCMBGeoPoint.LATITUDE_FIELD_NAME)
    }

    private static func getLongitude(object: [String : Any]) -> Double? {
        return NCMBFieldTypeUtil.getFieldValue(object: object, fieldname: NCMBGeoPoint.LONGITUDE_FIELD_NAME)
    }

    func toObject() -> [String : Any] {
        var object : [String : Any] = NCMBFieldTypeUtil.createTypeObjectBase(typename: NCMBGeoPoint.TYPENAME)
        object[NCMBGeoPoint.LATITUDE_FIELD_NAME] = self.latitude
        object[NCMBGeoPoint.LONGITUDE_FIELD_NAME] = self.longitude
        return object
    }
}