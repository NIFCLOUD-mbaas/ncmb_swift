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

/// NCMBACL のテストクラスです。
final class NCMBACLTests: NCMBTestCase {

    func test_constant_default() {
        let sut = NCMBACL.default

        XCTAssertEqual(sut.getReadable(key: "*"), true)
        XCTAssertEqual(sut.getWritable(key: "*"), true)
    }

    func test_constant_empty() {
        let sut = NCMBACL.empty

        XCTAssertNil(sut.getReadable(key: "*"))
        XCTAssertNil(sut.getWritable(key: "*"))
    }

    func test_init_default() {
        let sut = NCMBACL.default

        XCTAssertEqual(sut.getReadable(key: "*"), true)
        XCTAssertEqual(sut.getWritable(key: "*"), true)
    }

    func test_init_params_readWrite() {
        var object : [String : Any] = [:]
        
        var rw : [String : Bool] = [:]
        rw["read"] = true
        rw["write"] = true
        object["abcd"] = rw
        
        let sut = NCMBACL(object: object)
        
        XCTAssertEqual(sut.getReadable(key: "abcd"), true)
        XCTAssertEqual(sut.getWritable(key: "abcd"), true)
    }
    
    func test_init_params_readOnly() {
        var object : [String : Any] = [:]
        
        var rw : [String : Bool] = [:]
        rw["read"] = true
        object["efgh"] = rw
        
        let sut = NCMBACL(object: object)
        
        XCTAssertEqual(sut.getReadable(key: "efgh"), true)
        XCTAssertEqual(sut.getWritable(key: "efgh"), false)
    }
    
    func test_init_params_writeOnly() {
        var object : [String : Any] = [:]
        
        var rw : [String : Bool] = [:]
        rw["write"] = true
        object["ijkl"] = rw
        
        let sut = NCMBACL(object: object)
        
        XCTAssertEqual(sut.getReadable(key: "ijkl"), false)
        XCTAssertEqual(sut.getWritable(key: "ijkl"), true)
    }
    
    func test_init_params_none() {
        var object : [String : Any] = [:]
        
        let rw : [String : Bool] = [:]
        object["mnop"] = rw
        
        let sut = NCMBACL(object: object)
        
        XCTAssertEqual(sut.getReadable(key: "mnop"), false)
        XCTAssertEqual(sut.getWritable(key: "mnop"), false)
    }
    
    func test_init_params_invalid() {
        var object : [String : Any] = [:]
        
        var rw : [String : String] = [:]
        rw["read"] = "true"
        object["qrst"] = rw
        
        let sut = NCMBACL(object: object)
        
        XCTAssertNil(sut.getReadable(key: "qrst"))
        XCTAssertNil(sut.getWritable(key: "qrst"))
    }

    func test_init_params_existAllkey() {
        var object : [String : Any] = [:]
        
        var rw : [String : Bool] = [:]
        rw["read"] = true
        rw["write"] = true
        object["*"] = rw
        
        let sut = NCMBACL(object: object)
        
        XCTAssertEqual(sut.getReadable(key: "*"), true)
        XCTAssertEqual(sut.getWritable(key: "*"), true)
    }
    
    func test_init_params_notExistAllkey() {
        var object : [String : Any] = [:]
        
        var rw : [String : Bool] = [:]
        rw["read"] = true
        rw["write"] = true
        object["abcd"] = rw
        
        let sut = NCMBACL(object: object)
        
        XCTAssertNil(sut.getReadable(key: "*"))
        XCTAssertNil(sut.getWritable(key: "*"))
    }
    
    func test_put_notExistBefore() {
        let object : [String : Any] = [:]
        
        var sut = NCMBACL(object: object)
        sut.put(key: "ijkl", readable: false, writable: true)
        
        XCTAssertEqual(sut.getReadable(key: "ijkl"), false)
        XCTAssertEqual(sut.getWritable(key: "ijkl"), true)
    }
    
    func test_put_ExistBefore() {
        var object : [String : Any] = [:]
        
        var rw : [String : Bool] = [:]
        rw["read"] = true
        rw["write"] = false
        object["efgh"] = rw
        
        var sut = NCMBACL(object: object)
        sut.put(key: "efgh", readable: false, writable: true)
        
        XCTAssertEqual(sut.getReadable(key: "efgh"), false)
        XCTAssertEqual(sut.getWritable(key: "efgh"), true)
    }
    
    func test_put_DontRemoveBeforeData() {
        var object : [String : Any] = [:]
        
        var rw : [String : Bool] = [:]
        rw["read"] = true
        rw["write"] = false
        object["abcd"] = rw
        
        var sut = NCMBACL(object: object)
        sut.put(key: "ijkl", readable: false, writable: true)
        
        XCTAssertEqual(sut.getReadable(key: "abcd"), true)
        XCTAssertEqual(sut.getWritable(key: "abcd"), false)
    }

    func test_put_PutAllkey() {
        let object : [String : Any] = [:]
        
        var sut = NCMBACL(object: object)
        sut.put(key: "*", readable: false, writable: true)
        
        XCTAssertEqual(sut.getReadable(key: "*"), false)
        XCTAssertEqual(sut.getWritable(key: "*"), true)
    }
    
    func test_put_notAddAllkeyWithoutPutAllkey() {
        let object : [String : Any] = [:]
        
        var sut = NCMBACL(object: object)
        sut.put(key: "abcd", readable: false, writable: true)
        
        XCTAssertNil(sut.getReadable(key: "*"))
        XCTAssertNil(sut.getWritable(key: "*"))
    }
    
    func test_remove_otherValue() {
        var object : [String : Any] = [:]
        
        var rw : [String : Bool] = [:]
        rw["read"] = true
        rw["write"] = false
        object["abcd"] = rw
        
        var sut = NCMBACL(object: object)
        sut.remove(key: "efgh")
        
        XCTAssertEqual(sut.getReadable(key: "abcd"), true)
        XCTAssertEqual(sut.getWritable(key: "abcd"), false)
    }
    
    func test_remove_existBefore() {
        var object : [String : Any] = [:]
        
        var rw : [String : Bool] = [:]
        rw["read"] = true
        rw["write"] = false
        object["efgh"] = rw
        
        var sut = NCMBACL(object: object)
        sut.remove(key: "efgh")
        
        XCTAssertNil(sut.getReadable(key: "efgh"))
        XCTAssertNil(sut.getWritable(key: "efgh"))
    }
    
    func test_remove_notExistBefore() {
        let object : [String : Any] = [:]
        
        var sut = NCMBACL(object: object)
        sut.remove(key: "ijkl")
        
        XCTAssertNil(sut.getReadable(key: "ijkl"))
        XCTAssertNil(sut.getWritable(key: "ijkl"))
    }
    
    func test_remove_allKeyExistBefore() {
        var object : [String : Any] = [:]
        
        var rw1 : [String : Bool] = [:]
        rw1["read"] = true
        rw1["write"] = false
        object["*"] = rw1
        
        var rw2 : [String : Bool] = [:]
        rw2["read"] = true
        rw2["write"] = false
        object["efgh"] = rw2
        
        var sut = NCMBACL(object: object)
        sut.remove(key: "*")
        
        XCTAssertEqual(sut.getReadable(key: "efgh"), true)
        XCTAssertEqual(sut.getWritable(key: "efgh"), false)
        XCTAssertNil(sut.getReadable(key: "*"))
        XCTAssertNil(sut.getWritable(key: "*"))
    }
    
    func test_remove_allKeyNotExistBefore() {
        var object : [String : Any] = [:]
        
        var rw : [String : Bool] = [:]
        rw["read"] = true
        rw["write"] = false
        object["efgh"] = rw
        
        var sut = NCMBACL(object: object)
        sut.remove(key: "*")
        
        XCTAssertEqual(sut.getReadable(key: "efgh"), true)
        XCTAssertEqual(sut.getWritable(key: "efgh"), false)
        XCTAssertNil(sut.getReadable(key: "*"))
        XCTAssertNil(sut.getWritable(key: "*"))
    }
    
    func test_toObject() {
        var object : [String : Any] = [:]

        var rw1 : [String : Bool] = [:]
        rw1["read"] = true
        rw1["write"] = false
        object["abcd"] = rw1

        var rw2 : [String : String] = [:]
        rw2["read"] = "true"
        rw2["write"] = "false"
        object["efgh"] = rw2

        var rw3 : [String : Bool] = [:]
        rw3["read"] = false
        rw3["write"] = true
        object["ijkl"] = rw3

        var rw4 : [String : Bool] = [:]
        rw4["read"] = false
        rw4["write"] = true
        object["mnop"] = rw4

        var sut = NCMBACL(object: object)

        sut.put(key: "ijkl", readable: false, writable: true)
        sut.put(key: "qrst", readable: false, writable: true)
        sut.remove(key: "mnop")
        sut.remove(key: "uvwx")

        let result : [String : [String : Bool]] = sut.toObject()

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result["abcd"]!.count, 1)
        XCTAssertEqual(result["abcd"]!["read"], true)
        XCTAssertNil(result["abcd"]!["write"])
        XCTAssertNil(result["efgh"])
        XCTAssertEqual(result["ijkl"]!.count, 1)
        XCTAssertNil(result["ijkl"]!["read"])
        XCTAssertEqual(result["ijkl"]!["write"], true)
        XCTAssertNil(result["mnop"])
        XCTAssertEqual(result["qrst"]!.count, 1)
        XCTAssertNil(result["qrst"]!["read"])
        XCTAssertEqual(result["qrst"]!["write"], true)
        XCTAssertNil(result["uvwx"])
        XCTAssertNil(result["*"])

    }

    func test_toObject_default() {
        let sut = NCMBACL.default

        let result : [String : [String : Bool]] = sut.toObject()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result["*"]!.count, 2)
        XCTAssertEqual(result["*"]!["read"], true)
        XCTAssertEqual(result["*"]!["write"], true)
    }

    func test_toObject_empty() {
        let sut = NCMBACL.empty
        
        let result : [String : [String : Bool]] = sut.toObject()
        
        XCTAssertEqual(result.count, 0)
    }
    
    //aclが全員のみの場合
    func test_acl_description_default() {
        let sut = NCMBACL.default
        
        XCTAssertEqual("\(sut)","{\"*\"=(read=true,write=true)}")
    }
    
    //aclが何もない場合
    func test_acl_description_empty() {
        let sut = NCMBACL.empty
        
        XCTAssertEqual("\(sut)","{}")
    }
    
    func test_acl_description_object() {
        var sut = NCMBACL.empty
        sut.put(key: "efgh", readable: false, writable: true)
        
        XCTAssertEqual("\(sut)","{\"efgh\"=(read=false,write=true)}")
    }
    
    func test_acl_description_role() {
        var sut = NCMBACL.empty
        sut.put(key: "role:admin", readable: true, writable: true)
        sut.put(key: "role:test", readable: true, writable: false)
        
        XCTAssertEqual("\(sut)","{\"role:admin\"=(read=true,write=true),\"role:test\"=(read=true,write=false)}")
    }
    
    func test_acl_description_default_object_role() {
        var sut = NCMBACL.default
        sut.put(key: "abcd", readable: true, writable: false)
        sut.put(key: "role:admin", readable: true, writable: true)
        sut.put(key: "role:test", readable: false, writable: false)
        
        XCTAssertEqual("\(sut)","{\"*\"=(read=true,write=true),\"abcd\"=(read=true,write=false),\"role:admin\"=(read=true,write=true),\"role:test\"=(read=false,write=false)}")
    }
    
    func test_acl_description_sort(){
        var sut = NCMBACL.default
        sut.put(key: "abc", readable: true, writable: false)
        sut.put(key: "cde", readable: false, writable: true)
        sut.put(key: "bcd", readable: false, writable: false)
        sut.put(key: "abc2", readable: true, writable: true)
        sut.put(key: "abc1", readable: true, writable: true)
        
        XCTAssertEqual("\(sut)","{\"*\"=(read=true,write=true),\"abc\"=(read=true,write=false),\"abc1\"=(read=true,write=true),\"abc2\"=(read=true,write=true),\"bcd\"=(read=false,write=false),\"cde\"=(read=false,write=true)}")
    }
    
    static var allTests = [
        ("test_constant_default", test_constant_default),
        ("test_constant_empty", test_constant_empty),
        ("test_init_default", test_init_default),
        ("test_init_params_readWrite", test_init_params_readWrite),
        ("test_init_params_readOnly", test_init_params_readOnly),
        ("test_init_params_writeOnly", test_init_params_writeOnly),
        ("test_init_params_none", test_init_params_none),
        ("test_init_params_invalid", test_init_params_invalid),
        ("test_init_params_existAllkey", test_init_params_existAllkey),
        ("test_init_params_notExistAllkey", test_init_params_notExistAllkey),
        ("test_put_notExistBefore", test_put_notExistBefore),
        ("test_put_ExistBefore", test_put_ExistBefore),
        ("test_put_DontRemoveBeforeData", test_put_DontRemoveBeforeData),
        ("test_put_PutAllkey", test_put_PutAllkey),
        ("test_put_notAddAllkeyWithoutPutAllkey", test_put_notAddAllkeyWithoutPutAllkey),
        ("test_remove_otherValue", test_remove_otherValue),
        ("test_remove_existBefore", test_remove_existBefore),
        ("test_remove_notExistBefore", test_remove_notExistBefore),
        ("test_remove_allKeyExistBefore", test_remove_allKeyExistBefore),
        ("test_remove_allKeyNotExistBefore", test_remove_allKeyNotExistBefore),
        ("test_toObject", test_toObject),
        ("test_toObject_default", test_toObject_default),
        ("test_toObject_empty", test_toObject_empty),
    ]
}
