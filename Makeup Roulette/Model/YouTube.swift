//
//  YouTube.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 3/8/19.
//  Copyright © 2019 Fedha. All rights reserved.
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
}
extension Items: Decodable {
    
    enum ItemsCodingKeys: String, CodingKey {
        case id
    }
    
    init(from decoder: Decoder) throws {
        let itemsContainer = try decoder.container(keyedBy: ItemsCodingKeys.self)
        
        id = try itemsContainer.decode(Id.self, forKey: .id)
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

