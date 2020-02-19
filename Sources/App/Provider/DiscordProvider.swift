//
//  DiscordProvider.swift
//  App
//
//  Created by Christian on 14.02.20.
//

import Vapor

public struct TestWebHooks {
    static let testChannel = "https://discordapp.com/api/webhooks/677528584889565186/a_FWsKmRbs5K0xWOIGB7EiszfZ8QdvVbGVnEyW2t4wy19yIzgjGwLSkEobFePkm26bZM"
}

public final class DiscordProvider: Provider {
    public func register(_ services: inout Services) throws {

    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        .done(on: container)
    }

    public func send(username: String, message: String, avatarURL: String?, webhook: String) -> String {
        do {

            let httpBody = DiscordHTTPBody(
                content: message,
                username: username,
                avatar_url: avatarURL
            )

            let bodyJson = try JSONEncoder().encode(httpBody)

            var headers: HTTPHeaders = .init()
            headers.add(name: .contentType, value: "application/json")
            let body = HTTPBody(data: bodyJson)
            let client = try currentApplication.make(Client.self)
            if let webHookURL = URL(string: webhook) {
                _ = client.post(webHookURL, headers: headers, beforeSend: { request in
                    request.http.body = body
                    debugPrint("beforeSend: \(request)")

                })
            } else {
                print("INVALID WEBHOOK URL")
            }
            return "posting to discord: " + message
        } catch {
            return error.localizedDescription
        }
    }
}

private struct DiscordHTTPBody: Codable {
    let content: String
    let username: String
    let avatar_url: String?
}
