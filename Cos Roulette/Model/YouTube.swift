//
//  YouTube.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 3/8/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import Foundation

struct YouTubeApiSearchResponse {
    // Response url: https://developers.google.com/youtube/v3/docs/search/list#response
    let nextPageToken: String
    let items: [Items]
}
extension YouTubeApiSearchResponse: Decodable {
    
    private enum YouTubeApiSearchResponseCodingKeys: String, CodingKey {
        case nextPageToken
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: YouTubeApiSearchResponseCodingKeys.self)
        
        nextPageToken = try container.decode(String.self, forKey: .nextPageToken)
        items = try container.decode([Items].self, forKey: .items)
    }
}

struct Items {
    let id: Id
    let snippet: Snippet
}
extension Items: Decodable {
    
    enum ItemsCodingKeys: String, CodingKey {
        case id
        case snippet
    }
    
    init(from decoder: Decoder) throws {
        let itemsContainer = try decoder.container(keyedBy: ItemsCodingKeys.self)
        
        id = try itemsContainer.decode(Id.self, forKey: .id)
        snippet = try itemsContainer.decode(Snippet.self, forKey: .snippet)
    }
}

struct Id {
    let videoId: String
}
extension Id: Decodable {
    
    enum IdCodingKeys: String, CodingKey {
        case videoId
    }
    
    init(from decoder: Decoder) throws {
        let idContainer = try decoder.container(keyedBy: IdCodingKeys.self)
        
        videoId = try idContainer.decode(String.self, forKey: .videoId)
    }
}

struct Snippet {
    var title: String
    var thumbnails: Thumbnails
    var channelTitle: String
}
extension Snippet: Decodable {
    
    enum SnippetCodingKeys: String, CodingKey {
        case title
        case thumbnails
        case channelTitle
    }
    
    init(from decoder: Decoder) throws {
        let snippetContainer = try decoder.container(keyedBy: SnippetCodingKeys.self)
        
        title = try snippetContainer.decode(String.self, forKey: .title)
        thumbnails = try snippetContainer.decode(Thumbnails.self, forKey: .thumbnails)
        channelTitle = try snippetContainer.decode(String.self, forKey: .channelTitle)
    }
}

struct Thumbnails {
    var medium: Medium
}
extension Thumbnails: Decodable {
    
    enum ThumbnailsCodingKeys: String, CodingKey {
        case medium
    }
    
    init(decoder: Decoder) throws {
        let thumbnailsContainer = try decoder.container(keyedBy: ThumbnailsCodingKeys.self)
        
        medium = try thumbnailsContainer.decode(Medium.self, forKey: .medium)
    }
}

struct Medium {
    var url: String
}
extension Medium: Decodable {
    
    enum MediumCodingKeys: String, CodingKey {
        case url
    }
    
    init(from decoder: Decoder) throws {
        let mediumContainer = try decoder.container(keyedBy: MediumCodingKeys.self)
        
        url = try mediumContainer.decode(String.self, forKey: .url)
    }
}
