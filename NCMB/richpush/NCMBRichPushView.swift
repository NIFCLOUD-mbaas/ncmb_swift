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


#if os(iOS)
import WebKit
import UIKit

let IMAGE_SIZE = 25

class NCMBRichPushView: UIViewController, WKNavigationDelegate {
    
    private var _webView: WKWebView!
    private var _activityIndicator: UIActivityIndicatorView!
    private var _richUrl : String!
    private var _closeCallback : () -> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        
        let myURL = URL(string: _richUrl)
        let myRequest = URLRequest(url: myURL!)
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.suppressesIncrementalRendering = true;
        
        view.frame = CGRect(x: 0,
                            y: 0,
                            width: Int(view.frame.width),
                            height: Int(view.frame.height * 0.9))
        let viewSize:CGSize = view.frame.size
        
        var safeAreaTop:Int = 0
        var safeAreaBottom:Int = 0
        
        if #available(iOS 11.0, *) {
            safeAreaTop = Int((UIApplication.shared.keyWindow?.safeAreaInsets.top)!)
            safeAreaBottom = Int((UIApplication.shared.keyWindow?.safeAreaInsets.top)!)
        }
        
        let rect = CGRect(x: 0,
                          y: safeAreaTop + Int(viewSize.height * 0.05),
                          width: Int(viewSize.width),
                          height: Int(viewSize.height) - safeAreaTop - safeAreaBottom - IMAGE_SIZE*2)
        
        _webView = WKWebView(frame: rect , configuration: webConfiguration)
        _webView.navigationDelegate = self
        view.addSubview(_webView)
        _webView.load(myRequest)
        
        let buttonRect =  CGRect(x: Int((viewSize.width)/2) - 50,
                                 y: Int((viewSize.height)) - safeAreaBottom - IMAGE_SIZE + Int(viewSize.height * 0.05),
                                 width: 100,
                                 height: IMAGE_SIZE)
        let closeButton = getCloseButton(frame: buttonRect, color: UIColor.black)
        view.addSubview(closeButton!)
        
        _activityIndicator = UIActivityIndicatorView()
        _activityIndicator.center = self.view.center
        _activityIndicator.hidesWhenStopped = true
        _activityIndicator.style = UIActivityIndicatorView.Style.gray
        
        view.addSubview(_activityIndicator)
        showActivityIndicator(show: true)
        view.backgroundColor = UIColor.gray
        
    }
    
    public var richUrl : String? {
        get {
            return self._richUrl
        }
        set {
            self._richUrl = newValue
        }
    }
    
    var closeCallback : () -> Void {
        get {
            return self._closeCallback
        }
        set {
            self._closeCallback = newValue
        }
    }
    
    //ウェブビューデリゲート
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        showActivityIndicator(show: false)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        showActivityIndicator(show: false)
    }
    
    func getCloseButton(frame: CGRect, color: UIColor) -> UIButton? {
        let button = UIButton(type: .custom)
        button.frame = frame
        button.setTitleColor(color, for: .normal)
        button.setTitle("Close", for: .normal)
        button.addTarget(self, action: #selector(closeAction), for: UIControl.Event.touchUpInside)
        return button
    }
    
    func showActivityIndicator(show: Bool) {
        if show {
            _activityIndicator.startAnimating()
        } else {
            _activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true) {
            self._closeCallback()
        }
    }
    
}
#endif
