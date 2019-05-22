//
//  BookmarkStore.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 5/20/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import UIKit

class BookmarkStore {
    
    var allBookmarks = [Bookmark]()
    
    var dbHelper: BookmarkDBHelper!
    
    init() {
        allBookmarks.removeAll()
        dbHelper = BookmarkDBHelper()
        let dbConn = dbHelper.openConnection()
        dbHelper.queryBookmarksList(db: dbConn).forEach { bookmark in
            allBookmarks.append(bookmark)
        }
    }
    
    func appendBookmark(bookmark: Bookmark) {
        allBookmarks.append(bookmark)
    }
    
    func allStoreBookmarks() -> [Bookmark] {
        return allBookmarks
    }
    
}
