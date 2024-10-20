//
//  ProxyWebRouteCollection.swift
//  CustomDNS
//
//  Created by Md Ashikul Hosen Sagor on 17-10-2024.
//

import Vapor
import DNSClient
import NIO

struct ProxyWebRouteCollection: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("dns", use: dnsResolutionHandler)
    }
    
    private func dnsResolutionHandler(_ req: Request) async throws -> Response {
        guard let targetURL = try req.query.decode(ProxyURL.self).url else {
            throw Abort(.badRequest)
        }
        guard let url = URL(string: targetURL) else {
            throw Abort(.badRequest)
        }
        
        guard let hostName = url.host() else {
            throw Abort(.badRequest)
        }
        let blockedHost = "blocked.kahfguard.com"
        var responseHost = ""
        let dnsServerUrls = ["51.142.0.101", "51.142.0.102"]
        do {
            let kahfGuardDns = dnsServerUrls.map{ try! SocketAddress(ipAddress: $0, port: 53) }
            let client = try await DNSClient.connect(on: req.eventLoop, config: kahfGuardDns).get()
            let records = try await client.sendQuery(forHost: "\(hostName)", type: .cName).get()
            if case .cname(let data) = records.answers.first {
                data.resource.labels.enumerated().forEach {
                    $0.element.label.forEach{
                        let char = String(UnicodeScalar($0))
                        responseHost.append(char)
                        print(char, terminator: "")
                    }
                    if $0.offset < 2 {
                        let char = "."
                        responseHost.append(char)
                        print(char, terminator: "")
                    }
                }
            }
        } catch {
            return Response(status: .forbidden, body: .init(stringLiteral: error.localizedDescription))
        }
        if blockedHost == responseHost {
            return Response(status: .forbidden, body: .init(stringLiteral: "BLOCKED"))
        }
       
        return Response(status: .ok, body: .init(stringLiteral: "You are okay to proceed"))

    }
    
}

fileprivate struct ProxyURL: Content {
    var url: String?
}
