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

#if canImport(CommonCrypto)
    import CommonCrypto
#else
    import CryptoSwift
#endif

class NCMBSignatureCalculator {

    static let SIGNATURE_METHOD : String = "SignatureMethod=HmacSHA256"
    static let SIGNATURE_VERSION : String = "SignatureVersion=2"

    class func calculate(method: NCMBHTTPMethod, date: Date, url: URL) throws -> String {
        do {
            let timestamp : String = NCMBDateFormatter.getISO8601Timestamp(date: date)
            let domainName : String = try getDomainName(url: url)
            let path : String = getPath(url: url)
            let query : String = getQuery(url: url)
            let applicationKey : String = try getApplicationKey()
            let clientKey : String = try getClientKey()
            let plaintext : String = createPlaintext(
                method: method,
                timestamp: timestamp,
                domainName: domainName,
                applicationKey: applicationKey,
                path: path,
                query: query)
            return try calculateSignature(plaintext: plaintext, clientKey: clientKey)
        } catch let error {
            throw error
        }
    }

    private class func getDomainName(url: URL) throws -> String {
        if let host = url.host {
            return host
        }
        throw NCMBInvalidRequestError.invalidDomainName
    }

    private class func getPath(url: URL) -> String {
        return url.path
    }

    private class func getQuery(url: URL) -> String {
        if let query = url.query {
            return query
        }
        return ""
    }

    private class func getApplicationKey() throws -> String {
        if NCMB.applicationKey == "" {
            throw NCMBInvalidRequestError.emptyApplicationKey
        }
        return NCMB.applicationKey
    }

    private class func getClientKey() throws -> String {
        if NCMB.clientKey == "" {
            throw NCMBInvalidRequestError.emptyClientKey
        }
        return NCMB.clientKey
    }

    private class func createPlaintext(
            method: NCMBHTTPMethod,
            timestamp: String,
            domainName: String,
            applicationKey: String,
            path: String,
            query: String = "") -> String {
        var result : String =  method.rawValue + "\n"
        result += domainName + "\n"
        result += path + "\n"
        result += createPlaintextLastLine(timestamp: timestamp, applicationKey: applicationKey, query: query)
        return result
    }

    private class func createPlaintextLastLine(timestamp: String, applicationKey: String, query: String) -> String {
        var array : [String] = [
            SIGNATURE_METHOD,
            SIGNATURE_VERSION,
            "X-NCMB-Application-Key=" + applicationKey,
            "X-NCMB-Timestamp=" + timestamp]
        if query != "" {
            array.append(query)
        }
        array.sort()
        return array.joined(separator: "&")
    }

    #if canImport(CommonCrypto)

    class func calculateSignature(plaintext: String, clientKey: String) throws -> String {
        guard let bytes = plaintext.cString(using: .utf8) else {
            throw NCMBInvalidRequestError.cantCalculateSignature
        }
        guard let key = clientKey.cString(using: .utf8) else {
            throw NCMBInvalidRequestError.cantCalculateSignature
        }
        let sha256Length : Int = Int(CC_SHA256_DIGEST_LENGTH)
        let cHMAC = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: sha256Length)
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count - 1, bytes, bytes.count - 1, cHMAC)
        var hmac = Data()
        for i in 0..<sha256Length {
            hmac.append(contentsOf: [UInt8(cHMAC[i])])
        }
        cHMAC.deallocate()
        return hmac.base64EncodedString()
    }

    #else

    class func calculateSignature(plaintext: String, clientKey: String) throws -> String {
        let bytes : [UInt8] = Array(plaintext.utf8)
        let key : [UInt8] = Array(clientKey.utf8)
        do {
            let hmac : [UInt8] = try HMAC(key: key, variant: .sha256).authenticate(bytes)
            if let signature : String = hmac.toBase64() {
                return signature
            } else {
                throw NCMBInvalidRequestError.cantCalculateSignature
            }
        } catch {
            throw NCMBInvalidRequestError.cantCalculateSignature
        }
    }

    #endif

}
