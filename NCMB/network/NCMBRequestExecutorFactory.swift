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


class NCMBRequestExecutorFactory {

    private static let shared = NCMBRequestExecutorFactory()
    private var _executor : NCMBRequestExecutorProtocol

    private init() {
        self._executor = NCMBRequestExecutor()
    }

    class func getInstance() -> NCMBRequestExecutorProtocol {
        return shared._executor
    }

    class func setInstance(executor: NCMBRequestExecutorProtocol) -> Void {
        shared._executor = executor
    }

}