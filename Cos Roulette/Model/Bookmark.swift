//
//  Bookmark.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 5/18/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import Foundation

class Bookmark: Codable {
    
    var videoId: String
    var title: String
    var thumbnail: String
    var channelTitle: String
    
    init(videoId: String, title: String, thumbnail: String, channelTitle: String) {
        self.videoId = videoId
        self.title = title
        self.thumbnail = thumbnail
        self.channelTitle = channelTitle
    }
    
}
