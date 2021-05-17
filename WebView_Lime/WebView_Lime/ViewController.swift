//
//  ViewController.swift
//  WebView_Lime
//
//  Created by limefriends on 2021/04/23.
//

import UIKit
import WebKit
import SnapKit
import SVProgressHUD

let _KitaURL = URL(string: "https://www.kita.net")!
let _KitaURLRequest = URLRequest(url: _KitaURL)

class ViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var backwardButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var webview: WKWebView!
    var childWebviews: [WKWebView] = []
    var currentWebview: WKWebView {
        get {
            if childWebviews.count > 0 {
                return childWebviews.last!
            }
            return webview
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        webview = WKWebView(frame: CGRect.zero, configuration: config)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.allowsBackForwardNavigationGestures = true
        containerView.addSubview(webview)
        webview.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        webview.load(_KitaURLRequest)
    }
    
    @IBAction func backwardAction(_ sender: Any) {
        if currentWebview.canGoBack {
            currentWebview.goBack()
            // 뒤로 가기 후 break 위해 return 입력
            return
        }
        
        if childWebviews.count > 0 {
            let last = childWebviews.popLast()
            last?.removeFromSuperview()
            setBackAndForwardButton()
        }
    }
    
    @IBAction func forwardAction(_ sender: Any) {
        if currentWebview.canGoForward {
            currentWebview.goForward()
        }
    }
    
    @IBAction func shareAction(_ sender: Any) {
        guard let url = currentWebview.url else { return }
        
        let items = [url]
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.show(activity, sender: nil)
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        currentWebview.reload()
    }
    
    @IBAction func homeAction(_ sender: Any) {
        currentWebview.load(_KitaURLRequest)
    }
    
    // 뒤로가기, 앞으로가기 버튼 세팅
    // 웹뷰 탐색 완료 delegate 이외 코드에서도 사용할 때가 있어 따로 method를 만듦
    func setBackAndForwardButton() {
        backwardButton.isEnabled = currentWebview.canGoBack || childWebviews.count > 0
        forwardButton.isEnabled = currentWebview.canGoForward
    }
    
    // 공유버튼 세팅
    func setShareButton() {
        currentWebview.evaluateJavaScript("document.body.innerHTML") { (data, error) in
            guard error == nil else {
                self.shareButton.isEnabled = false
                return
            }
            
            // html body 안에 "popShare" 가 있을 경우 공유 버튼 활성화
            if let html = data as? String,
               html.contains("popShare") {
                self.shareButton.isEnabled = true
            }
            else {
                self.shareButton.isEnabled = false
            }
        }
    }
}

extension ViewController: WKUIDelegate {
    // 새 웹뷰 생성
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return createWebView(config: configuration)
    }
    
    // 새 웹뷰를 child웹뷰로 추가
    func createWebView(config: WKWebViewConfiguration) -> WKWebView {
        let newChildWebview = WKWebView(frame: CGRect.zero, configuration: config)
        newChildWebview.navigationDelegate = self
        newChildWebview.uiDelegate = self
        newChildWebview.allowsBackForwardNavigationGestures = true
        
        containerView.addSubview(newChildWebview)
        newChildWebview.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        childWebviews.append(newChildWebview)
        
        return newChildWebview
    }
    
    // 자바스크립트로 창 닫음
    func webViewDidClose(_ webView: WKWebView) {
        // 자바스크립트로 창을 닫을 때도 childWebview 처리를 해야 팝업창이 동시에 닫히지 않음(2개 이상일 때)
        if childWebviews.count > 0 {
            let last = childWebviews.popLast()
            last?.removeFromSuperview()
        }
        setBackAndForwardButton()
    }
    
    // 기본 프레임에서 탐색이 시작되었음을 delegate에 알림
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        SVProgressHUD.show()
    }
    
    // 탐색 완료
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.setBackAndForwardButton()
        self.setShareButton()
        SVProgressHUD.dismiss()
        print("--->[ChildWebviews] count:", childWebviews.count, "canGoBack?:", currentWebview.canGoBack)
    }
    
    // javascript alert 처리
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .default) { (action) in
            completionHandler(false)
        }
        let ok = UIAlertAction(title: "확인", style: .default) { (action) in
            completionHandler(true)
        }
        ac.addAction(cancel)
        ac.addAction(ok)
        present(ac, animated: true)
    }
    
    // 탐색 중 오류가 발생하면 호출
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.setShareButton()
        SVProgressHUD.dismiss()
        print("--->[webView:didFail]:", error.localizedDescription)
    }
}
