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

/// NCMBGeoPoint のテストクラスです。
final class NCMBGeoPointTests: NCMBTestCase {

    func test_createInstance_success() {
        var object : [String : Any] = [:]
        object["__type"] = "GeoPoint"
        object["latitude"] = Double(35.6666269)
        object["longitude"] = Double(139.765607)
        let geoPoint : NCMBGeoPoint? = NCMBGeoPoint.createInstance(object: object)
        XCTAssertEqual(geoPoint!.latitude, 35.6666269)
        XCTAssertEqual(geoPoint!.longitude, 139.765607)
    }

    func test_createInstance_notDictionary() {
        let geoPoint : NCMBGeoPoint?
            = NCMBGeoPoint.createInstance(object: "{\"__type\":\"GeoPoint\",\"longitude\":35.6666269,\"latitude\":139.765607}")
        XCTAssertNil(geoPoint)
    }

    func test_createInstance_lackingTypeField() {
        var object : [String : Any] = [:]
        object["latitude"] = Double(35.6666269)
        object["longitude"] = Double(139.765607)
        let geoPoint : NCMBGeoPoint? = NCMBGeoPoint.createInstance(object: object)
        XCTAssertNil(geoPoint)
    }

    func test_createInstance_TypeFieldIsNotGeoPoint() {
        var object : [String : Any] = [:]
        object["__type"] = "Date"
        object["latitude"] = Double(35.6666269)
        object["longitude"] = Double(139.765607)
        let geoPoint : NCMBGeoPoint? = NCMBGeoPoint.createInstance(object: object)
        XCTAssertNil(geoPoint)
    }

    func test_createInstance_lackingLatitudeField() {
        var object : [String : Any] = [:]
        object["__type"] = "GeoPoint"
        object["longitude"] = Double(139.765607)
        let geoPoint : NCMBGeoPoint? = NCMBGeoPoint.createInstance(object: object)
        XCTAssertNil(geoPoint)
    }

    func test_createInstance_latitudeFieldIsNotDouble() {
        var object : [String : Any] = [:]
        object["__type"] = "GeoPoint"
        object["latitude"] = "35.6666269"
        object["longitude"] = Double(139.765607)
        let geoPoint : NCMBGeoPoint? = NCMBGeoPoint.createInstance(object: object)
        XCTAssertNil(geoPoint)
    }

    func test_createInstance_lackingLongitudeField() {
        var object : [String : Any] = [:]
        object["__type"] = "GeoPoint"
        object["latitude"] = Double(35.6666269)
        let geoPoint : NCMBGeoPoint? = NCMBGeoPoint.createInstance(object: object)
        XCTAssertNil(geoPoint)
    }

    func test_createInstance_longitudeFieldIsNotDouble() {
        var object : [String : Any] = [:]
        object["__type"] = "GeoPoint"
        object["latitude"] = Double(35.6666269)
        object["longitude"] = "139.765607"
        let geoPoint : NCMBGeoPoint? = NCMBGeoPoint.createInstance(object: object)
        XCTAssertNil(geoPoint)
    }

    func test_toObject() {
        let geoPoint = NCMBGeoPoint(latitude: 35.6666269, longitude: 139.765607)
        let object : [String : Any] = geoPoint.toObject()
        XCTAssertEqual(object["__type"]! as! String, "GeoPoint")
        XCTAssertEqual(object["latitude"]! as! Double, Double(35.6666269))
        XCTAssertEqual(object["longitude"]! as! Double, Double(139.765607))
    }

    static var allTests = [
        ("test_createInstance_success", test_createInstance_success),
        ("test_createInstance_notDictionary", test_createInstance_notDictionary),
        ("test_createInstance_lackingTypeField", test_createInstance_lackingTypeField),
        ("test_createInstance_TypeFieldIsNotGeoPoint", test_createInstance_TypeFieldIsNotGeoPoint),
        ("test_createInstance_lackingLatitudeField", test_createInstance_lackingLatitudeField),
        ("test_createInstance_latitudeFieldIsNotDouble", test_createInstance_latitudeFieldIsNotDouble),
        ("test_createInstance_lackingLongitudeField", test_createInstance_lackingLongitudeField),
        ("test_createInstance_longitudeFieldIsNotDouble", test_createInstance_longitudeFieldIsNotDouble),
        ("test_toObject", test_toObject),
    ]
}
