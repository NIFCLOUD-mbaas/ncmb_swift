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

class NCMBFieldTypeConverter {

    class func convertToFieldValue(object: Any) -> Any? {
        if let incrementOperator = NCMBIncrementOperator.createInstance(object: object) {
            return incrementOperator
        }
        if let addOperator = NCMBAddOperator.createInstance(object: object) {
            return addOperator
        }
        if let addUniqueOperator = NCMBAddUniqueOperator.createInstance(object: object) {
            return addUniqueOperator
        }
        if let removeOperator = NCMBRemoveOperator.createInstance(object: object) {
            return removeOperator
        }
        if let addRelationOperator = NCMBAddRelationOperator.createInstance(object: object) {
             return addRelationOperator
        }
         if let removeRelationOperator = NCMBRemoveRelationOperator.createInstance(object: object) {
             return removeRelationOperator
         }
        if let dateField = NCMBDateField.createInstance(object: object) {
            return dateField.date
        }
        if let pointer = NCMBPointer.createInstance(object: object) {
            return pointer
        }
        if let relation = NCMBRelation.createInstance(object: object) {
            return relation
        }
        if let geoPoint = NCMBGeoPoint.createInstance(object: object) {
            return geoPoint
        }
        // if let objectField = NCMBObjectField.createInstance(object: object) {
        //     return objectField
        // }
        return nil
    }

    class func converToObject(value: Any) -> [String : Any]? {
        if let incrementOperator = value as? NCMBIncrementOperator {
            return incrementOperator.toObject()
        }
        if let addOperator = value as? NCMBAddOperator {
            return addOperator.toObject()
        }
        if let addUniqueOperator = value as? NCMBAddUniqueOperator {
            return addUniqueOperator.toObject()
        }
        if let removeOperator = value as? NCMBRemoveOperator {
            return removeOperator.toObject()
        }
         if let addRelationOperator = value as? NCMBAddRelationOperator {
             return addRelationOperator.toObject()
        }
         if let removeRelationOperator = value as? NCMBRemoveRelationOperator {
             return removeRelationOperator.toObject()
         }
        if let date = value as? Date {
            return NCMBDateField.convertObject(date: date)
        }
        if let pointer = value as? NCMBPointer {
            return pointer.toObject()
        }
        if let relation = value as? NCMBRelation {
            return relation.toObject()
        }
        if let geoPoint = value as? NCMBGeoPoint {
            return geoPoint.toObject()
        }
        // if let objectField = value as? NCMBObjectField {
        //     return objectField.toObject()
        // }
        return nil
    }
}
