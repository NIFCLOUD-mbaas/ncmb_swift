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


/// APIエラーコードと対応する列挙型です。
public enum NCMBApiErrorCode : Error {
    case invalidResponseSignature
    case badRequest
    case invalidJson
    case invalidType
    case required
    case invalidFormat
    case invalidValue
    case notExist
    case invalidFormatSpecificLine
    case correlationError
    case invalidLength
    case unauthorized
    case authenticationErrorByHeaderIncorrect
    case authenticationErrorWithIdPassIncorrect
    case oAuthAuthenticationError
    case noSettlementForAFreePlan
    case forbidden
    case noAccessWithACL
    case unauthorizedOperations
    case operationThatAreProhibited
    case oneTimeTokenExpired
    case settingDisable
    case invalidGeoPointValue
    case noDataAvailable
    case noneService
    case noneField
    case noneDeviceToken
    case noSuchApplication
    case noSuchUser
    case methodNotAllowed
    case duplication
    case fileSizeLimitError
    case requestEntityTooLarge
    case requestsThreadLimitError
    case requestUriTooLarge
    case unsupportedMediaType
    case passedLimit
    case tooManyRequests
    case systemError
    case storageError
    case mailFailure
    case serviceUnavailable
    case genericError

    init(code: String) {
        switch code {
            case "E100001": self = .invalidResponseSignature
            case "E400000": self = .badRequest
            case "E400001": self = .invalidJson
            case "E400002": self = .invalidType
            case "E400003": self = .required
            case "E400004": self = .invalidFormat
            case "E400005": self = .invalidValue
            case "E400006": self = .notExist
            case "E400007": self = .invalidFormatSpecificLine
            case "E400008": self = .correlationError
            case "E400009": self = .invalidLength
            case "E401000": self = .unauthorized
            case "E401001": self = .authenticationErrorByHeaderIncorrect
            case "E401002": self = .authenticationErrorWithIdPassIncorrect
            case "E401003": self = .oAuthAuthenticationError
            case "E401004": self = .noSettlementForAFreePlan
            case "E403000": self = .forbidden
            case "E403001": self = .noAccessWithACL
            case "E403002": self = .unauthorizedOperations
            case "E403003": self = .operationThatAreProhibited
            case "E403004": self = .oneTimeTokenExpired
            case "E403005": self = .settingDisable
            case "E403006": self = .invalidGeoPointValue
            case "E404001": self = .noDataAvailable
            case "E404002": self = .noneService
            case "E404003": self = .noneField
            case "E404004": self = .noneDeviceToken
            case "E404005": self = .noSuchApplication
            case "E404006": self = .noSuchUser
            case "E405001": self = .methodNotAllowed
            case "E409001": self = .duplication
            case "E413001": self = .fileSizeLimitError
            case "E413002": self = .requestEntityTooLarge
            case "E413003": self = .requestsThreadLimitError
            case "E414000": self = .requestUriTooLarge
            case "E415001": self = .unsupportedMediaType
            case "E429001": self = .passedLimit
            case "E429002": self = .tooManyRequests
            case "E500001": self = .systemError
            case "E502001": self = .storageError
            case "E502002": self = .mailFailure
            case "E503001": self = .serviceUnavailable
            default: self = .genericError
        }
    }
}
