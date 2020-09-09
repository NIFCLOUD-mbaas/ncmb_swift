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


protocol NCMBRequestServiceProtocol {

    var apiType : NCMBApiType { get }

    func getSubpath(object: NCMBBase, objectId: String?) -> [String]

}

extension NCMBRequestServiceProtocol {

    func find<T : NCMBBase>(query: NCMBQuery<T>, callback: @escaping (NCMBResult<NCMBResponse>) -> Void ) -> Void {
        let request : NCMBRequest
        request = createGetRequest(query: query)
        let executor : NCMBRequestExecutorProtocol = NCMBRequestExecutorFactory.getInstance()
        executor.exec(request: request, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
            callback(result)
        })
    }

    func fetch(object: NCMBBase, callback: @escaping (NCMBResult<NCMBResponse>) -> Void ) -> Void {
        let request : NCMBRequest
        do {
            request = try createGetRequest(object: object)
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


    func save(object: NCMBBase, callback: @escaping (NCMBResult<NCMBResponse>) -> Void ) -> Void {
        let request : NCMBRequest
        do {
            if let objectId = object.objectId {
                request = try createPutRequest(object: object, objectId: objectId)
            } else {
                request = try createPostRequest(object: object)
            }
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

    func delete(object: NCMBBase, callback: @escaping (NCMBResult<NCMBResponse>) -> Void ) -> Void {
        let request : NCMBRequest
        do {
            request = try createDeleteRequest(object: object)
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

    func createGetRequest(object: NCMBBase) throws -> NCMBRequest {
        if let objectId = object.objectId {
            let request : NCMBRequest = NCMBRequest(
                    apiType: apiType,
                    method: NCMBHTTPMethod.get,
                    subpath: getSubpath(object: object, objectId: objectId))
            return request
        }
        throw NCMBInvalidRequestError.emptyObjectId
    }

    func createGetRequest<T : NCMBBase>(query: NCMBQuery<T>) -> NCMBRequest {
        let object : NCMBBase = NCMBBase(className: query.className)
        let request : NCMBRequest = NCMBRequest(
                apiType: apiType,
                method: NCMBHTTPMethod.get,
                subpath: getSubpath(object: object, objectId: nil),
                queries: query.requestItems)
        return request
    }

    func createPostRequest(object: NCMBBase) throws -> NCMBRequest {
        do {
            let request : NCMBRequest = NCMBRequest(
                    apiType: apiType,
                    method: NCMBHTTPMethod.post,
                    subpath: getSubpath(object: object, objectId: nil),
                    body: try object.getPostFieldsToJson())
            return request
        } catch let error {
            throw error
        }
    }

    func createPutRequest(object: NCMBBase, objectId: String) throws -> NCMBRequest {
        do {
            let request : NCMBRequest = NCMBRequest(
                    apiType: apiType,
                    method: NCMBHTTPMethod.put,
                    subpath: getSubpath(object: object, objectId: objectId),
                    body: try object.getModifiedToJson())
            return request
        } catch let error {
            throw error
        }
    }

    func createDeleteRequest(object: NCMBBase) throws -> NCMBRequest {
        if let objectId = object.objectId {
            let request : NCMBRequest = NCMBRequest(
                    apiType: self.apiType,
                    method: NCMBHTTPMethod.delete,
                    subpath: getSubpath(object: object, objectId: objectId))
            return request
        }
        throw NCMBInvalidRequestError.emptyObjectId
    }

}
