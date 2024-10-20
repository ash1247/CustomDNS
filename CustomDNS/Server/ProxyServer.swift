//
//  ProxyServer.swift
//  CustomDNS
//
//  Created by Md Ashikul Hosen Sagor on 17-10-2024.
//

import Vapor

final class ProxyServer {
    
    var app: Application
    let host: String
    let port: Int
    
    init(host: String, port: Int) {
        self.app = Application(.development)
        self.host = host
        self.port = port
        configure(app)
    }
    
    private func configure(_ app: Application) {
        app.http.server.configuration.hostname = host
        app.http.server.configuration.port = port
    }
    
    func start() {
        Task(priority: .background) {
            do {
                try app.register(collection: ProxyWebRouteCollection())
                try await app.startup()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
