//
//  ContentView.swift
//  CustomDNS
//
//  Created by Md Ashikul Hosen Sagor on 17-10-2024.
//

import SwiftUI
import WebKit

struct ContentView: View {
    
    let host = "127.0.0.1"
    let port = 8080
    
    let server: ProxyServer
    let webView = WebView()
    
    @State var urlString: String
    
    init() {
        self.server = ProxyServer(host: host, port: port)
        self.urlString = "https://www.facebook.com"
        server.start()
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    webView.goBack()
                }) {
                    Image(systemName: "arrow.backward")
                        .font(.title)
                        .padding()
                }
                
                TextField("Enter url", text: $urlString)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                
                Button(action: {
                    webView.loadURL(urlString: urlString)
                }, label: {
                    Text("Go")
                    
                })
                
                Button(action: {
                    webView.goForward()
                }) {
                    Image(systemName: "arrow.forward")
                        .font(.title)
                        .padding()
                    
                    
                }
                
            }.background(Color(.systemGray6))
            
            webView
        }
        .onAppear {
            webView.loadURL(urlString: urlString)
        }
    }
}
#Preview {
    ContentView()
}
