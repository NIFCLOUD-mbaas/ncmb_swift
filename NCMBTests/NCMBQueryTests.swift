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

/// NCMBQuery のテストクラスです。
final class NCMBQueryTests: NCMBTestCase {

    func test_init_className() {
        let sut = NCMBQuery.getQuery(className: "TestClass")
        XCTAssertEqual(sut.className, "TestClass")
        XCTAssertEqual(String(describing: type(of: sut)), "NCMBQuery<NCMBObject>")
        XCTAssertEqual(String(describing: type(of: sut.service)), "NCMBObjectService")
    }

    func test_init_service() {
        let sut = NCMBQuery<NCMBPush>(service: NCMBPushService())
        XCTAssertEqual(sut.className, "")
        XCTAssertEqual(String(describing: type(of: sut)), "NCMBQuery<NCMBPush>")
        XCTAssertEqual(String(describing: type(of: sut.service)), "NCMBPushService")
    }

    func test_init_all() {
        let lte: [String: Any] = ["$lte": 42]
        let whereItems: [String: Any] = ["takano_san": lte]
        let order = ["fieldY", "-fieldZ"]

        let sut = NCMBQuery<NCMBUser>(
            className: "takanokun",
            service: NCMBUserService(),
            whereItems: whereItems,
            isCount: true,
            order: order,
            skip: 45,
            limit: 29)
        XCTAssertEqual(sut.className, "takanokun")
        XCTAssertEqual(String(describing: type(of: sut)), "NCMBQuery<NCMBUser>")
        XCTAssertEqual(String(describing: type(of: sut.service)), "NCMBUserService")
        XCTAssertEqual(sut.whereItems.count, 1)
        XCTAssertEqual((sut.whereItems["takano_san"]! as! [String:Any]).count, 1)
        XCTAssertEqual((sut.whereItems["takano_san"]! as! [String:Any])["$lte"]! as! Int, 42)
        XCTAssertEqual(sut.isCount, true)
        XCTAssertEqual(sut.order, ["fieldY", "-fieldZ"])
        XCTAssertEqual(sut.skip, 45)
        XCTAssertEqual(sut.limit, 29)
    }
    
    func test_init_all_default() {
        let sut = NCMBQuery<NCMBUser>(
            className: "takanokun",
            service: NCMBUserService())
        XCTAssertEqual(sut.className, "takanokun")
        XCTAssertEqual(String(describing: type(of: sut)), "NCMBQuery<NCMBUser>")
        XCTAssertEqual(String(describing: type(of: sut.service)), "NCMBUserService")
        XCTAssertEqual(sut.whereItems.count, 0)
        XCTAssertEqual(sut.isCount, false)
        XCTAssertEqual(sut.order, [])
        XCTAssertNil(sut.skip)
        XCTAssertNil(sut.limit)
    }
    
    func test_requestItems_default() {
        let sut = NCMBQuery.getQuery(className: "TestClass")
        let requestItems : [String : String?] = sut.requestItems
        XCTAssertEqual(requestItems.count, 0)
    }

    func test_requestItems_all() {
        var sut = NCMBQuery.getQuery(className: "TestClass")
        sut.where(field: "takano_san", lessThanOrEqualTo: 42)
        sut.order = ["fieldA", "-fieldB"]
        sut.skip = 256
        sut.limit = 48
        sut.isCount = true
        let requestItems : [String : String?] = sut.requestItems
        XCTAssertEqual(requestItems.count, 5)
        XCTAssertEqual(requestItems["where"], "{\"takano_san\":{\"$lte\":42}}")
        XCTAssertEqual(requestItems["order"], "fieldA,-fieldB")
        XCTAssertEqual(requestItems["skip"], "256")
        XCTAssertEqual(requestItems["limit"], "48")
        XCTAssertEqual(requestItems["count"], "1")
    }

    func test_convertAnyToString() {
        let sut = NCMBQuery.getQuery(className: "TestClass")
        XCTAssertEqual(sut.convertAnyToString(nil), nil)
        XCTAssertEqual(sut.convertAnyToString(Int(3)), "3")
        XCTAssertEqual(sut.convertAnyToString("takanokun"), "takanokun")
        let object : [String : Any] = ["takanokun":["takano_san":24]]
        XCTAssertEqual(sut.convertAnyToString(object), "{\"takanokun\":{\"takano_san\":24}}")
    }

    func test_query_default() {
        let sut = NCMBQuery.getQuery(className: "TestClass")
        let queryItems : [String : Any?] = sut.query
        XCTAssertEqual(queryItems.count, 0)
    }

    func test_query_all() {
        var sut = NCMBQuery.getQuery(className: "TestClass")
        sut.where(field: "takano_san", lessThanOrEqualTo: 42)
        sut.order = ["fieldA", "-fieldB"]
        sut.skip = 256
        sut.limit = 48
        sut.isCount = true
        let queryItems : [String : Any?] = sut.query
        XCTAssertEqual(queryItems.count, 5)
        XCTAssertEqual((queryItems["where"] as! [String : Any]).count, 1)
        XCTAssertEqual(((queryItems["where"] as! [String : Any])["takano_san"] as! [String : Any]).count, 1)
        XCTAssertEqual(((queryItems["where"] as! [String : Any])["takano_san"] as! [String : Any])["$lte"] as! Int, 42)
        XCTAssertEqual(queryItems["order"] as! String, "fieldA,-fieldB")
        XCTAssertEqual(queryItems["skip"] as! Int, 256)
        XCTAssertEqual(queryItems["limit"] as! Int, 48)
        XCTAssertEqual(queryItems["count"] as! Int, 1)
    }

    func test_find_success() {
        let objectA : [String : Any] = ["objectId":"abcdefg12345", "field_a":"value_a", "field_b":"value_b", "field_c":"value_c"]
        let objectB : [String : Any] = ["objectId":"67890hijklmn", "field_a":"value_d", "field_e":"value_f", "field_c":"value_g"]
        let objectC : [String : Any] = ["objectId":"opqr76543stu", "field_a":"value_h", "field_b":"value_i", "field_c":"value_j"]
        let contents : [String : Any] = ["count":5, "results":[objectA, objectB, objectC]]
        let mockResponse : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(mockResponse)))

        let sut = NCMBQuery.getQuery(className: "TestClass")

        let result : NCMBResult<[NCMBObject]> = sut.find()
        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        let response : [NCMBObject] = NCMBTestUtil.getResponse(result: result)!
        XCTAssertEqual(response.count, 3)
        XCTAssertEqual(response[1]["objectId"], "67890hijklmn")
    }

    func test_find_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut = NCMBQuery.getQuery(className: "TestClass")

        let result: NCMBResult<[NCMBObject]> = sut.find()
        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_findInBackground_success() {
        let objectA : [String : Any] = ["objectId":"abcdefg12345", "field_a":"value_a", "field_b":"value_b", "field_c":"value_c"]
        let objectB : [String : Any] = ["objectId":"67890hijklmn", "field_a":"value_d", "field_e":"value_f", "field_c":"value_g"]
        let objectC : [String : Any] = ["objectId":"opqr76543stu", "field_a":"value_h", "field_b":"value_i", "field_c":"value_j"]
        let contents : [String : Any] = ["count":5, "results":[objectA, objectB, objectC]]
        let mockResponse : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(mockResponse)))

        let sut = NCMBQuery.getQuery(className: "TestClass")

        let expectation : XCTestExpectation? = self.expectation(description: "test_findInBackground_success")
        sut.findInBackground(callback: { (result: NCMBResult<[NCMBObject]>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response : [NCMBObject] = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response.count, 3)
            XCTAssertEqual(response[1]["objectId"], "67890hijklmn")
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_findInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        let sut = NCMBQuery.getQuery(className: "TestClass")

        let expectation : XCTestExpectation? = self.expectation(description: "test_findInBackground_failure")
        sut.findInBackground(callback: { (result: NCMBResult<[NCMBObject]>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_count_success() {
        let objectA : [String : Any] = ["objectId":"abcdefg12345", "field_a":"value_a", "field_b":"value_b", "field_c":"value_c"]
        let objectB : [String : Any] = ["objectId":"67890hijklmn", "field_a":"value_d", "field_e":"value_f", "field_c":"value_g"]
        let objectC : [String : Any] = ["objectId":"opqr76543stu", "field_a":"value_h", "field_b":"value_i", "field_c":"value_j"]
        let contents : [String : Any] = ["count":5, "results":[objectA, objectB, objectC]]
        let mockResponse : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(mockResponse)))

        var sut = NCMBQuery.getQuery(className: "TestClass")
        sut.where(field: "takano_san", lessThan: 42)

        let result : NCMBResult<Int> = sut.count()
        XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
        let response : Int = NCMBTestUtil.getResponse(result: result)!
        XCTAssertEqual(response, 5)
    }

    func test_count_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        var sut = NCMBQuery.getQuery(className: "TestClass")
        sut.where(field: "takano_san", lessThan: 42)

        let result : NCMBResult<Int> = sut.count()
        XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
        XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
    }

    func test_countInBackground_success() {
        let objectA : [String : Any] = ["objectId":"abcdefg12345", "field_a":"value_a", "field_b":"value_b", "field_c":"value_c"]
        let objectB : [String : Any] = ["objectId":"67890hijklmn", "field_a":"value_d", "field_e":"value_f", "field_c":"value_g"]
        let objectC : [String : Any] = ["objectId":"opqr76543stu", "field_a":"value_h", "field_b":"value_i", "field_c":"value_j"]
        let contents : [String : Any] = ["count":5, "results":[objectA, objectB, objectC]]
        let mockResponse : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(mockResponse)))

        var sut = NCMBQuery.getQuery(className: "TestClass")
        sut.where(field: "takano_san", lessThan: 42)

        let expectation : XCTestExpectation? = self.expectation(description: "test_countInBackground_success")
        sut.countInBackground(callback: { (result: NCMBResult<Int>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsSuccess(result: result))
            let response : Int = NCMBTestUtil.getResponse(result: result)!
            XCTAssertEqual(response, 5)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_countInBackground_failure() {
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .failure(DummyErrors.dummyError)))

        var sut = NCMBQuery.getQuery(className: "TestClass")
        sut.where(field: "takano_san", lessThan: 42)

        let expectation : XCTestExpectation? = self.expectation(description: "test_countInBackground_failure")
        sut.countInBackground(callback: { (result: NCMBResult<Int>) in
            XCTAssertTrue(NCMBTestUtil.checkResultIsFailure(result: result))
            XCTAssertEqual(NCMBTestUtil.getError(result: result)! as! DummyErrors, DummyErrors.dummyError)
            expectation?.fulfill()
        })
        self.waitForExpectations(timeout: 1.00, handler: nil)
    }

    func test_getResultObjects_ordinal() {
        let objectA : [String : Any] = ["objectId":"abcdefg12345", "field_a":"value_a", "field_b":"value_b", "field_c":"value_c"]
        let objectB : [String : Any] = ["objectId":"67890hijklmn", "field_a":"value_d", "field_e":"value_f", "field_c":"value_g"]
        let objectC : [String : Any] = ["objectId":"opqr76543stu", "field_a":"value_h", "field_b":"value_i", "field_c":"value_j"]
        let contents : [String : Any] = ["count":5, "results":[objectA, objectB, objectC]]
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        let sut = NCMBQuery.getQuery(className: "TestClass")
        let results : [NCMBObject] = sut.getResultObjects(response: response)
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[1]["objectId"], "67890hijklmn")
    }

    func test_getResultObjects_installation() {
        let objectA : [String : Any] = ["objectId":"abcdefg12345", "field_a":"value_a", "field_b":"value_b", "field_c":"value_c"]
        let objectB : [String : Any] = ["objectId":"67890hijklmn", "field_a":"value_d", "field_e":"value_f", "field_c":"value_g"]
        let objectC : [String : Any] = ["objectId":"opqr76543stu", "field_a":"value_h", "field_b":"value_i", "field_c":"value_j"]
        let contents : [String : Any] = ["count":5, "results":[objectA, objectB, objectC]]
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        let sut = NCMBInstallation.query
        let results : [NCMBInstallation] = sut.getResultObjects(response: response)
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[2]["objectId"], "opqr76543stu")
    }

    func test_getResultObjects_invalidMember() {
        let objectA : [String : Any] = ["objectId":"abcdefg12345", "field_a":"value_a", "field_b":"value_b", "field_c":"value_c"]
        let objectB : String = "{\"objectId\":\"67890hijklmn\",\"field_a\":\"value_d\",\"field_e\":\"value_f\",\"field_c\":\"value_g\"}"
        let objectC : [String : Any] = ["objectId":"opqr76543stu", "field_a":"value_h", "field_b":"value_i", "field_c":"value_j"]
        let contents : [String : Any] = ["count":5, "results":[objectA, objectB, objectC]]
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        let sut = NCMBQuery.getQuery(className: "TestClass")
        let results : [NCMBObject] = sut.getResultObjects(response: response)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[1]["objectId"], "opqr76543stu")
    }

    func test_getResultObjects_resultsNotExist() {
        let contents : [String : Any] = ["count":5]
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        let sut = NCMBQuery.getQuery(className: "TestClass")
        let results : [NCMBObject] = sut.getResultObjects(response: response)
        XCTAssertEqual(results.count, 0)
    }

    func test_getResultObjects_invalidResults() {
        let contents : [String : Any] = ["count":5, "results":"[42, 43, 44]"]
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        let sut = NCMBQuery.getQuery(className: "TestClass")
        let results : [NCMBObject] = sut.getResultObjects(response: response)
        XCTAssertEqual(results.count, 0)
    }

    func test_getResultCount_ordinal() {
        let objectA : [String : Any] = ["objectId":"abcdefg12345", "field_a":"value_a", "field_b":"value_b", "field_c":"value_c"]
        let objectB : [String : Any] = ["objectId":"67890hijklmn", "field_a":"value_d", "field_e":"value_f", "field_c":"value_g"]
        let objectC : [String : Any] = ["objectId":"opqr76543stu", "field_a":"value_h", "field_b":"value_i", "field_c":"value_j"]
        let contents : [String : Any] = ["count":5, "results":[objectA, objectB, objectC]]
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        let sut = NCMBQuery.getQuery(className: "TestClass")
        XCTAssertEqual(sut.getResultCount(response: response), 5)
    }

    func test_getResultCount_countNotExist() {
        let objectA : [String : Any] = ["objectId":"abcdefg12345", "field_a":"value_a", "field_b":"value_b", "field_c":"value_c"]
        let objectB : [String : Any] = ["objectId":"67890hijklmn", "field_a":"value_d", "field_e":"value_f", "field_c":"value_g"]
        let objectC : [String : Any] = ["objectId":"opqr76543stu", "field_a":"value_h", "field_b":"value_i", "field_c":"value_j"]
        let contents : [String : Any] = ["results":[objectA, objectB, objectC]]
        let response : NCMBResponse = MockResponseBuilder.createResponse(contents: contents, statusCode: 201)

        let sut = NCMBQuery.getQuery(className: "TestClass")
        XCTAssertEqual(sut.getResultCount(response: response), 0)
    }

    func test_createCountQuery() {
        var sut = NCMBQuery<NCMBPush>(service: NCMBPushService())
        sut.isCount = false
        sut.order = ["fieldA", "-fieldB"]
        sut.skip = 34
        sut.limit = 314
        let countQuery = sut.createCountQuery()
        XCTAssertEqual(countQuery.isCount, true)
        XCTAssertEqual(countQuery.order, [])
        XCTAssertEqual(countQuery.skip, nil)
        XCTAssertEqual(countQuery.limit, 0)
        XCTAssertEqual(sut.isCount, false)
        XCTAssertEqual(sut.order, ["fieldA", "-fieldB"])
        XCTAssertEqual(sut.skip, 34)
        XCTAssertEqual(sut.limit, 314)
    }

    func test_addOperation_ordinalType() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.addOperation(field: "takano_san", operation: "$trial", value: 42)
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$trial\":42}}")
    }

    func test_addOperation_specialType() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        let value : NCMBGeoPoint = NCMBGeoPoint(latitude: 35.6666269, longitude: 139.765607)
        sut.addOperation(field: "takano_san", operation: "$trial", value: value)
        XCTAssertTrue(sut.requestItems["where"]!!.contains("{\"takano_san\":{\"$trial\":{"))
        XCTAssertTrue(sut.requestItems["where"]!!.contains("\"__type\":\"GeoPoint\""))
        XCTAssertTrue(sut.requestItems["where"]!!.contains("\"latitude\":35.666626"))
        XCTAssertTrue(sut.requestItems["where"]!!.contains("\"longitude\":139.76560"))
        // "{\"takano_san\":{\"$trial\":{\"longitude\":139.76560699999999,\"__type\":\"GeoPoint\",\"latitude\":35.666626899999997}}}"
    }

    func test_getFieldItem() {
        var sut = NCMBQuery.getQuery(className: "TestClass")
        sut.where(field: "fieldA", equalTo: 42)
        sut.where(field: "fieldB", lessThan: 15)
        sut.where(field: "fieldB", greaterThan: 30)
        sut.where(field: "fieldC", lessThan: 15)
        sut.where(field: "fieldC", greaterThan: 30)
        sut.where(field: "fieldC", equalTo: 42)

        XCTAssertEqual(sut.getFieldItem(field: "fieldA").count, 0)
        XCTAssertEqual(sut.getFieldItem(field: "fieldB").count, 2)
        XCTAssertEqual(sut.getFieldItem(field: "fieldB")["$lt"] as! Int, 15)
        XCTAssertEqual(sut.getFieldItem(field: "fieldB")["$gt"] as! Int, 30)
        XCTAssertEqual(sut.getFieldItem(field: "fieldC").count, 0)
    }

    func test_convertToObject_ordinalType() {
        let sut = NCMBQuery.getQuery(className: "TestClass")
        let value : String = "piyo"
        XCTAssertEqual(sut.convertToObject(value: value) as! String, "piyo")
    }

    func test_convertToObject_specialType() {
        let sut = NCMBQuery.getQuery(className: "TestClass")
        let value : NCMBGeoPoint = NCMBGeoPoint(latitude: 35.6666269, longitude: 139.765607)
        let object = sut.convertToObject(value: value)

        XCTAssertEqual((object as! [String : Any])["__type"] as! String, "GeoPoint")
        XCTAssertEqual((object as! [String : Any])["latitude"] as! Double, 35.6666269)
        XCTAssertEqual((object as! [String : Any])["longitude"] as! Double, 139.765607)
    }

    func test_where_equalTo() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", equalTo: 42)
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":42}")
    }

    func test_where_notEqualTo() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", notEqualTo: 42)
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$ne\":42}}")
    }

    func test_where_lessThan() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", lessThan: 42)
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$lt\":42}}")
    }

    func test_where_greaterThan() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", greaterThan: 42)
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$gt\":42}}")
    }

    func test_where_lessThanOrEqualTo() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", lessThanOrEqualTo: 42)
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$lte\":42}}")
    }

    func test_where_greaterThanOrEqualTo() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", greaterThanOrEqualTo: 42)
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$gte\":42}}")
    }

    func test_where_containedIn() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", containedIn: [42, "piyo", 38])
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$in\":[42,\"piyo\",38]}}")
    }

    func test_where_notContainedIn() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", notContainedIn: [42, "piyo", 38])
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$nin\":[42,\"piyo\",38]}}")
    }

    func test_where_exists() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", exists: 42)
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$exists\":42}}")
    }

    func test_where_toMatchPattern() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", toMatchPattern: "[a-z]{2}[0-9]{3}")
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$regex\":\"[a-z]{2}[0-9]{3}\"}}")
    }

    func test_where_containedInArrayTo() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", containedInArrayTo: [42, "piyo", 38])
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$inArray\":[42,\"piyo\",38]}}")
    }

    func test_where_notContainedInArrayTo() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", notContainedInArrayTo: [42, "piyo", 38])
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$ninArray\":[42,\"piyo\",38]}}")
    }

    func test_where_containsAllObjectsInArrayTo() {
        var sut = NCMBQuery.getQuery(className: "Takanokun")
        sut.where(field: "takano_san", containsAllObjectsInArrayTo: [42, "piyo", 38])
        XCTAssertEqual(sut.requestItems["where"], "{\"takano_san\":{\"$all\":[42,\"piyo\",38]}}")
    }

    func test_orQuery_1queries() {
        var query1 = NCMBQuery.getQuery(className: "Takanokun1")
        query1.where(field: "fieldA", equalTo: "value1")
        let sut = NCMBQuery.orQuery(query1)
        XCTAssertEqual(sut.className, "Takanokun1")
        XCTAssertEqual(String(describing: type(of: sut)), "NCMBQuery<NCMBObject>")
        XCTAssertEqual(sut.requestItems["where"], "{\"$or\":[{\"fieldA\":\"value1\"}]}")
    }

    func test_orQuery_2queries() {
        var query1 = NCMBQuery.getQuery(className: "Takanokun1")
        query1.where(field: "fieldA", equalTo: "value1")
        var query2 = NCMBQuery.getQuery(className: "Takanokun2")
        query2.where(field: "field2", notEqualTo: "value2")
        let sut = NCMBQuery.orQuery(query1, query2)
        XCTAssertEqual(sut.className, "Takanokun1")
        XCTAssertEqual(String(describing: type(of: sut)), "NCMBQuery<NCMBObject>")
        XCTAssertEqual(sut.requestItems["where"], "{\"$or\":[{\"fieldA\":\"value1\"},{\"field2\":{\"$ne\":\"value2\"}}]}")
    }

    func test_orQuery_3queries() {
        var query1 = NCMBQuery.getQuery(className: "Takanokun1")
        query1.where(field: "fieldA", equalTo: "value1")
        var query2 = NCMBQuery.getQuery(className: "Takanokun2")
        query2.where(field: "field2", notEqualTo: "value2")
        var query3 = NCMBQuery.getQuery(className: "Takanokun3")
        query3.where(field: "field3", lessThan: 42)
        let sut = NCMBQuery.orQuery(query1, query2, query3)
        XCTAssertEqual(sut.className, "Takanokun1")
        XCTAssertEqual(String(describing: type(of: sut)), "NCMBQuery<NCMBObject>")
        XCTAssertEqual(sut.requestItems["where"], "{\"$or\":[{\"fieldA\":\"value1\"},{\"field2\":{\"$ne\":\"value2\"}},{\"field3\":{\"$lt\":42}}]}")
    }
    
    func test_where_select() {
        var query_city_class = NCMBQuery.getQuery(className: "City")
        query_city_class.where(field: "population", greaterThan: 1000000)
        query_city_class.limit = 1
        query_city_class.skip = 1
        
        var query_team_class = NCMBQuery.getQuery(className: "Team")
        query_team_class.where(field: "hometown", matchesKey: "cityname", inQuery: query_city_class)
        
        let where_expectation: [String : Any] = ["hometown": ["$select": ["key": "cityname", "query": ["className": "City", "skip": 1, "limit": 1, "where": ["population": ["$gt": 1000000]]]]]]
        XCTAssertTrue(NSDictionary(dictionary: query_team_class.whereItems).isEqual(to: where_expectation))
    }
    
    func test_where_inQuery() {
        var query_city_class = NCMBQuery.getQuery(className: "City")
        query_city_class.where(field: "population", greaterThan: 1000000)
        query_city_class.limit = 1
        query_city_class.skip = 1
        
        var query_team_class = NCMBQuery.getQuery(className: "Team")
        query_team_class.where(field: "hometown", matchesQuery: query_city_class)
        
        let where_expectation: [String : Any] = ["hometown": ["$inQuery": ["className": "City", "skip": 1, "limit": 1, "where": ["population": ["$gt": 1000000]]]]]
        XCTAssertTrue(NSDictionary(dictionary: query_team_class.whereItems).isEqual(to: where_expectation))
    }
    
    func test_where_nearGeoPoint() {
        let latitude = 35.688499
        let longitude = 139.684026
        let geoPoint = NCMBGeoPoint.init(latitude: latitude, longitude: longitude)
        var query = NCMBQuery.getQuery(className: "Shop")
        query.where(field: "geoPoint", nearGeoPoint: geoPoint)
        
        let where_expectation: [String : Any] = ["geoPoint": ["$nearSphere": ["__type": "GeoPoint", "latitude": latitude, "longitude": longitude]]]
        XCTAssertTrue(NSDictionary(dictionary: query.whereItems).isEqual(to: where_expectation))
    }
    
    func test_where_nearGeoPoint_withinKilometers() {
        let latitude = 35.688499
        let longitude = 139.684026
        let kilometers = 10.0
        let geoPoint = NCMBGeoPoint.init(latitude: latitude, longitude: longitude)
        var query = NCMBQuery.getQuery(className: "Shop")
        query.where(field: "geoPoint", nearGeoPoint: geoPoint, withinKilometers: kilometers)
        
        let where_expectation: [String : Any] = ["geoPoint": ["$maxDistanceInKilometers": kilometers, "$nearSphere": ["__type": "GeoPoint", "latitude": latitude, "longitude": longitude]]]
        XCTAssertTrue(NSDictionary(dictionary: query.whereItems).isEqual(to: where_expectation))
    }
    
    func test_where_nearGeoPoint_withinMiles() {
        let latitude = 35.688499
        let longitude = 139.684026
        let miles = 100.0
        let geoPoint = NCMBGeoPoint.init(latitude: latitude, longitude: longitude)
        var query = NCMBQuery.getQuery(className: "Shop")
        query.where(field: "geoPoint", nearGeoPoint: geoPoint, withinMiles: miles)
        
        let where_expectation: [String : Any] = ["geoPoint": ["$maxDistanceInMiles": miles, "$nearSphere": ["__type": "GeoPoint", "latitude": latitude, "longitude": longitude]]]
        XCTAssertTrue(NSDictionary(dictionary: query.whereItems).isEqual(to: where_expectation))
    }
    
    func test_where_nearGeoPoint_withinRadians() {
        let latitude = 35.688499
        let longitude = 139.684026
        let radians = 180/Double.pi
        let geoPoint = NCMBGeoPoint.init(latitude: latitude, longitude: longitude)
        var query = NCMBQuery.getQuery(className: "Shop")
        query.where(field: "geoPoint", nearGeoPoint: geoPoint, withinRadians: radians)
        
        let where_expectation: [String : Any] = ["geoPoint": ["$maxDistanceInRadians": radians, "$nearSphere": ["__type": "GeoPoint", "latitude": latitude, "longitude": longitude]]]
        XCTAssertTrue(NSDictionary(dictionary: query.whereItems).isEqual(to: where_expectation))
    }
    
    func test_where_within_box() {
        let southwest_lat = 35.688499
        let southwest_lng = 139.684026
        let northeast_lat = 35.695737
        let northeast_lng = 139.687384
        let southwest = NCMBGeoPoint.init(latitude: southwest_lat, longitude: southwest_lng)
        let northeast = NCMBGeoPoint.init(latitude: northeast_lat, longitude: northeast_lng)
        var query = NCMBQuery.getQuery(className: "Shop")
        query.where(field: "geoPoint", withinGeoBoxFromSouthwest: southwest, toNortheast: northeast)
        
        let where_expectation: [String : Any] = ["geoPoint": ["$within": ["$box": [["__type": "GeoPoint", "latitude": southwest_lat, "longitude": southwest_lng], ["__type": "GeoPoint", "latitude": northeast_lat, "longitude": northeast_lng]]]]]
        XCTAssertTrue(NSDictionary(dictionary: query.whereItems).isEqual(to: where_expectation))
    }
    
    func test_relatedTo() {
        var query = NCMBQuery.getQuery(className: "ClassA")
        query.relatedTo(targetClassName: "ClassB", objectId: "fA2UG40Xd09KynDp", key: "Relation")
        
        let where_expectation: [String : Any] = ["$relatedTo": ["object": ["__type": "Pointer", "className": "ClassB", "objectId": "fA2UG40Xd09KynDp"], "key": "Relation"]]
        XCTAssertTrue(NSDictionary(dictionary: query.whereItems).isEqual(to: where_expectation))
    }

    static var allTests = [
        ("test_init_className", test_init_className),
        ("test_init_service", test_init_service),
        ("test_init_all", test_init_all),
        ("test_init_all_default", test_init_all_default),
        ("test_requestItems_default", test_requestItems_default),
        ("test_requestItems_all", test_requestItems_all),
        ("test_convertAnyToString", test_convertAnyToString),
        ("test_query_default", test_query_default),
        ("test_query_all", test_query_all),
        ("test_find_success", test_find_success),
        ("test_find_failure", test_find_failure),
        ("test_findInBackground_success", test_findInBackground_success),
        ("test_findInBackground_failure", test_findInBackground_failure),
        ("test_count_success", test_count_success),
        ("test_count_failure", test_count_failure),
        ("test_countInBackground_success", test_countInBackground_success),
        ("test_countInBackground_failure", test_countInBackground_failure),
        ("test_getResultObjects_ordinal", test_getResultObjects_ordinal),
        ("test_getResultObjects_installation", test_getResultObjects_installation),
        ("test_getResultObjects_invalidMember", test_getResultObjects_invalidMember),
        ("test_getResultObjects_resultsNotExist", test_getResultObjects_resultsNotExist),
        ("test_getResultObjects_invalidResults", test_getResultObjects_invalidResults),
        ("test_getResultCount_ordinal", test_getResultCount_ordinal),
        ("test_getResultCount_countNotExist", test_getResultCount_countNotExist),
        ("test_createCountQuery", test_createCountQuery),
        ("test_addOperation_ordinalType", test_addOperation_ordinalType),
        ("test_addOperation_specialType", test_addOperation_specialType),
        ("test_getFieldItem", test_getFieldItem),
        ("test_convertToObject_ordinalType", test_convertToObject_ordinalType),
        ("test_convertToObject_specialType", test_convertToObject_specialType),
        ("test_where_equalTo", test_where_equalTo),
        ("test_where_notEqualTo", test_where_notEqualTo),
        ("test_where_lessThan", test_where_lessThan),
        ("test_where_greaterThan", test_where_greaterThan),
        ("test_where_lessThanOrEqualTo", test_where_lessThanOrEqualTo),
        ("test_where_greaterThanOrEqualTo", test_where_greaterThanOrEqualTo),
        ("test_where_containedIn", test_where_containedIn),
        ("test_where_notContainedIn", test_where_notContainedIn),
        ("test_where_exists", test_where_exists),
        ("test_where_toMatchPattern", test_where_toMatchPattern),
        ("test_where_containedInArrayTo", test_where_containedInArrayTo),
        ("test_where_notContainedInArrayTo", test_where_notContainedInArrayTo),
        ("test_where_containsAllObjectsInArrayTo", test_where_containsAllObjectsInArrayTo),
        ("test_orQuery_1queries", test_orQuery_1queries),
        ("test_orQuery_2queries", test_orQuery_2queries),
        ("test_orQuery_3queries", test_orQuery_3queries),
        ("test_where_select", test_where_select),
        ("test_where_inQuery", test_where_inQuery),
        ("test_where_nearGeoPoint", test_where_nearGeoPoint),
        ("test_where_nearGeoPoint_withinKilometers", test_where_nearGeoPoint_withinKilometers),
        ("test_where_nearGeoPoint_withinMiles", test_where_nearGeoPoint_withinMiles),
        ("test_where_nearGeoPoint_withinRadians", test_where_nearGeoPoint_withinRadians),
        ("test_relatedTo", test_relatedTo),
    ]
}
