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

/// NCMBFieldTypeConverter のテストクラスです。
final class NCMBFieldTypeConverterTests: NCMBTestCase {

    func test_convertToFieldValue_NCMBIncrementOperator() {
        var object : [String : Any] = [:]
        object["__op"] = "Increment"
        object["amount"] = 42
        let incrementOperator = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertEqual((incrementOperator! as! NCMBIncrementOperator).amount as! Int, 42)
    }

    func test_convertToFieldValue_NCMBAddOperator() {
        var object : [String : Any] = [:]
        object["__op"] = "Add"
        object["objects"] = ["takanokun"]
        let addOperator = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertEqual((addOperator! as! NCMBAddOperator).elements.count, 1)
        XCTAssertEqual((addOperator! as! NCMBAddOperator).elements[0] as! String, "takanokun")
    }

    func test_convertToFieldValue_NCMBAddUniqueOperator() {
        var object : [String : Any] = [:]
        object["__op"] = "AddUnique"
        object["objects"] = ["takanokun"]
        let addUniqueOperator = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertEqual((addUniqueOperator! as! NCMBAddUniqueOperator).elements.count, 1)
        XCTAssertEqual((addUniqueOperator! as! NCMBAddUniqueOperator).elements[0] as! String, "takanokun")
    }

    func test_convertToFieldValue_NCMBRemoveOperator() {
        var object : [String : Any] = [:]
        object["__op"] = "Remove"
        object["objects"] = ["takanokun"]
        let removeOperator = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertEqual((removeOperator! as! NCMBRemoveOperator).elements.count, 1)
        XCTAssertEqual((removeOperator! as! NCMBRemoveOperator).elements[0] as! String, "takanokun")
    }

     func test_convertToFieldValue_NCMBAddRelationOperator() {
        var object : [String : Any] = [:]
        object["__op"] = "AddRelation"
        object["className"] = "TestClass"
        var pointerJson : [String : Any] = [:]
        pointerJson["__type"] = "Pointer"
        pointerJson["className"] = "TestClass"
        pointerJson["objectId"] = "hogeHOGE12345678"
        object["objects"] = [pointerJson]

        let addRelationOperator = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertEqual((addRelationOperator! as! NCMBAddRelationOperator).elements.count, 1)
        XCTAssertEqual((addRelationOperator! as! NCMBAddRelationOperator).elements[0] , NCMBPointer(className: "TestClass", objectId: "hogeHOGE12345678"))
     }

    func test_convertToFieldValue_NCMBRemoveRelationOperator() {
        var object : [String : Any] = [:]
        object["__op"] = "RemoveRelation"
        object["className"] = "TestClass"
        var pointerJson : [String : Any] = [:]
        pointerJson["__type"] = "Pointer"
        pointerJson["className"] = "TestClass"
        pointerJson["objectId"] = "hogeHOGE12345678"
        object["objects"] = [pointerJson]
        
        let removeRelationOperator = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertEqual((removeRelationOperator! as! NCMBRemoveRelationOperator).elements.count, 1)
        XCTAssertEqual((removeRelationOperator! as! NCMBRemoveRelationOperator).elements[0] , NCMBPointer(className: "TestClass", objectId: "hogeHOGE12345678"))
    }

    func test_convertToFieldValue_Date() {
        var object : [String : Any] = [:]
        object["__type"] = "Date"
        object["iso"] = "1986-02-04T12:34:56.789Z"
        let date = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertEqual(date! as! Date, Date(timeIntervalSince1970: 507904496.789))
    }

    func test_convertToFieldValue_NCMBPointer() {
        var object : [String : Any] = [:]
        object["__type"] = "Pointer"
        object["className"] = "TestClass"
        object["objectId"] = "abcde12345"
        let pointer = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertEqual((pointer! as! NCMBPointer).className, "TestClass")
        XCTAssertEqual((pointer! as! NCMBPointer).objectId, "abcde12345")
    }

    func test_convertToFieldValue_NCMBRelation() {
        var object : [String : Any] = [:]
        object["__type"] = "Relation"
        object["className"] = "TestClass"
        let relation = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertEqual((relation! as! NCMBRelation).className, "TestClass")
    }

    func test_convertToFieldValue_NCMBGeoPoint() {
        var object : [String : Any] = [:]
        object["__type"] = "GeoPoint"
        object["latitude"] = Double(35.6666269)
        object["longitude"] = Double(139.765607)
        let geoPoint = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertEqual((geoPoint! as! NCMBGeoPoint).latitude, Double(35.6666269))
        XCTAssertEqual((geoPoint! as! NCMBGeoPoint).longitude, Double(139.765607))
    }

    // func test_convertToFieldValue_NCMBObjectField() {
    // TBD
    // }

    func test_convertToFieldValue_Int() {
        let object : Int = 42
        let int = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertNil(int)
    }

    func test_convertToFieldValue_String() {
        let object : String = "takanokun"
        let string = NCMBFieldTypeConverter.convertToFieldValue(object: object)
        XCTAssertNil(string)
    }

    func test_converToObject_NCMBIncrementOperator() {
        let incrementOperator = NCMBIncrementOperator(amount: 42)
        var object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: incrementOperator)
        XCTAssertEqual(object!["__op"]! as! String, "Increment")
        XCTAssertEqual(object!["amount"]! as! Int, 42)
    }

    func test_converToObject_NCMBAddOperator() {
        let addOperator = NCMBAddOperator(elements: ["takanokun", "takano_san"])
        var object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: addOperator)
        XCTAssertEqual(object!["__op"]! as! String, "Add")
        XCTAssertEqual((object!["objects"]! as! Array<String>).count, 2)
        XCTAssertEqual((object!["objects"]! as! Array<String>)[0], "takanokun")
        XCTAssertEqual((object!["objects"]! as! Array<String>)[1], "takano_san")
    }

    func test_converToObject_NCMBAddUniqueOperator() {
        let addUniqueOperator = NCMBAddUniqueOperator(elements: ["takanokun", "takano_san"])
        var object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: addUniqueOperator)
        XCTAssertEqual(object!["__op"]! as! String, "AddUnique")
        XCTAssertEqual((object!["objects"]! as! Array<String>).count, 2)
        XCTAssertEqual((object!["objects"]! as! Array<String>)[0], "takanokun")
        XCTAssertEqual((object!["objects"]! as! Array<String>)[1], "takano_san")
    }

    func test_converToObject_NCMBRemoveOperator() {
        let removeOperator = NCMBRemoveOperator(elements: ["takanokun", "takano_san"])
        var object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: removeOperator)
        XCTAssertEqual(object!["__op"]! as! String, "Remove")
        XCTAssertEqual((object!["objects"]! as! Array<String>).count, 2)
        XCTAssertEqual((object!["objects"]! as! Array<String>)[0], "takanokun")
        XCTAssertEqual((object!["objects"]! as! Array<String>)[1], "takano_san")
    }

    func test_converToObject_NCMBAddRelationOperator() {
        let JsontoObject1 = NCMBPointer(className: "TestClass", objectId: "hogeHOGE12345678")
        let JsontoObject2 = NCMBPointer(className: "TestClass", objectId: "hogeHOGE90123456")
        let addRelationOperator = NCMBAddRelationOperator(elements: [JsontoObject1,JsontoObject2])

        var object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: addRelationOperator)
        XCTAssertEqual(object!["__op"]! as! String, "AddRelation")
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>).count, 2)
        
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[0].count, 3)
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[0]["__type"] as! String, "Pointer")
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[0]["className"] as! String, "TestClass")
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[0]["objectId"] as! String, "hogeHOGE12345678")
        
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[1].count, 3)
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[1]["__type"] as! String, "Pointer")
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[1]["className"] as! String, "TestClass")
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[1]["objectId"] as! String, "hogeHOGE90123456")
     }

    func test_converToObject_NCMBRemoveRelationOperator() {
        let JsontoObject1 = NCMBPointer(className: "TestClass", objectId: "hogeHOGE12345678")
        let JsontoObject2 = NCMBPointer(className: "TestClass", objectId: "hogeHOGE90123456")
        let removeRelationOperator = NCMBRemoveRelationOperator(elements: [JsontoObject1,JsontoObject2])
        
        var object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: removeRelationOperator)
        XCTAssertEqual(object!["__op"]! as! String, "RemoveRelation")
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>).count, 2)
        
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[0].count, 3)
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[0]["__type"] as! String, "Pointer")
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[0]["className"] as! String, "TestClass")
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[0]["objectId"] as! String, "hogeHOGE12345678")
        
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[1].count, 3)
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[1]["__type"] as! String, "Pointer")
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[1]["className"] as! String, "TestClass")
        XCTAssertEqual((object!["objects"]! as! Array<Dictionary<String,Any>>)[1]["objectId"] as! String, "hogeHOGE90123456")
    }

    func test_converToObject_Date() {
        let date = Date(timeIntervalSince1970: 507904496.789)
        var object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: date)
        XCTAssertEqual(object!["__type"]! as! String, "Date")
        XCTAssertEqual(object!["iso"]! as! String, "1986-02-04T12:34:56.789Z")
    }

    func test_converToObject_NCMBPointer() {
        let pointer = NCMBPointer(className: "TestClass", objectId: "abcde12345")
        var object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: pointer)
        XCTAssertEqual(object!["__type"]! as! String, "Pointer")
        XCTAssertEqual(object!["className"]! as! String, "TestClass")
        XCTAssertEqual(object!["objectId"]! as! String, "abcde12345")
    }

     func test_converToObject_NCMBRelation() {
        let relation = NCMBRelation(className: "TestClass")
        var object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: relation)
        XCTAssertEqual(object!["__type"]! as! String, "Relation")
        XCTAssertEqual(object!["className"]! as! String, "TestClass")
     }

    func test_converToObject_NCMBGeoPoint() {
        let geoPoint = NCMBGeoPoint(latitude: 35.6666269, longitude: 139.765607)
        var object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: geoPoint)
        XCTAssertEqual(object!["__type"]! as! String, "GeoPoint")
        XCTAssertEqual(object!["latitude"]! as! Double, Double(35.6666269))
        XCTAssertEqual(object!["longitude"]! as! Double, Double(139.765607))
    }

    // func test_converToObject_NCMBObjectField() {
    // TBD
    // }

    func test_converToObject_Int() {
        let object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: 42)
        XCTAssertNil(object)
    }

    func test_converToObject_String() {
        let object : [String : Any]? = NCMBFieldTypeConverter.converToObject(value: "takanokun")
        XCTAssertNil(object)
    }

    static var allTests = [
        ("test_convertToFieldValue_NCMBIncrementOperator", test_convertToFieldValue_NCMBIncrementOperator),
        ("test_convertToFieldValue_NCMBAddOperator", test_convertToFieldValue_NCMBAddOperator),
        ("test_convertToFieldValue_NCMBAddUniqueOperator", test_convertToFieldValue_NCMBAddUniqueOperator),
        ("test_convertToFieldValue_NCMBRemoveOperator", test_convertToFieldValue_NCMBRemoveOperator),
         ("test_convertToFieldValue_NCMBAddRelationOperator", test_convertToFieldValue_NCMBAddRelationOperator),
         ("test_convertToFieldValue_NCMBRemoveRelationOperator", test_convertToFieldValue_NCMBRemoveRelationOperator),
        ("test_convertToFieldValue_Date", test_convertToFieldValue_Date),
        ("test_convertToFieldValue_NCMBPointer", test_convertToFieldValue_NCMBPointer),
        ("test_convertToFieldValue_NCMBRelation", test_convertToFieldValue_NCMBRelation),
        ("test_convertToFieldValue_NCMBGeoPoint", test_convertToFieldValue_NCMBGeoPoint),
        // ("test_convertToFieldValue_NCMBObjectField", test_convertToFieldValue_NCMBObjectField),
        ("test_convertToFieldValue_Int", test_convertToFieldValue_Int),
        ("test_convertToFieldValue_String", test_convertToFieldValue_String),
        ("test_converToObject_NCMBIncrementOperator", test_converToObject_NCMBIncrementOperator),
        ("test_converToObject_NCMBAddOperator", test_converToObject_NCMBAddOperator),
        ("test_converToObject_NCMBAddUniqueOperator", test_converToObject_NCMBAddUniqueOperator),
        ("test_converToObject_NCMBRemoveOperator", test_converToObject_NCMBRemoveOperator),
         ("test_converToObject_NCMBAddRelationOperator", test_converToObject_NCMBAddRelationOperator),
         ("test_converToObject_NCMBRemoveRelationOperator", test_converToObject_NCMBRemoveRelationOperator),
        ("test_converToObject_Date", test_converToObject_Date),
        ("test_converToObject_NCMBPointer", test_converToObject_NCMBPointer),
        ("test_converToObject_NCMBRelation", test_converToObject_NCMBRelation),
        ("test_converToObject_NCMBGeoPoint", test_converToObject_NCMBGeoPoint),
        // ("test_converToObject_NCMBObjectField", test_converToObject_NCMBObjectField),
        ("test_converToObject_Int", test_converToObject_Int),
        ("test_converToObject_String", test_converToObject_String),
    ]
}
