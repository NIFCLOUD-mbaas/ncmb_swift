/*
 Copyright 2019-2023 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

#if os(iOS)
import UIKit

public class NCMBAnalytics: NSObject {

    public static func trackAppOpenedWithLaunchOptions(launchOptions : [UIApplication.LaunchOptionsKey: Any]?) {
        if let notificationOption = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            trackAppOpenedWithRemoteNotificationPayload(userInfo: notificationOption)
        }
    }
    
    public static func trackAppOpenedWithRemoteNotificationPayload(userInfo : [String: AnyObject]) {
        if let pushId = userInfo["com.nifcloud.mbaas.PushId"] as? String {
            if NCMBInstallation.currentInstallation.objectId != nil {
                do {
                    let url = "\(pushId)/openNumber"
                    //コネクションを作成
                    let data : Data? = try NCMBJsonConverter.convertToJson(["deviceType": NCMBInstallation.currentInstallation.deviceType,
                                                                            "deviceToken":NCMBInstallation.currentInstallation.deviceToken])
                    let request : NCMBRequest = NCMBRequest(
                        apiType: NCMBApiType.push,
                        method: NCMBHTTPMethod.post,
                        subpath: [url],
                        body: data,
                        timeoutInterval: NCMBFileService.REQUEST_TIMEINTERVAL)
                    let executor : NCMBRequestExecutorProtocol = NCMBRequestExecutorFactory.getInstance()
                    executor.exec(request: request, callback: {(result: NCMBResult<NCMBResponse>) -> Void in
                        
                    })
                } catch {
                    
                }
            }
        }
    }
}
#endif
