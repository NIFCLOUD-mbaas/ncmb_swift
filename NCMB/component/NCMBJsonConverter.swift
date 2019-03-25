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

class NCMBJsonConverter {

    class func convertToKeyValue(_ body: Data?) throws -> [String : Any] {
        if let body : Data = body {
            if body.isEmpty {
                return [:]
            }
            do {
                let json = try JSONSerialization.jsonObject(with: body, options: [])
                let result = json as? [String : Any]
                if let result = result {
                    return result
                }
            } catch let error {
                throw error
            }
            throw NCMBParseError.unsupportJsonFormat
        }
        return [:]
    }

    class func convertToJson(_ object: [String : Any]) throws -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: object, options: [])
        } catch {
            throw NCMBInvalidRequestError.invalidBodyJsonValue
        }
    }

    class func convertToJson(_ object: [String : Any?]) throws -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: object, options: [])
        } catch {
            throw NCMBInvalidRequestError.invalidBodyJsonValue
        }
    }

}
