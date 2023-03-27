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


struct NCMBLoginService {
    
    var apiType : NCMBApiType {
        get {
            return NCMBApiType.login
        }
    }
    
    func logIn(userName: [String : String?], mailAddress: [String : String?],password:[String : String], callback : @escaping (NCMBResult<NCMBResponse>) -> Void ) -> Void {
        
        let request : NCMBRequest
        do {
            request = try createPostRequest(userName: userName, mailAddress: mailAddress,password:password)
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
    
//    func createGetRequest(queryItems: [String : String?]) -> NCMBRequest {
//        var request : NCMBRequest = NCMBRequest(
//            apiType: apiType,
//            method: NCMBHTTPMethod.get)
//        request.queryItems = queryItems
//        return request
//    }
    
    func createPostRequest(userName: [String : String?], mailAddress: [String : String?],password:[String : String]) throws -> NCMBRequest{
        
        var requestBody : Data?
        do{
            if (userName != nil){
                requestBody = try NCMBJsonConverter.convertToJson(["userName": userName,
                                                                   "password":password])
            } else if (mailAddress != nil){
                requestBody = try NCMBJsonConverter.convertToJson(["mailAddress": mailAddress,
                                                                   "password":password])
            }
        } catch let error{
            throw error
        }
        
        var request : NCMBRequest = NCMBRequest(
            apiType: apiType,
            method: NCMBHTTPMethod.post,
            body: requestBody)
        
        return request
    }
    
}
