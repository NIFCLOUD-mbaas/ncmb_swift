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

struct NCMBRequestExecutor : NCMBRequestExecutorProtocol {

    private let session : NCMBSessionProtocol

    init() {
        session = NCMBSessionFactory.getInstance()
    }

    func exec(request: NCMBRequest, callback: @escaping (NCMBResult<NCMBResponse>) -> Void) -> Void {
        let urlRequest : URLRequest
        do {
            urlRequest = try request.build()
        } catch let error {
            NCMBRequestExecutor.doErrorCase(error: error, callback: callback)
            return;
        }
        let task = session.dataTask(with: urlRequest) {
            data, response, error in
            if let error = error {
                NCMBRequestExecutor.doErrorCase(error: error, callback: callback)
                return;
            }
            let res : NCMBResponse
            do {
                res = try NCMBResponse(body: data, response: response)
            } catch let error {
                NCMBRequestExecutor.doErrorCase(error: error, callback: callback)
                return;
            }
            if let apiError = res.apiError {
                NCMBRequestExecutor.doErrorCase(error: apiError, callback: callback)
                return;
            }
            let result = NCMBResult<NCMBResponse>.success(res)
            callback(result)
        }
        task.resume()
    }

    private static func doErrorCase(error: Error, callback: @escaping (NCMBResult<NCMBResponse>) -> Void) -> Void {
            let result = NCMBResult<NCMBResponse>.failure(error)
            callback(result)
    }
}
