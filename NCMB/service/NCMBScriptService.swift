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

struct NCMBScriptService {

    let method : NCMBHTTPMethod
    let endpoint : String
    let apiVersion : String

    init(method: NCMBHTTPMethod, endpoint: String, apiVersion: String) {
        self.method = method
        self.endpoint = endpoint
        self.apiVersion = apiVersion
    }

    func executeScript(
                name: String,
                headers: [String : String?],
                queries: [String : String?],
                body: [String : Any?],
                callback: @escaping (NCMBResult<NCMBResponse>) -> Void ) -> Void {
        let request : NCMBRequest
        do {
            request = try createRequest(name: name, headers: headers, queries: queries, body: body)
        } catch let error {
            let result = NCMBResult<NCMBResponse>.failure(error)
            callback(result)
            return;
        }
        let executor : NCMBRequestExecutorProtocol = NCMBRequestExecutorFactory.getInstance()
        executor.exec(request: request, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            callback(result)
        })
    }

    func createRequest(
                name: String,
                headers: [String : String?],
                queries: [String : String?],
                body: [String : Any?]) throws -> NCMBRequest {
        let data: Data? = try convertToJson(body: body)
        let request : NCMBRequest = NCMBRequest(
                domainURL: self.endpoint,
                apiVersion: self.apiVersion,
                apiType: NCMBApiType.script,
                method: self.method,
                subpath: [name],
                headers: headers,
                queries: queries,
                contentType: NCMBRequest.DEFAULT_CONTENT_TYPE,
                body: data)
        return request
    }
    
    func convertToJson(body: [String: Any?]) throws -> Data? {
        if body.count == 0 {
            return nil
        }
        do {
            return try NCMBJsonConverter.convertToJson(body)
        } catch {
            throw NCMBInvalidRequestError.invalidBodyJsonValue
        }
    }
}
