//
//  TweetProvider.swift
//  App
//
//  Created by Christian on 13.02.20.
//

import Foundation
import Vapor

enum TweetProviderError: Error {
    case decodingFailed
}

public final class TweetProvider: Provider {

    public func register(_ services: inout Services) throws {
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }

    func retrieveTweets(username: String, numberOfTweets: UInt = 50, completion: @escaping (Result<Tweets, Error>) -> Void) -> String {
        do {
            let result = shell(
                command: .twurl(
                    username: username,
                    numberOfTweets: numberOfTweets
                )
            )

            if let data = result.output.data(using: .utf8) {
                let tweets = try JSONDecoder().decode(Tweets.self, from: data)
                completion(.success(tweets))
            } else {
                completion(.failure(TweetProviderError.decodingFailed))
            }
            return result.output
        } catch {
            completion(.failure(error))
            return error.localizedDescription
        }
    }
}
