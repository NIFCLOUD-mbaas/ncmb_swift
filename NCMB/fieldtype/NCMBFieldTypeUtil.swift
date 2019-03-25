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


class NCMBFieldTypeUtil {

    static let TYPE_FIELD_NAME : String = "__type"
    static let OPERATE_FIELD_NAME : String = "__op"

    class func checkTypeField(object: [String : Any], typename : String) -> Bool {
        if let type = object[TYPE_FIELD_NAME] {
            if let type = type as? String {
                if type == typename {
                    return true
                }
            }
        }
        return false
    }

    class func checkOperationField(object: [String : Any], typename : String) -> Bool {
        if let type = object[OPERATE_FIELD_NAME] {
            if let type = type as? String {
                if type == typename {
                    return true
                }
            }
        }
        return false
    }

    class func getFieldValue<T>(object: [String : Any], fieldname : String) -> T? {
        if let value = object[fieldname] {
            if let value = value as? T {
                return value
            }
        }
        return nil
    }

    class func createTypeObjectBase(typename: String) -> [String : Any] {
        var object : [String : Any] = [:]
        object[TYPE_FIELD_NAME] = typename
        return object
    }

    class func createOperatorObjectBase(typename: String) -> [String : Any] {
        var object : [String : Any] = [:]
        object[OPERATE_FIELD_NAME] = typename
        return object
    }

}