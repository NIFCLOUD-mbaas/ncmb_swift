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

/// NCMBResponse のテストクラスです。
final class NCMBResponseTests: NCMBTestCase {

    func test_init_normal() {
        let body : Data? = "{\"takanokun\" : \"takano_san\"}".data(using: .utf8)!
        var header : [String : String] = [:]
        header["key1"] = "value1"
        header["key2"] = "value2"
        header["key3"] = "value3"
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: header)!
        XCTAssertNoThrow(try NCMBResponse(body: body, response: response))
    }

    func test_init_normal_include_nil() {
        let body : Data? = "{\"objectId\":\"09Mp23m4bEOInUqT\",\"userName\":\"user01\",\"mailAddress\":null,\"mailAddressConfirm\":null,\"sessionToken\":\"ebDH8TtmLoygzjqjaI4EWFfxc\",\"createDate\":\"2013-08-28T07:46:09.801Z\",\"updateDate\":\"2013-08-30T05:32:03.868Z\"}".data(using: .utf8)!
        var header : [String : String] = [:]
        header["key1"] = "value1"
        header["key2"] = "value2"
        header["key3"] = "value3"
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: header)!
        let sut : NCMBResponse = try! NCMBResponse(body: body, response: response)
        XCTAssertEqual(sut.contents.count, 7)
        XCTAssertEqual(sut.contents["objectId"] as! String, "09Mp23m4bEOInUqT")
        XCTAssertNil(sut.contents["mailAddrss"])
    }

    func test_init_invalidBody() {
        let body : Data? = "[\"takanokun\", \"takano_san\"]".data(using: .utf8)!
        var header : [String : String] = [:]
        header["key1"] = "value1"
        header["key2"] = "value2"
        header["key3"] = "value3"
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: header)!
        var sut : NCMBResponse
        sut = try! NCMBResponse(body: body, response: response)
        XCTAssertEqual(sut.contents.count, 0)
    }

    func test_init_invalidResponse() {
        let body : Data? = "{\"takanokun\":\"takano_san\"}".data(using: .utf8)!
        let invalidUrlReasponse = NotHTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                mimeType: "application/json",
                expectedContentLength: 1024,
                textEncodingName: "utf-8")
        XCTAssertThrowsError(try NCMBResponse(body: body, response: invalidUrlReasponse)) { error in
            XCTAssertEqual(error as! NCMBParseError, NCMBParseError.unsupportResponseHeader)
        }
    }

    func test_isError_code100() {
        let body : Data? = "{}".data(using: .utf8)!
        let header : [String : String] = [:]
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 100,
                httpVersion: nil,
                headerFields: header)!
        let sut = try! NCMBResponse(body: body, response: response)
        XCTAssertEqual(sut.isError, true)
    }

    func test_isError_code199() {
        let body : Data? = "{}".data(using: .utf8)!
        let header : [String : String] = [:]
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 199,
                httpVersion: nil,
                headerFields: header)!
        let sut = try! NCMBResponse(body: body, response: response)
        XCTAssertEqual(sut.isError, true)
    }

    func test_isError_code200() {
        let body : Data? = "{}".data(using: .utf8)!
        let header : [String : String] = [:]
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: header)!
        let sut = try! NCMBResponse(body: body, response: response)
        XCTAssertEqual(sut.isError, false)
    }

    func test_isError_code299() {
        let body : Data? = "{}".data(using: .utf8)!
        let header : [String : String] = [:]
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 299,
                httpVersion: nil,
                headerFields: header)!
        let sut = try! NCMBResponse(body: body, response: response)
        XCTAssertEqual(sut.isError, false)
    }

    func test_isError_code300() {
        let body : Data? = "{}".data(using: .utf8)!
        let header : [String : String] = [:]
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 300,
                httpVersion: nil,
                headerFields: header)!
        let sut = try! NCMBResponse(body: body, response: response)
        XCTAssertEqual(sut.isError, true)
    }

    func test_isError_code401() {
        let body : Data? = "{}".data(using: .utf8)!
        let header : [String : String] = [:]
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: header)!
        let sut = try! NCMBResponse(body: body, response: response)
        XCTAssertEqual(sut.isError, true)
    }

    func test_isError_code503() {
        let body : Data? = "{}".data(using: .utf8)!
        let header : [String : String] = [:]
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 503,
                httpVersion: nil,
                headerFields: header)!
        let sut = try! NCMBResponse(body: body, response: response)
        XCTAssertEqual(sut.isError, true)
    }

    func test_apiError_statusCodeIsNotError() {
        let body : Data? = "{\"code\":\"E404002\",\"error\":\"None service.\"}".data(using: .utf8)!
        let header : [String : String] = [:]
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: header)!
        let sut = try! NCMBResponse(body: body, response: response)
        XCTAssertNil(sut.apiError)
    }

    func test_apiError_statusCodeIsError() {
        let body : Data? = "{\"code\":\"E404002\",\"error\":\"None service.\"}".data(using: .utf8)!
        let header : [String : String] = [:]
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 503,
                httpVersion: nil,
                headerFields: header)!
        let sut = try! NCMBResponse(body: body, response: response)
        XCTAssertEqual(sut.apiError!.errorCode, NCMBApiErrorCode.noneService)
        XCTAssertEqual(sut.apiError!.message, "None service.")
    }

    func test_apiError_emptyBody() {
        let body : Data? = "{}".data(using: .utf8)!
        let header : [String : String] = [:]
        let response = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 503,
                httpVersion: nil,
                headerFields: header)!
        let sut = try! NCMBResponse(body: body, response: response)
        XCTAssertEqual(sut.apiError!.errorCode, NCMBApiErrorCode.genericError)
        XCTAssertEqual(sut.apiError!.message, "")
    }

    func test_convertHTTPURLResponse_nil() {
        XCTAssertThrowsError(try NCMBResponse.convertHTTPURLResponse(response: nil)) { error in
            XCTAssertEqual(error as! NCMBParseError, NCMBParseError.unsupportResponseHeader)
        }
    }

    func test_convertHTTPURLResponse_invalidType() {
        let invalidUrlResponse = NotHTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                mimeType: "application/json",
                expectedContentLength: 1024,
                textEncodingName : "utf-8")
        XCTAssertThrowsError(try NCMBResponse.convertHTTPURLResponse(response: invalidUrlResponse)) { error in
            XCTAssertEqual(error as! NCMBParseError, NCMBParseError.unsupportResponseHeader)
        }
    }

    func test_convertHTTPURLResponse_normal() {
        var header : [String : String] = [:]
        header["key1"] = "value1"
        header["key2"] = "value2"
        header["key3"] = "value3"
        let orig = HTTPURLResponse(
                url: URL(string: "https://takanokun.takano_san.example.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: header)!
        let result = try! NCMBResponse.convertHTTPURLResponse(response: orig)
        XCTAssertEqual(result, orig)
    }

    static var allTests = [
        ("test_init_normal", test_init_normal),
        ("test_init_normal_include_nil", test_init_normal_include_nil),
        ("test_init_invalidBody", test_init_invalidBody),
        ("test_init_invalidResponse", test_init_invalidResponse),
        ("test_isError_code100", test_isError_code100),
        ("test_isError_code199", test_isError_code199),
        ("test_isError_code200", test_isError_code200),
        ("test_isError_code299", test_isError_code299),
        ("test_isError_code300", test_isError_code300),
        ("test_isError_code401", test_isError_code401),
        ("test_isError_code503", test_isError_code503),
        ("test_apiError_statusCodeIsNotError", test_apiError_statusCodeIsNotError),
        ("test_apiError_statusCodeIsError", test_apiError_statusCodeIsError),
        ("test_apiError_emptyBody", test_apiError_emptyBody),
        ("test_convertHTTPURLResponse_nil", test_convertHTTPURLResponse_nil),
        ("test_convertHTTPURLResponse_invalidType", test_convertHTTPURLResponse_invalidType),
        ("test_convertHTTPURLResponse_normal", test_convertHTTPURLResponse_normal),
    ]

    private class NotHTTPURLResponse : URLResponse {
    }
}
