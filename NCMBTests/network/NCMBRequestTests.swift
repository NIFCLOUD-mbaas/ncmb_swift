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
import XCTest
@testable import NCMB
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// NCMBRequest のテストクラスです。
final class NCMBRequestTests: NCMBTestCase {

    func test_getURL_invalid_domain() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "")
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath : ["TestClass", "abcdef01"]) // className/objectId
        XCTAssertThrowsError(try sut.getURL()) { error in
            XCTAssertEqual(error as! NCMBInvalidRequestError, NCMBInvalidRequestError.invalidDomainName)
        }
    }

    func test_getURL_domain_apiversion() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "https://piyo.example.com",
            apiVersion: "1986-02-04")
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"]) // className/objectId
        XCTAssertEqual(try sut.getURL(), URL(string: "https://piyo.example.com/1986-02-04/classes/TestClass/abcdef01"))
    }

    func test_getURL_default() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.get,
                subpath: ["abcdef01"]) // objectId
        XCTAssertEqual(try sut.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/users/abcdef01"))
    }

    func test_getURL_argument_domainURL_apiVersion() {
        let sut : NCMBRequest = NCMBRequest(
                domainURL: "https://piyo.example.com",
                apiVersion: "1986-02-04",
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.get,
                subpath: ["abcdef01"]) // objectId
        XCTAssertEqual(try sut.getURL(), URL(string: "https://piyo.example.com/1986-02-04/users/abcdef01"))
    }

    func test_getURL_noSubpathQuery() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.installations,
                method: NCMBHTTPMethod.get)
        XCTAssertEqual(try sut.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/installations"))
    }

    func test_getURL_subpath() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.get,
                subpath : ["c", "d", "a", "b", "e"])
        // subpath は 配列順に結合される
        XCTAssertEqual(try sut.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/users/c/d/a/b/e"))
    }

    func test_getURL_query_init() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.login,
                method: NCMBHTTPMethod.get,
                queries: ["c":"1", "d":nil, "a":"2", "b":"3", "e":"4"])
        // query はキー名称によりソートされる
        XCTAssertEqual(try sut.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/login?a=2&b=3&c=1&d&e=4"))
    }

    func test_getURL_query_method() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.login,
                method: NCMBHTTPMethod.get)
        sut.addQueryItem(name: "c", value: "1")
        sut.addQueryItem(name: "d", value: nil)
        sut.addQueryItem(name: "a", value: "2")
        sut.addQueryItem(name: "b", value: "3")
        sut.addQueryItem(name: "e", value: "4")
        // query はキー名称によりソートされる
        XCTAssertEqual(try sut.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/login?a=2&b=3&c=1&d&e=4"))
    }

    func test_getURL_queryEncoded() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass"])
        sut.addQueryItem(name: "where", value: "{\"testKey\":\"testValue&\"}")
        XCTAssertEqual(try sut.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/TestClass?where=%7B%22testKey%22:%22testValue%26%22%7D"))
    }

    func test_getURL_subpathQuery() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["abcdef01"])
        sut.addQueryItem(name: "takanokun", value: "takano_san")
        XCTAssertEqual(try sut.getURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/abcdef01?takanokun=takano_san"))
    }

    func test_getSignatureURL_invalid_domain_get() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "")
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath : ["TestClass", "abcdef01"]) // className/objectId
        XCTAssertThrowsError(try sut.getSignatureURL()) { error in
            XCTAssertEqual(error as! NCMBInvalidRequestError, NCMBInvalidRequestError.invalidDomainName)
        }
    }

    func test_getSignatureURL_domain_apiversion_get() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "https://piyo.example.com",
            apiVersion: "1986-02-04")
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"]) // className/objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://piyo.example.com/1986-02-04/classes/TestClass/abcdef01"))
    }

    func test_getSignatureURL_default_get() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.get,
                subpath: ["abcdef01"]) // objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/users/abcdef01"))
    }

    func test_getSignatureURL_argument_domainURL_apiVersion_get() {
        let sut : NCMBRequest = NCMBRequest(
                domainURL: "https://piyo.example.com",
                apiVersion: "1986-02-04",
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.get,
                subpath: ["abcdef01"]) // objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://piyo.example.com/1986-02-04/users/abcdef01"))
    }

    func test_getSignatureURL_noSubpathQuery_get() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.installations,
                method: NCMBHTTPMethod.get)
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/installations"))
    }

    func test_getSignatureURL_subpath_get() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.get,
                subpath : ["c", "d", "a", "b", "e"])
        // subpath は 配列順に結合される
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/users/c/d/a/b/e"))
    }

    func test_getSignatureURL_query_init_get() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.login,
                method: NCMBHTTPMethod.get,
                queries: ["c":"1", "d":nil, "a":"2", "b":"3", "e":"4"])
        // query はキー名称によりソートされる
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/login?a=2&b=3&c=1&d&e=4"))
    }

    func test_getSignatureURL_query_method_get() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.login,
                method: NCMBHTTPMethod.get)
        sut.addQueryItem(name: "c", value: "1")
        sut.addQueryItem(name: "d", value: nil)
        sut.addQueryItem(name: "a", value: "2")
        sut.addQueryItem(name: "b", value: "3")
        sut.addQueryItem(name: "e", value: "4")
        // query はキー名称によりソートされる
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/login?a=2&b=3&c=1&d&e=4"))
    }

    func test_getSignatureURL_queryEncoded_get() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass"])
        sut.addQueryItem(name: "where", value: "{\"testKey\":\"testValue&\"}")
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/TestClass?where=%7B%22testKey%22:%22testValue%26%22%7D"))
    }

    func test_getSignatureURL_subpathQuery_get() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["abcdef01"])
        sut.addQueryItem(name: "takanokun", value: "takano_san")
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/abcdef01?takanokun=takano_san"))
    }

    func test_getSignatureURL_invalid_domain_post() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "")
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.post,
                subpath : ["TestClass", "abcdef01"]) // className/objectId
        XCTAssertThrowsError(try sut.getSignatureURL()) { error in
            XCTAssertEqual(error as! NCMBInvalidRequestError, NCMBInvalidRequestError.invalidDomainName)
        }
    }

    func test_getSignatureURL_domain_apiversion_post() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "https://piyo.example.com",
            apiVersion: "1986-02-04")
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.post,
                subpath: ["TestClass", "abcdef01"]) // className/objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://piyo.example.com/1986-02-04/classes/TestClass/abcdef01"))
    }

    func test_getSignatureURL_default_post() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.post,
                subpath: ["abcdef01"]) // objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/users/abcdef01"))
    }

    func test_getSignatureURL_argument_domainURL_apiVersion_post() {
        let sut : NCMBRequest = NCMBRequest(
                domainURL: "https://piyo.example.com",
                apiVersion: "1986-02-04",
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.post,
                subpath: ["abcdef01"]) // objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://piyo.example.com/1986-02-04/users/abcdef01"))
    }

    func test_getSignatureURL_noSubpathQuery_post() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.installations,
                method: NCMBHTTPMethod.post)
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/installations"))
    }

    func test_getSignatureURL_subpath_post() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.post,
                subpath : ["c", "d", "a", "b", "e"])
        // subpath は 配列順に結合される
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/users/c/d/a/b/e"))
    }

    func test_getSignatureURL_query_init_post() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.login,
                method: NCMBHTTPMethod.post,
                queries: ["c":"1", "d":nil, "a":"2", "b":"3", "e":"4"])
        // query はキー名称によりソートされる
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/login"))
    }

    func test_getSignatureURL_query_method_post() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.login,
                method: NCMBHTTPMethod.post)
        sut.addQueryItem(name: "c", value: "1")
        sut.addQueryItem(name: "d", value: nil)
        sut.addQueryItem(name: "a", value: "2")
        sut.addQueryItem(name: "b", value: "3")
        sut.addQueryItem(name: "e", value: "4")
        // query はキー名称によりソートされる
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/login"))
    }

    func test_getSignatureURL_queryEncoded_post() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.post,
                subpath: ["TestClass"])
        sut.addQueryItem(name: "where", value: "{\"testKey\":\"testValue&\"}")
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/TestClass"))
    }

    func test_getSignatureURL_subpathQuery_post() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.post,
                subpath: ["abcdef01"])
        sut.addQueryItem(name: "takanokun", value: "takano_san")
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/abcdef01"))
    }

    func test_getSignatureURL_invalid_domain_put() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "")
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.put,
                subpath : ["TestClass", "abcdef01"]) // className/objectId
        XCTAssertThrowsError(try sut.getSignatureURL()) { error in
            XCTAssertEqual(error as! NCMBInvalidRequestError, NCMBInvalidRequestError.invalidDomainName)
        }
    }

    func test_getSignatureURL_domain_apiversion_put() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "https://piyo.example.com",
            apiVersion: "1986-02-04")
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.put,
                subpath: ["TestClass", "abcdef01"]) // className/objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://piyo.example.com/1986-02-04/classes/TestClass/abcdef01"))
    }

    func test_getSignatureURL_default_put() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.put,
                subpath: ["abcdef01"]) // objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/users/abcdef01"))
    }

    func test_getSignatureURL_argument_domainURL_apiVersion_put() {
        let sut : NCMBRequest = NCMBRequest(
                domainURL: "https://piyo.example.com",
                apiVersion: "1986-02-04",
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.put,
                subpath: ["abcdef01"]) // objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://piyo.example.com/1986-02-04/users/abcdef01"))
    }

    func test_getSignatureURL_noSubpathQuery_put() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.installations,
                method: NCMBHTTPMethod.put)
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/installations"))
    }

    func test_getSignatureURL_subpath_put() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.put,
                subpath : ["c", "d", "a", "b", "e"])
        // subpath は 配列順に結合される
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/users/c/d/a/b/e"))
    }

    func test_getSignatureURL_query_init_put() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.login,
                method: NCMBHTTPMethod.put,
                queries: ["c":"1", "d":nil, "a":"2", "b":"3", "e":"4"])
        // query はキー名称によりソートされる
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/login"))
    }

    func test_getSignatureURL_query_method_put() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.login,
                method: NCMBHTTPMethod.put)
        sut.addQueryItem(name: "c", value: "1")
        sut.addQueryItem(name: "d", value: nil)
        sut.addQueryItem(name: "a", value: "2")
        sut.addQueryItem(name: "b", value: "3")
        sut.addQueryItem(name: "e", value: "4")
        // query はキー名称によりソートされる
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/login"))
    }

    func test_getSignatureURL_queryEncoded_put() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.put,
                subpath: ["TestClass"])
        sut.addQueryItem(name: "where", value: "{\"testKey\":\"testValue&\"}")
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/TestClass"))
    }

    func test_getSignatureURL_subpathQuery_put() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.put,
                subpath: ["abcdef01"])
        sut.addQueryItem(name: "takanokun", value: "takano_san")
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/abcdef01"))
    }

    func test_getSignatureURL_invalid_domain_delete() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "")
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.delete,
                subpath : ["TestClass", "abcdef01"]) // className/objectId
        XCTAssertThrowsError(try sut.getSignatureURL()) { error in
            XCTAssertEqual(error as! NCMBInvalidRequestError, NCMBInvalidRequestError.invalidDomainName)
        }
    }

    func test_getSignatureURL_domain_apiversion_delete() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "https://piyo.example.com",
            apiVersion: "1986-02-04")
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.delete,
                subpath: ["TestClass", "abcdef01"]) // className/objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://piyo.example.com/1986-02-04/classes/TestClass/abcdef01"))
    }

    func test_getSignatureURL_default_delete() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.delete,
                subpath: ["abcdef01"]) // objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/users/abcdef01"))
    }

    func test_getSignatureURL_argument_domainURL_apiVersion_delete() {
        let sut : NCMBRequest = NCMBRequest(
                domainURL: "https://piyo.example.com",
                apiVersion: "1986-02-04",
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.delete,
                subpath: ["abcdef01"]) // objectId
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://piyo.example.com/1986-02-04/users/abcdef01"))
    }

    func test_getSignatureURL_noSubpathQuery_delete() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.installations,
                method: NCMBHTTPMethod.delete)
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/installations"))
    }

    func test_getSignatureURL_subpath_delete() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.delete,
                subpath : ["c", "d", "a", "b", "e"])
        // subpath は 配列順に結合される
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/users/c/d/a/b/e"))
    }

    func test_getSignatureURL_query_init_delete() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.login,
                method: NCMBHTTPMethod.delete,
                queries: ["c":"1", "d":nil, "a":"2", "b":"3", "e":"4"])
        // query はキー名称によりソートされる
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/login"))
    }

    func test_getSignatureURL_query_method_delete() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.login,
                method: NCMBHTTPMethod.delete)
        sut.addQueryItem(name: "c", value: "1")
        sut.addQueryItem(name: "d", value: nil)
        sut.addQueryItem(name: "a", value: "2")
        sut.addQueryItem(name: "b", value: "3")
        sut.addQueryItem(name: "e", value: "4")
        // query はキー名称によりソートされる
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/login"))
    }

    func test_getSignatureURL_queryEncoded_delete() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.delete,
                subpath: ["TestClass"])
        sut.addQueryItem(name: "where", value: "{\"testKey\":\"testValue&\"}")
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/TestClass"))
    }

    func test_getSignatureURL_subpathQuery_delete() {
        var sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.delete,
                subpath: ["abcdef01"])
        sut.addQueryItem(name: "takanokun", value: "takano_san")
        XCTAssertEqual(try sut.getSignatureURL(), URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/classes/abcdef01"))
    }

    func test_build_invalid_domain() {
        NCMB.initialize(
            applicationKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            clientKey: "1111111111111111111111111111111111111111111111111111111111111111",
            domainURL: "")
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                subpath: ["TestClass", "abcdef01"])
        XCTAssertThrowsError(try sut.build()) { error in
            XCTAssertEqual(error as! NCMBInvalidRequestError, NCMBInvalidRequestError.invalidDomainName)
        }
    }

    func test_build_all_arguments_get() {
        let sut : NCMBRequest = NCMBRequest(
                domainURL: "https://piyo.example.com",
                apiVersion: "1986-02-04",
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.get,
                date: Date(timeIntervalSince1970: 507904496.789),
                subpath: ["TestClass", "abcdef01"],
                headers: ["X-NCMB-TEST1":"VALUE1", "X-NCMB-TEST2":"VALUE2"],
                queries: ["p":"q", "s":nil, "r":"t"],
                contentType: "plain/text_Vol2",
                body: "{\"takanokun\":\"takano_san\"}".data(using: .utf8)!)
        let urlRequest : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.url, URL(string: "https://piyo.example.com/1986-02-04/classes/TestClass/abcdef01?p=q&r=t&s"))
        XCTAssertEqual(urlRequest.httpBody, "{\"takanokun\":\"takano_san\"}".data(using: .utf8)!)
        XCTAssertEqual(urlRequest.httpBodyStream, nil)
        XCTAssertEqual(urlRequest.mainDocumentURL, nil)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!.count, 8)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"Content-Type")!, "plain/text_Vol2")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Application-Key")!, "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Timestamp")!, "1986-02-04T12:34:56.789Z")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Signature")!, "Gr/jVnob8/fucYAUwW8fXEVllonyDH1NMirCUHgoYZU=")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Apps-Session-Token"), nil)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-SDK-Version"), "swift-1.1.2")
        XCTAssertNotNil(urlRequest.value(forHTTPHeaderField:"X-NCMB-OS-Version"))
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-TEST1"), "VALUE1")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-TEST2"), "VALUE2")
    }

    func test_build_all_arguments_post() {
        let sut : NCMBRequest = NCMBRequest(
                domainURL: "https://piyo.example.com",
                apiVersion: "1986-02-04",
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.post,
                date: Date(timeIntervalSince1970: 507904496.789),
                subpath: ["TestClass", "abcdef01"],
                headers: ["X-NCMB-TEST1":"VALUE1", "X-NCMB-TEST2":"VALUE2"],
                queries: ["p":"q", "s":nil, "r":"t"],
                contentType: "plain/text_Vol2",
                body: "{\"takanokun\":\"takano_san\"}".data(using: .utf8)!)
        let urlRequest : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.url, URL(string: "https://piyo.example.com/1986-02-04/classes/TestClass/abcdef01?p=q&r=t&s"))
        XCTAssertEqual(urlRequest.httpBody, "{\"takanokun\":\"takano_san\"}".data(using: .utf8)!)
        XCTAssertEqual(urlRequest.httpBodyStream, nil)
        XCTAssertEqual(urlRequest.mainDocumentURL, nil)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!.count, 8)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"Content-Type")!, "plain/text_Vol2")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Application-Key")!, "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Timestamp")!, "1986-02-04T12:34:56.789Z")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Signature")!, "ArT9YDP4fyy8gDxTm65k5uPkXxDjP5LquDNS76cSZqk=")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Apps-Session-Token"), nil)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-SDK-Version"), "swift-1.1.2")
        XCTAssertNotNil(urlRequest.value(forHTTPHeaderField:"X-NCMB-OS-Version"))
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-TEST1"), "VALUE1")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-TEST2"), "VALUE2")
    }

    func test_build_all_arguments_put() {
        let sut : NCMBRequest = NCMBRequest(
                domainURL: "https://piyo.example.com",
                apiVersion: "1986-02-04",
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.put,
                date: Date(timeIntervalSince1970: 507904496.789),
                subpath: ["TestClass", "abcdef01"],
                headers: ["X-NCMB-TEST1":"VALUE1", "X-NCMB-TEST2":"VALUE2"],
                queries: ["p":"q", "s":nil, "r":"t"],
                contentType: "plain/text_Vol2",
                body: "{\"takanokun\":\"takano_san\"}".data(using: .utf8)!)
        let urlRequest : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest.httpMethod, "PUT")
        XCTAssertEqual(urlRequest.url, URL(string: "https://piyo.example.com/1986-02-04/classes/TestClass/abcdef01?p=q&r=t&s"))
        XCTAssertEqual(urlRequest.httpBody, "{\"takanokun\":\"takano_san\"}".data(using: .utf8)!)
        XCTAssertEqual(urlRequest.httpBodyStream, nil)
        XCTAssertEqual(urlRequest.mainDocumentURL, nil)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!.count, 8)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"Content-Type")!, "plain/text_Vol2")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Application-Key")!, "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Timestamp")!, "1986-02-04T12:34:56.789Z")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Signature")!, "2cXESZFIx0Zed+XiKrf+VJjvo2/uxuRDw/J3sjqXogI=")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Apps-Session-Token"), nil)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-SDK-Version"), "swift-1.1.2")
        XCTAssertNotNil(urlRequest.value(forHTTPHeaderField:"X-NCMB-OS-Version"))
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-TEST1"), "VALUE1")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-TEST2"), "VALUE2")
    }

    func test_build_all_arguments_delete() {
        let sut : NCMBRequest = NCMBRequest(
                domainURL: "https://piyo.example.com",
                apiVersion: "1986-02-04",
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.delete,
                date: Date(timeIntervalSince1970: 507904496.789),
                subpath: ["TestClass", "abcdef01"],
                headers: ["X-NCMB-TEST1":"VALUE1", "X-NCMB-TEST2":"VALUE2"],
                queries: ["p":"q", "s":nil, "r":"t"],
                contentType: "plain/text_Vol2",
                body: "{\"takanokun\":\"takano_san\"}".data(using: .utf8)!)
        let urlRequest : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest.httpMethod, "DELETE")
        XCTAssertEqual(urlRequest.url, URL(string: "https://piyo.example.com/1986-02-04/classes/TestClass/abcdef01?p=q&r=t&s"))
        XCTAssertEqual(urlRequest.httpBody, "{\"takanokun\":\"takano_san\"}".data(using: .utf8)!)
        XCTAssertEqual(urlRequest.httpBodyStream, nil)
        XCTAssertEqual(urlRequest.mainDocumentURL, nil)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!.count, 8)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"Content-Type")!, "plain/text_Vol2")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Application-Key")!, "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Timestamp")!, "1986-02-04T12:34:56.789Z")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Signature")!, "873rompizKVX/dxhRLtcrBlOtRO/q1NeEvwYl8qEj/c=")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-Apps-Session-Token"), nil)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-SDK-Version"), "swift-1.1.2")
        XCTAssertNotNil(urlRequest.value(forHTTPHeaderField:"X-NCMB-OS-Version"))
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-TEST1"), "VALUE1")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"X-NCMB-TEST2"), "VALUE2")
    }

    func test_build_default() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.users,
                method: NCMBHTTPMethod.put,
                subpath: ["abcdef01"])
        let urlRequest : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest.httpMethod, "PUT")
        XCTAssertEqual(urlRequest.url, URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/users/abcdef01"))
        XCTAssertEqual(urlRequest.httpBody, nil)
        XCTAssertEqual(urlRequest.httpBodyStream, nil)
        XCTAssertEqual(urlRequest.mainDocumentURL, nil)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!.count, 6)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type")!, "application/json")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-NCMB-Application-Key")!, "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
        XCTAssertNotNil(urlRequest.value(forHTTPHeaderField: "X-NCMB-Timestamp"))
        XCTAssertNotNil(urlRequest.value(forHTTPHeaderField: "X-NCMB-Signature"))
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-NCMB-Apps-Session-Token"), nil)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-NCMB-SDK-Version"), "swift-1.1.2")
        XCTAssertNotNil(urlRequest.value(forHTTPHeaderField: "X-NCMB-OS-Version"))
    }

    func test_contentType_default() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.post,
                subpath: [])
        let urlRequest : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type")!, "application/json")
    }

    func test_contentType_isNothing() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.post,
                subpath: [],
                contentType: nil)
        let urlRequest : URLRequest = try! sut.build()
        XCTAssertNil(urlRequest.value(forHTTPHeaderField:"Content-Type"))
    }

    func test_contentType_customize() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.post,
                subpath: [],
                contentType: "takanokun")
        let urlRequest : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField:"Content-Type")!, "takanokun")
    }

    func test_timeoutInterval_default() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.post,
                subpath: [])
        let urlRequest : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest.timeoutInterval, 10.0)
    }

    func test_timeoutInterval_customize() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.post,
                subpath: [],
                timeoutInterval: 42.0)
        let urlRequest : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest.timeoutInterval, 42.0)
    }

    func test_sessionToken() {
        let sut : NCMBRequest = NCMBRequest(
                apiType: NCMBApiType.classes,
                method: NCMBHTTPMethod.post,
                subpath: [])

        // ログインしていない状態ではセッショントークンが付与されない
        let urlRequest1 : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest1.value(forHTTPHeaderField:"X-NCMB-Apps-Session-Token"), nil)

        let loginApiResponse : NCMBResponse = MockResponseBuilder.createResponse(contents: ["sessionToken":"abcdefg1233445678"], statusCode : 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(loginApiResponse)))

        _ = NCMBUser.logIn(userName: "takanokun", password: "testpswd")

        // ログインするとセッショントークンが付与される
        let urlRequest2 : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest2.value(forHTTPHeaderField:"X-NCMB-Apps-Session-Token"), "abcdefg1233445678")

        let logoutApiResponse : NCMBResponse = MockResponseBuilder.createResponse(contents: [:], statusCode : 200)
        NCMBRequestExecutorFactory.setInstance(executor: MockRequestExecutor(result: .success(logoutApiResponse)))

        _ = NCMBUser.logOut()

        // ログアウトするとセッショントークンが付与されない
        let urlRequest3 : URLRequest = try! sut.build()
        XCTAssertEqual(urlRequest3.value(forHTTPHeaderField:"X-NCMB-Apps-Session-Token"), nil)
    }


    static var allTests = [
        ("test_getURL_invalid_domain", test_getURL_invalid_domain),
        ("test_getURL_domain_apiversion", test_getURL_domain_apiversion),
        ("test_getURL_default", test_getURL_default),
        ("test_getURL_argument_domainURL_apiVersion", test_getURL_argument_domainURL_apiVersion),
        ("test_getURL_noSubpathQuery", test_getURL_noSubpathQuery),
        ("test_getURL_subpath", test_getURL_subpath),
        ("test_getURL_query_init", test_getURL_query_init),
        ("test_getURL_query_method", test_getURL_query_method),
        ("test_getURL_queryEncoded", test_getURL_queryEncoded),
        ("test_getURL_subpathQuery", test_getURL_subpathQuery),
        ("test_getSignatureURL_invalid_domain_get", test_getSignatureURL_invalid_domain_get),
        ("test_getSignatureURL_domain_apiversion_get", test_getSignatureURL_domain_apiversion_get),
        ("test_getSignatureURL_default_get", test_getSignatureURL_default_get),
        ("test_getSignatureURL_argument_domainURL_apiVersion_get", test_getSignatureURL_argument_domainURL_apiVersion_get),
        ("test_getSignatureURL_noSubpathQuery_get", test_getSignatureURL_noSubpathQuery_get),
        ("test_getSignatureURL_subpath_get", test_getSignatureURL_subpath_get),
        ("test_getSignatureURL_query_init_get", test_getSignatureURL_query_init_get),
        ("test_getSignatureURL_query_method_get", test_getSignatureURL_query_method_get),
        ("test_getSignatureURL_queryEncoded_get", test_getSignatureURL_queryEncoded_get),
        ("test_getSignatureURL_subpathQuery_get", test_getSignatureURL_subpathQuery_get),
        ("test_getSignatureURL_invalid_domain_post", test_getSignatureURL_invalid_domain_post),
        ("test_getSignatureURL_domain_apiversion_post", test_getSignatureURL_domain_apiversion_post),
        ("test_getSignatureURL_default_post", test_getSignatureURL_default_post),
        ("test_getSignatureURL_argument_domainURL_apiVersion_post", test_getSignatureURL_argument_domainURL_apiVersion_post),
        ("test_getSignatureURL_noSubpathQuery_post", test_getSignatureURL_noSubpathQuery_post),
        ("test_getSignatureURL_subpath_post", test_getSignatureURL_subpath_post),
        ("test_getSignatureURL_query_init_post", test_getSignatureURL_query_init_post),
        ("test_getSignatureURL_query_method_post", test_getSignatureURL_query_method_post),
        ("test_getSignatureURL_queryEncoded_post", test_getSignatureURL_queryEncoded_post),
        ("test_getSignatureURL_subpathQuery_post", test_getSignatureURL_subpathQuery_post),
        ("test_getSignatureURL_invalid_domain_put", test_getSignatureURL_invalid_domain_put),
        ("test_getSignatureURL_domain_apiversion_put", test_getSignatureURL_domain_apiversion_put),
        ("test_getSignatureURL_default_put", test_getSignatureURL_default_put),
        ("test_getSignatureURL_argument_domainURL_apiVersion_put", test_getSignatureURL_argument_domainURL_apiVersion_put),
        ("test_getSignatureURL_noSubpathQuery_put", test_getSignatureURL_noSubpathQuery_put),
        ("test_getSignatureURL_subpath_put", test_getSignatureURL_subpath_put),
        ("test_getSignatureURL_query_init_put", test_getSignatureURL_query_init_put),
        ("test_getSignatureURL_query_method_put", test_getSignatureURL_query_method_put),
        ("test_getSignatureURL_queryEncoded_put", test_getSignatureURL_queryEncoded_put),
        ("test_getSignatureURL_subpathQuery_put", test_getSignatureURL_subpathQuery_put),
        ("test_getSignatureURL_invalid_domain_delete", test_getSignatureURL_invalid_domain_delete),
        ("test_getSignatureURL_domain_apiversion_delete", test_getSignatureURL_domain_apiversion_delete),
        ("test_getSignatureURL_default_delete", test_getSignatureURL_default_delete),
        ("test_getSignatureURL_argument_domainURL_apiVersion_delete", test_getSignatureURL_argument_domainURL_apiVersion_delete),
        ("test_getSignatureURL_noSubpathQuery_delete", test_getSignatureURL_noSubpathQuery_delete),
        ("test_getSignatureURL_subpath_delete", test_getSignatureURL_subpath_delete),
        ("test_getSignatureURL_query_init_delete", test_getSignatureURL_query_init_delete),
        ("test_getSignatureURL_query_method_delete", test_getSignatureURL_query_method_delete),
        ("test_getSignatureURL_queryEncoded_delete", test_getSignatureURL_queryEncoded_delete),
        ("test_getSignatureURL_subpathQuery_delete", test_getSignatureURL_subpathQuery_delete),
        ("test_build_invalid_domain", test_build_invalid_domain),
        ("test_build_all_arguments_get", test_build_all_arguments_get),
        ("test_build_all_arguments_post", test_build_all_arguments_post),
        ("test_build_all_arguments_put", test_build_all_arguments_put),
        ("test_build_all_arguments_delete", test_build_all_arguments_delete),
        ("test_build_default", test_build_default),
        ("test_contentType_default", test_contentType_default),
        ("test_contentType_isNothing", test_contentType_isNothing),
        ("test_contentType_customize", test_contentType_customize),
        ("test_timeoutInterval_default", test_timeoutInterval_default),
        ("test_timeoutInterval_customize", test_timeoutInterval_customize),
        ("test_sessionToken", test_sessionToken),
    ]
}
