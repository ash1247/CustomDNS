//
//  WebView.swift
//  CustomDNS
//
//  Created by Md Ashikul Hosen Sagor on 17-10-2024.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    private let webView: WKWebView
    private let urlObservation: NSKeyValueObservation
    
    init() {
        let webConfiguration = WKWebViewConfiguration()
        let wkcontentController = WKUserContentController()
        webConfiguration.userContentController = wkcontentController
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView = webView
        self.urlObservation = webView.observe(\.url) { (webView, change) in
            print("Changed url")
            print(webView.url?.absoluteString)
        }
        
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsBackForwardNavigationGestures = true
        self.webView.navigationDelegate = context.coordinator
        self.webView.uiDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func goBack(){
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func loadURL(urlString: String) {
        webView.load(URLRequest(url: URL(string: urlString)!))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self.webView)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        weak var view: WKWebView?
        
        init(_ view: WKWebView) {
            self.view = view
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            print(#function)
            do {
                let urlString = navigationAction.request.url?.absoluteString ?? ""
                let string = "http://\("127.0.0.1"):\(8080)/dns?url=\(urlString)"
                let (_, response) = try await URLSession.shared.data(from: URL(string: string)!)
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 403 {
                    return .cancel
                }
            } catch {
                return .cancel
            }
            
            return .allow
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            print("Error: \(error)")
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        }
    }
}
