//
//  TweetedTweet.swift
//  App
//
//  Created by Christian on 14.02.20.
//

import FluentSQLite
import Vapor

public final class TweetedTweet: SQLiteModel {
    public var id: Int?
    public var tweetID: Int

    public init(id: Int? = nil, tweetID: Int) {
        self.id = id
        self.tweetID = tweetID
    }
}

extension TweetedTweet: Migration { }
extension TweetedTweet: Content { }
extension TweetedTweet: Parameter { }
