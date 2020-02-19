//
//  Tweets.swift
//  App
//
//  Created by Christian on 13.02.20.
//

import Foundation


public struct Tweets: Codable {
    let statuses: [Tweet]
}

public struct Tweet: Codable {
    let id: Int
    let created_at: String
    let full_text: String
    let retweeted: Bool
    let extended_entities: ExtendedEntities?
    let user: User?
    let in_reply_to_screen_name: String?
}

public struct ExtendedEntities: Codable {
    let media: [ExtendedEntitiesMedia]?
}

public struct ExtendedEntitiesMedia: Codable {
    let url: String?
    let expanded_url: String?
}

public struct User: Codable {
    let screen_name: String
    let profile_image_url: String?
}
