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

class NCMBLocalFileManagerFactory {

    private static let shared = NCMBLocalFileManagerFactory()
    private var _manager : NCMBLocalFileManagerProtocol

    private init() {
        #if os(iOS)
            self._manager = NCMBLocalFileManager()
        #else
            self._manager = DummyLocalFileManager()
        #endif
    }

    class func setDummy() -> Void {
        shared._manager = DummyLocalFileManager()
    }

    class func getInstance() -> NCMBLocalFileManagerProtocol {
        return shared._manager
    }

    class func setInstance(manager: NCMBLocalFileManagerProtocol) -> Void {
        shared._manager = manager
    }

    private class DummyLocalFileManager : NCMBLocalFileManagerProtocol {
        func loadFromFile(target: NCMBLocalFileType) -> Data? { return nil }
        func saveToFile(data: Data, target: NCMBLocalFileType) -> Void {}
        func deleteFile(target: NCMBLocalFileType) -> Void {}
        init() {}
    }

    private class NCMBLocalFileManager : NCMBLocalFileManagerProtocol {

        let manager : FileManager
        let baseUrl : URL

        init() {
            self.manager = FileManager.default
            let documentDir : URL = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.baseUrl = documentDir.appendingPathComponent("NCMB")
        }

        func loadFromFile(target: NCMBLocalFileType) -> Data? {
            let url : URL = target.getURL(base: self.baseUrl)
            if !self.manager.fileExists(atPath: url.relativePath) {
                return nil
            }
            do {
                return try Data(contentsOf: url)
            } catch let error {
                NSLog("NCMB: Failed to acquire local file with \(target.message) : \(error)")
            }
            return nil
        }

        func saveToFile(data: Data, target: NCMBLocalFileType) -> Void {
            do {
                try manager.createDirectory(at: self.baseUrl, withIntermediateDirectories: true, attributes: [:])
                try data.write(to: target.getURL(base: self.baseUrl), options: [])
            } catch let error {
                NSLog("NCMB: Failed to save local file with \(target.message) : \(error)")
            }
        }

        func deleteFile(target: NCMBLocalFileType) -> Void {
            do {
                try self.manager.removeItem(at: target.getURL(base: self.baseUrl))
            } catch let error {
                NSLog("NCMB: Failed to delete local file with \(target.message) : \(error)")
            }
        }
    }
}
