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

/// NCMBBase のテストクラスです。
final class NCMBBaseTests: NCMBTestCase {

    func test_property_acl_decode() {
        let body : Data? = "{\"objectId\":\"abcdef012345\",\"createDate\":\"1986-02-04T12:34:56.123Z\",\"updateDate\":\"1986-02-04T12:34:56.789Z\",\"acl\":{\"abc\":{\"read\":true,\"write\":false},\"def\":{\"read\":false,\"write\":false}}}".data(using: .utf8)!
        let httpUrlResponse = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [:])!
        let response = try! NCMBResponse(body: body, response: httpUrlResponse)

        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut.reflectResponse(response: response)
        XCTAssertEqual(sut.acl!.getReadable(key: "abc"), true)
        XCTAssertEqual(sut.acl!.getWritable(key: "abc"), false)
        XCTAssertNil(sut.acl!.getReadable(key: "ghi"))
    }

    func test_property_acl_encode() {
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: [:], statusCode : 201)
        let executor : MockRequestExecutor = MockRequestExecutor(result: .success(response))
        NCMBRequestExecutorFactory.setInstance(executor: executor)

        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut.objectId = "abcdefg12345"
        var acl = NCMBACL.empty
        acl.put(key: "abcd", readable: true, writable: false)
        sut.acl = acl

        let json = try! sut.toJson()!
        XCTAssertTrue(String(data: json, encoding: .utf8)!.contains("\"acl\":{\"abcd\":"))
        XCTAssertFalse(String(data: json, encoding: .utf8)!.contains("\"write\""))
        XCTAssertTrue(String(data: json, encoding: .utf8)!.contains("\"read\":true"))
    }

    func test_property_objectId() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut.objectId = "a12345678bc"
        XCTAssertEqual(sut.objectId, "a12345678bc")
    }

    func test_subscript_getset() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = "takano_san"
        XCTAssertEqual(sut["takanokun"], "takano_san")
        XCTAssertNil(sut["piyo"])
    }

    func test_subscript_types() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")

        let test_String_setValue  : String = "value_string"
        let test_Int_setValue  : Int = 42
        let test_Int8_setValue  : Int8 = -123
        let test_Int16_setValue  : Int16 = -456
        let test_Int32_setValue  : Int32 = -789
        let test_Int64_setValue  : Int64 = -12340
        let test_UInt8_setValue  : UInt8 = 123
        let test_UInt16_setValue  : UInt16 = 654
        let test_UInt32_setValue  : UInt32 = 987
        let test_UInt64_setValue  : UInt64 = 43210
        let test_Float_setValue  : Float = 12.345
        let test_Double_setValue  : Double = 67.890123

        sut["test_String"] = test_String_setValue
        sut["test_Int"] = test_Int_setValue
        sut["test_Int8"] = test_Int8_setValue
        sut["test_Int16"] = test_Int16_setValue
        sut["test_Int32"] = test_Int32_setValue
        sut["test_Int64"] = test_Int64_setValue
        sut["test_UInt8"] = test_UInt8_setValue
        sut["test_UInt16"] = test_UInt16_setValue
        sut["test_UInt32"] = test_UInt32_setValue
        sut["test_UInt64"] = test_UInt64_setValue
        sut["test_Float"] = test_Float_setValue
        sut["test_Double"] = test_Double_setValue

        let test_String_getValue : String? = sut["test_String"]
        let test_Int_getValue : Int? = sut["test_Int"]
        let test_Int8_getValue : Int8? = sut["test_Int8"]
        let test_Int16_getValue : Int16? = sut["test_Int16"]
        let test_Int32_getValue : Int32? = sut["test_Int32"]
        let test_Int64_getValue : Int64? = sut["test_Int64"]
        let test_UInt8_getValue : UInt8? = sut["test_UInt8"]
        let test_UInt16_getValue : UInt16? = sut["test_UInt16"]
        let test_UInt32_getValue : UInt32? = sut["test_UInt32"]
        let test_UInt64_getValue : UInt64? = sut["test_UInt64"]
        let test_Float_getValue : Float? = sut["test_Float"]
        let test_Double_getValue : Double? = sut["test_Double"]

        XCTAssertEqual(test_String_getValue, "value_string")
        XCTAssertEqual(test_Int_getValue, 42)
        XCTAssertEqual(test_Int8_getValue, -123)
        XCTAssertEqual(test_Int16_getValue, -456)
        XCTAssertEqual(test_Int32_getValue, -789)
        XCTAssertEqual(test_Int64_getValue, -12340)
        XCTAssertEqual(test_UInt8_getValue, 123)
        XCTAssertEqual(test_UInt16_getValue, 654)
        XCTAssertEqual(test_UInt32_getValue, 987)
        XCTAssertEqual(test_UInt64_getValue, 43210)
        XCTAssertEqual(test_Float_getValue, 12.345)
        XCTAssertEqual(test_Double_getValue, 67.890123)
    }

    func test_subscript_get_fieldType_success() {
        var geoObject : [String : Any] = [:]
        geoObject["__type"] = "GeoPoint"
        geoObject["latitude"] = Double(35.6666269)
        geoObject["longitude"] = Double(139.765607)

        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = geoObject
        let geoPoint : NCMBGeoPoint = sut["takanokun"]!
        XCTAssertEqual(geoPoint.latitude, Double(35.6666269))
        XCTAssertEqual(geoPoint.longitude, Double(139.765607))
    }

    func test_subscript_get_fieldType_dictionary() {
        var geoObject : [String : Any] = [:]
        geoObject["__type"] = "GeoPoint"
        geoObject["latitude"] = Double(35.6666269)
        geoObject["longitude"] = Double(139.765607)

        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = geoObject
        let geoPoint : [String : Any] = sut["takanokun"]!
        XCTAssertEqual(geoPoint["__type"] as! String, "GeoPoint")
        XCTAssertEqual(geoPoint["latitude"] as! Double, Double(35.6666269))
        XCTAssertEqual(geoPoint["longitude"] as! Double, Double(139.765607))
    }

    func test_subscript_get_fieldType_mismatch() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = NCMBGeoPoint(latitude: 35.6666269, longitude: 139.765607)
        let pointer : NCMBPointer? = sut["takanokun"]
        XCTAssertNil(pointer)
    }

    func test_subscript_set_fieldType() {
        let geoPoint = NCMBGeoPoint(latitude: 35.6666269, longitude: 139.765607)
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = geoPoint

        let geoObject : [String : Any] = sut["takanokun"]!
        XCTAssertEqual(geoObject["__type"] as! String, "GeoPoint")
        XCTAssertEqual(geoObject["latitude"] as! Double, Double(35.6666269))
        XCTAssertEqual(geoObject["longitude"] as! Double, Double(139.765607))
    }

    func test_subscript_update() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = "takano_san"
        sut["takanokun"] = "piyo"
        XCTAssertEqual(sut["takanokun"], "piyo")
    }

    func test_subscript_remove() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = "takano_san"
        let nilValue : String? = nil
        sut["takanokun"] = nilValue
        XCTAssertNil(sut["takanokun"])
    }

    func test_subscript_ignoreKeys() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["objectId"] = "test_oobectId"
        sut["acl"] = "test_acl"
        sut["createDate"] = "test_createDate"
        sut["updateDate"] = "test_updateDate"
        XCTAssertNil(sut["test_oobectId"])
        XCTAssertNil(sut["test_acl"])
        XCTAssertNil(sut["test_createDate"])
        XCTAssertNil(sut["test_updateDate"])
    }

    func test_subscript_separate() {
        let sut1 : NCMBBase = NCMBBase(className: "TestClass")
        let sut2 : NCMBBase = NCMBBase(className: "TestClass")
        sut1["takanokun"] = "takano_san"
        sut2["takanokun"] = "piyo"
        XCTAssertEqual(sut1["takanokun"], "takano_san")
        XCTAssertEqual(sut2["takanokun"], "piyo")
    }

    func test_removeField() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = "takano_san"
        sut["piyo"] = 123
        sut.removeField(field: "takanokun")

        XCTAssertNil(sut["takanokun"])
        XCTAssertEqual(sut["piyo"], 123)
    }

    func test_needUpdate_init() {
        var fields : [String : Any] = [:]
        fields["takanokun"] = "takano_san"
        let sut : NCMBBase = NCMBBase(className: "TestClass", fields: fields)
        XCTAssertEqual(sut.needUpdate, false)
    }

    func test_needUpdate_setfieldValue() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = "takano_san"
        XCTAssertEqual(sut.needUpdate, true)
    }

    func test_needUpdate_removeField() {
        var fields : [String : Any] = [:]
        fields["takanokun"] = "takano_san"
        let sut : NCMBBase = NCMBBase(className: "TestClass", fields: fields)
        sut.removeField(field: "takanokun")
        XCTAssertEqual(sut.needUpdate, true)
    }

    func test_needUpdate_afterRefrect() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = "takano_san"
        sut.reflectResponse(response: response)
        XCTAssertEqual(sut.needUpdate, false)
    }

    func test_refrectResponse_none() {
        let contents : [String : Any] = [:]
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        var fields : [String : Any] = [:]
        fields["objectId"] = "hijklmn67890"
        fields["field_a"] = "value_1"
        fields["field_b"] = "value_2"
        fields["field_c"] = "value_3"
        fields["field_d"] = "value_4"
        let sut : NCMBBase = NCMBBase(className: "TestClass", fields: fields)
        sut["field_a"] = "value_w"
        sut["field_b"] = "value_x"
        sut["field_e"] = "value_y"
        sut["field_f"] = "value_z"

        sut.reflectResponse(response: response)

        XCTAssertEqual(sut.objectId, "hijklmn67890")
        XCTAssertEqual(sut["field_a"], "value_w")
        XCTAssertEqual(sut["field_b"], "value_x")
        XCTAssertEqual(sut["field_c"], "value_3")
        XCTAssertEqual(sut["field_d"], "value_4")
        XCTAssertEqual(sut["field_e"], "value_y")
        XCTAssertEqual(sut["field_f"], "value_z")
    }

    func test_refrectResponse_update() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["field_a"] = "value_a"
        contents["field_c"] = "value_c"
        contents["field_e"] = "value_e"
        contents["field_g"] = "value_g"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        var fields : [String : Any] = [:]
        fields["objectId"] = "hijklmn67890"
        fields["field_a"] = "value_1"
        fields["field_b"] = "value_2"
        fields["field_c"] = "value_3"
        fields["field_d"] = "value_4"
        let sut : NCMBBase = NCMBBase(className: "TestClass", fields: fields)
        sut["field_a"] = "value_w"
        sut["field_b"] = "value_x"
        sut["field_e"] = "value_y"
        sut["field_f"] = "value_z"

        sut.reflectResponse(response: response)

        XCTAssertEqual(sut.objectId, "abcdefg12345")
        XCTAssertEqual(sut["createDate"], "1986-02-04T12:34:56.789Z")
        XCTAssertEqual(sut["field_a"], "value_a")
        XCTAssertEqual(sut["field_b"], "value_x")
        XCTAssertEqual(sut["field_c"], "value_c")
        XCTAssertEqual(sut["field_d"], "value_4")
        XCTAssertEqual(sut["field_e"], "value_e")
        XCTAssertEqual(sut["field_f"], "value_z")
        XCTAssertEqual(sut["field_g"], "value_g")
    }

    func test_refrectResponse_modifiedFieldKeys() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["field_a"] = "value_a"
        contents["field_c"] = "value_c"
        contents["field_e"] = "value_e"
        contents["field_g"] = "value_g"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        var fields : [String : Any] = [:]
        fields["objectId"] = "hijklmn67890"
        fields["field_a"] = "value_1"
        fields["field_b"] = "value_2"
        fields["field_c"] = "value_3"
        fields["field_d"] = "value_4"
        let sut : NCMBBase = NCMBBase(className: "TestClass", fields: fields)
        sut["field_a"] = "value_w"
        sut["field_b"] = "value_x"
        sut["field_e"] = "value_y"
        sut["field_f"] = "value_z"

        sut.reflectResponse(response: response)

        XCTAssertEqual(try! sut.getModifiedToJson(), "{}".data(using: .utf8))
    }

    func test_getModifiedToJson_init() {
        var fields : [String : Any] = [:]
        fields["takanokun"] = "takano_san"
        let sut : NCMBBase = NCMBBase(className: "TestClass", fields: fields)
        XCTAssertEqual(try! sut.getModifiedToJson(), "{}".data(using: .utf8))
    }

    func test_getModifiedToJson_setfieldValue() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = "takano_san"
        XCTAssertEqual(try! sut.getModifiedToJson(), "{\"takanokun\":\"takano_san\"}".data(using: .utf8))
    }

    func test_getModifiedToJson_removeField() {
        var fields : [String : Any] = [:]
        fields["takanokun"] = "takano_san"
        let sut : NCMBBase = NCMBBase(className: "TestClass", fields: fields)
        sut.removeField(field: "takanokun")
        XCTAssertEqual(try! sut.getModifiedToJson(), "{\"takanokun\":null}".data(using: .utf8))
    }

    func test_getModifiedToJson_afterRefrect() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = "takano_san"
        sut.reflectResponse(response: response)
        XCTAssertEqual(try! sut.getModifiedToJson(), "{}".data(using: .utf8))
    }

    func test_toJson_init() {
        var fields : [String : Any] = [:]
        fields["takanokun"] = "takano_san"
        let sut : NCMBBase = NCMBBase(className: "TestClass", fields: fields)
        XCTAssertEqual(try! sut.toJson(), "{\"takanokun\":\"takano_san\"}".data(using: .utf8))
    }

    func test_toJson_setfieldValue() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = "takano_san"
        XCTAssertEqual(try! sut.toJson(), "{\"takanokun\":\"takano_san\"}".data(using: .utf8))
    }

    func test_toJson_removeField() {
        var fields : [String : Any] = [:]
        fields["takanokun"] = "takano_san"
        let sut : NCMBBase = NCMBBase(className: "TestClass", fields: fields)
        sut.removeField(field: "takanokun")
        XCTAssertEqual(try! sut.toJson(), "{}".data(using: .utf8))
    }

    func test_toJson_afterRefrect() {
        var contents : [String : Any] = [:]
        contents["objectId"] = "abcdefg12345"
        contents["createDate"] = "1986-02-04T12:34:56.789Z"
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = "takano_san"
        sut.reflectResponse(response: response)
        let json : Data = try! sut.toJson()!
        let jsonString : String = String(data: json, encoding: .utf8)!
        XCTAssertNotNil(jsonString.range(of: "\"objectId\":\"abcdefg12345\""))
        XCTAssertNotNil(jsonString.range(of: "\"createDate\":\"1986-02-04T12:34:56.789Z\""))
        XCTAssertNotNil(jsonString.range(of: "\"takanokun\":\"takano_san\""))
    }

    func test_isIgnoredKey() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["takanokun"] = 42
        XCTAssertTrue(sut.isIgnoredKey(field: "objectId"))
        XCTAssertTrue(sut.isIgnoredKey(field: "acl"))
        XCTAssertTrue(sut.isIgnoredKey(field: "createDate"))
        XCTAssertTrue(sut.isIgnoredKey(field: "updateDate"))
        XCTAssertFalse(sut.isIgnoredKey(field: "takanokun"))
    }

    func test_isIgnoredKey_setFieldValue() {
        let sut : NCMBBase = NCMBBase(className: "TestClass")
        sut["objectId"] = "abc"
        sut["acl"] = NCMBACL.default
        sut["createDate"] = "def"
        sut["updateDate"] = "ghi"
        sut["takanokun"] = "jkl"
        XCTAssertNil(sut["objectId"])
        XCTAssertNil(sut["acl"])
        XCTAssertNil(sut["createDate"])
        XCTAssertNil(sut["updateDate"])
        XCTAssertEqual(sut["takanokun"], "jkl")
    }

    func test_copy() {
        let sut : NCMBBase = NCMBBase()
        sut["field1"] = "takano_san"

        let base = sut
        let base2 = sut.copy

        sut["field1"] = "takanokun"
        XCTAssertEqual(base["field1"], "takanokun")
        XCTAssertEqual(base2["field1"], "takano_san")
    }
    
    //fieldsがStringのみの場合
    func test_description_basic() {
        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "takanokun"
        sut["field2"] = "42"
        let nilValue: String? = nil
        sut["field3"] = nilValue
        XCTAssertEqual("\(sut)", "{className=TestClass,objectId=abcdefg12345,field1=takanokun,field2=42}")
    }
    
    //fieldsが整数を持つ場合
    func test_description_fields_have_int() {
        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "takanokun"
        sut["field2"] = 42
        let nilValue: String? = nil
        sut["field3"] = nilValue
        XCTAssertEqual("\(sut)", "{className=TestClass,objectId=abcdefg12345,field1=takanokun,field2=42}")
    }
    
    //fieldsが全てnilの場合
    func test_description_fields_all_nil(){
        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        let nilValue: String? = nil
        sut["field1"] = nilValue
        sut["field2"] = nilValue
        sut["field3"] = nilValue
        XCTAssertEqual("\(sut)", "{className=TestClass,objectId=abcdefg12345}")
    }
    
    //objectIdがnilの場合
    func test_description_objectId_is_nill(){
        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = nil
        let nilValue: String? = nil
        sut["field1"] = "takanokun"
        sut["field2"] = "42"
        sut["field3"] = nilValue
        XCTAssertEqual("\(sut)", "{className=TestClass,objectId=nil,field1=takanokun,field2=42}")
    }
    
    //fieldが小数を持つ場合
    func test_description_fields_have_double(){
        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["field1"] = "takanokun"
        sut["field2"] = "42"
        sut["field3"] = 15.2
        XCTAssertEqual("\(sut)", "{className=TestClass,objectId=abcdefg12345,field1=takanokun,field2=42,field3=15.2}")
    }
    
    //fieldがブール値を持つ場合
    func test_description_fields_have_boolean(){
        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        let nilValue: String? = nil
        sut["field1"] = false
        sut["field2"] = true
        sut["field3"] = nilValue
        XCTAssertEqual("\(sut)", "{className=TestClass,objectId=abcdefg12345,field1=false,field2=true}")
    }
    
    //fieldがソートされているかのテスト
    func test_description_fields_is_sorted(){
        let sut : NCMBObject = NCMBObject(className: "TestClass")
        sut.objectId = "abcdefg12345"
        sut["abc"] = "takanokun"
        sut["cba"] = "42"
        sut["acd"] = 15.2
        sut["cba1"] = "test"
        sut["cba2"] = "42"
        XCTAssertEqual("\(sut)", "{className=TestClass,objectId=abcdefg12345,abc=takanokun,acd=15.2,cba=42,cba1=test,cba2=42}")
    }

    static var allTests = [
        ("test_property_acl_decode", test_property_acl_decode),
        ("test_property_acl_encode", test_property_acl_encode),
        ("test_property_objectId", test_property_objectId),
        ("test_subscript_getset", test_subscript_getset),
        ("test_subscript_types", test_subscript_types),
        ("test_subscript_get_fieldType_success", test_subscript_get_fieldType_success),
        ("test_subscript_get_fieldType_dictionary", test_subscript_get_fieldType_dictionary),
        ("test_subscript_get_fieldType_mismatch", test_subscript_get_fieldType_mismatch),
        ("test_subscript_set_fieldType", test_subscript_set_fieldType),
        ("test_subscript_update", test_subscript_update),
        ("test_subscript_remove", test_subscript_remove),
        ("test_subscript_ignoreKeys", test_subscript_ignoreKeys),
        ("test_subscript_separate", test_subscript_separate),
        ("test_removeField", test_removeField),
        ("test_needUpdate_init", test_needUpdate_init),
        ("test_needUpdate_setfieldValue", test_needUpdate_setfieldValue),
        ("test_needUpdate_removeField", test_needUpdate_removeField),
        ("test_needUpdate_afterRefrect", test_needUpdate_afterRefrect),
        ("test_refrectResponse_none", test_refrectResponse_none),
        ("test_refrectResponse_update", test_refrectResponse_update),
        ("test_refrectResponse_modifiedFieldKeys", test_refrectResponse_modifiedFieldKeys),
        ("test_getModifiedToJson_init", test_getModifiedToJson_init),
        ("test_getModifiedToJson_setfieldValue", test_getModifiedToJson_setfieldValue),
        ("test_getModifiedToJson_removeField", test_getModifiedToJson_removeField),
        ("test_getModifiedToJson_afterRefrect", test_getModifiedToJson_afterRefrect),
        ("test_toJson_init", test_toJson_init),
        ("test_toJson_setfieldValue", test_toJson_setfieldValue),
        ("test_toJson_removeField", test_toJson_removeField),
        ("test_toJson_afterRefrect", test_toJson_afterRefrect),
        ("test_isIgnoredKey", test_isIgnoredKey),
        ("test_isIgnoredKey_setFieldValue", test_isIgnoredKey_setFieldValue),
        ("test_copy", test_copy),
    ]

}
