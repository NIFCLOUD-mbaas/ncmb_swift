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
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct NCMBRequest {

    static let APP_KEY_FIELD : String = "X-NCMB-Application-Key"
    static let TIMESTAMP_FIELD : String = "X-NCMB-Timestamp"
    static let SIGNATURE_FIELD : String = "X-NCMB-Signature"
    static let SESSION_TOKEN_FIELD : String = "X-NCMB-Apps-Session-Token"
    static let SDK_VERSION_FIELD : String = "X-NCMB-SDK-Version"
    static let OS_VERSION_FIELD : String = "X-NCMB-OS-Version"
    static let CONTENT_TYPE_FIELD : String = "Content-Type"
    static let CONTENT_LENGTH_FIELD : String = "Content-Length"
    static let DEFAULT_CONTENT_TYPE : String = "application/json"
    static let DEFAULT_REQUEST_TIMEINTERVAL : TimeInterval = 10.0

    var domainURL : String
    var apiVersion : String
    var apiType : NCMBApiType
    var method : NCMBHTTPMethod
    var date : Date
    var subpathItems : [String]
    var headerItems : [String : String?]
    var queryItems : [String : String?]
    var contentType : String?
    var contentLength : Int?
    var body : Data?
    var timeoutInterval : TimeInterval

    init(
            domainURL: String = NCMB.domainURL,
            apiVersion: String = NCMB.apiVersion,
            apiType: NCMBApiType,
            method: NCMBHTTPMethod,
            date: Date = Date(),
            subpath: [String] = [],
            headers: [String : String?] = [:],
            queries: [String : String?] = [:],
            contentType: String? = NCMBRequest.DEFAULT_CONTENT_TYPE,
            contentLength: Int? = nil,
            body: Data? = nil,
            timeoutInterval: TimeInterval = NCMBRequest.DEFAULT_REQUEST_TIMEINTERVAL) {
        self.domainURL = domainURL
        self.apiVersion = apiVersion
        self.apiType = apiType
        self.method = method
        self.date = date
        self.subpathItems = subpath
        self.queryItems = queries
        self.headerItems = headers
        self.contentType = contentType
        self.contentLength = contentLength
        self.body = body
        self.timeoutInterval = timeoutInterval
    }

    mutating func addQueryItem(name: String, value: String?) {
        self.queryItems[name] = value
    }

    func build() throws -> URLRequest {
        do {
            let url = try getURL()
            let signatureUrl = try getSignatureURL()
            let timestamp : String = NCMBDateFormatter.getISO8601Timestamp(date: date)
            let signature : String = try NCMBSignatureCalculator.calculate(method: method, date: date, url: signatureUrl)
            var request : URLRequest = URLRequest(url: url)
            request.timeoutInterval = self.timeoutInterval
            for item in self.headerItems {
                request.setValue(item.value, forHTTPHeaderField: item.key)
            }
            request.setValue(NCMB.applicationKey, forHTTPHeaderField: NCMBRequest.APP_KEY_FIELD)
            request.setValue(timestamp, forHTTPHeaderField: NCMBRequest.TIMESTAMP_FIELD)
            request.setValue(signature, forHTTPHeaderField: NCMBRequest.SIGNATURE_FIELD)
            if let sessionToken : String = NCMBUser.currentUserSessionToken {
                request.setValue(sessionToken, forHTTPHeaderField: NCMBRequest.SESSION_TOKEN_FIELD)
            }
            request.setValue("swift-" + NCMB.SDK_VERSION, forHTTPHeaderField: NCMBRequest.SDK_VERSION_FIELD)
            request.setValue(NCMBDeviceSystem.osVersion, forHTTPHeaderField: NCMBRequest.OS_VERSION_FIELD)
            if let contentType : String = self.contentType {
                request.setValue(contentType, forHTTPHeaderField: NCMBRequest.CONTENT_TYPE_FIELD)
            }
            if let contentLength : Int = self.contentLength {
                request.setValue(String(contentLength), forHTTPHeaderField: NCMBRequest.CONTENT_LENGTH_FIELD)
            }
            request.httpMethod = method.rawValue
            if self.body != nil {
                request.httpBody = self.body
            }
            return request
        } catch let error {
            throw error
        }
    }

    func getURL() throws -> URL {
        var url : URL

        if let domainURL : URL = URL(string: self.domainURL) {
            url = domainURL
        } else {
            throw NCMBInvalidRequestError.invalidDomainName
        }
        url.appendPathComponent(self.apiVersion, isDirectory: true)
        url.appendPathComponent(self.apiType.rawValue, isDirectory: false)
        for item in self.subpathItems {
            url.appendPathComponent(item, isDirectory: false)
        }
        do {
            url = try getURLwithQuery(url: url)
        } catch let error {
            throw error
        }
        return url
    }

    func getSignatureURL() throws -> URL {
        var url : URL

        if let domainURL : URL = URL(string: self.domainURL) {
            url = domainURL
        } else {
            throw NCMBInvalidRequestError.invalidDomainName
        }
        url.appendPathComponent(self.apiVersion, isDirectory: true)
        url.appendPathComponent(self.apiType.rawValue, isDirectory: false)
        for item in self.subpathItems {
            url.appendPathComponent(item, isDirectory: false)
        }
        do {
            if self.method == .get {
                url = try getURLwithQuery(url: url)
            }
        } catch let error {
            throw error
        }
        return url
    }

    private func getURLwithQuery(url: URL) throws -> URL {
        if self.queryItems.count == 0 {
            return url
        }
        if let urlComponents : URLComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            var urlComponents = urlComponents
            urlComponents.queryItems = getSortedQueryItems()
            // percent-encoded for '+' char.
            urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            if let urlWithQuery = urlComponents.url {
                return urlWithQuery
            } else {
                throw NCMBInvalidRequestError.invalidDomainName
            }
        } else {
            throw NCMBInvalidRequestError.invalidDomainName
        }
    }

    private func getSortedQueryItems() -> [URLQueryItem] {
        if self.queryItems.count == 0 {
            return []
        }
        var sortedQueryItems : [URLQueryItem] = []
        for element in self.queryItems.sorted(by: {(a, b) in return a.key < b.key }) {
            sortedQueryItems.append(URLQueryItem(name: element.key, value: element.value))
        }
        return sortedQueryItems
    }

}

