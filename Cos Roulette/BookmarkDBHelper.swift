//
//  BookmarkDBHelper.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 5/18/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import Foundation
import SQLite3

struct BookmarkDBHelper {
    
    init() {
        let db = openConnection()
        createTable(db: db)
        closeConnection(db: db)
    }
    
    let createBookmarksTableString = """
        CREATE TABLE IF NOT EXISTS Bookmarks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            videoId TEXT NOT NULL UNIQUE,
            title TEXT NOT NULL,
            thumbnail TEXT NOT NULL UNIQUE,
            channelTitle TEXT NOT NULL
        );
        """
    
    func openConnection() -> OpaquePointer? {
        
        var db: OpaquePointer? = nil
        
        let sqliteDatabaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Bookmarks.sqlite")
        
        if sqlite3_open(sqliteDatabaseURL.path, &db) == SQLITE_OK {
            //print("Successfully opened connection to Database at \(sqliteDatabaseURL)")
            print("Successfully opened connection to Database")
            return db
        } else {
            print("Unable to open database.")
            return nil
        }
    }
    
    func closeConnection(db: OpaquePointer?) {
        let r = sqlite3_close(db)
        if r == SQLITE_OK {
            print("Successfully Closed Connection")
        } else {
            print("Error Attempting to Close Connection")
        }
    }
    
    func addBookmark(connection: OpaquePointer?,videoId: NSString, title: NSString, thumbnail: NSString, channelTitle: NSString) {
        
        let insertStatementString = "INSERT INTO Bookmarks (videoId, title, thumbnail, channelTitle) VALUES (?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(connection, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            // 1-4 here represents the position of the `?` inside insertStatementString
            if sqlite3_bind_text(insertStatement, 1, videoId.utf8String, -1, nil) != SQLITE_OK {
                print("Error binding video")
                return
            }
            if sqlite3_bind_text(insertStatement, 2, title.utf8String, -1, nil) != SQLITE_OK {
                print("Error binding title")
                return
            }
            if sqlite3_bind_text(insertStatement, 3, thumbnail.utf8String, -1, nil) != SQLITE_OK {
                print("Error binding thumbnail")
                return
            }
            if sqlite3_bind_text(insertStatement, 4, channelTitle.utf8String, -1, nil) != SQLITE_OK {
                print("Error binding channelTitle")
                return
            }
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully Added Bookmark.")
            } else {
                print("Bookmark could not be added.")
            }
            
            sqlite3_reset(insertStatement)
            
        } else {
            print("INSERT statement could not be prepared.")
        }
        
        sqlite3_finalize(insertStatement)
        
    }
    
    func removeBookmark(connection: OpaquePointer?, videoId: String) {
        
        let removeStatementString = "DELETE FROM Bookmarks WHERE videoId = '\(videoId)';"
        
        var removeStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(connection, removeStatementString, -1, &removeStatement, nil) == SQLITE_OK {
            
            if sqlite3_step(removeStatement) == SQLITE_DONE {
                print("Successfully Removed Bookmark.")
            } else {
                print("Error attempting to remove Bookmark.")
            }
            
            sqlite3_reset(removeStatement)
            
        } else {
            print("DELETE Statement could not be prepared")
        }
        
        sqlite3_finalize(removeStatement)
        
    }
    
    func createTable(db: OpaquePointer?) {
        
        //var db: OpaquePointer? = nil
        
        var createTableStatement: OpaquePointer? = nil
    
        if sqlite3_prepare_v2(db, createBookmarksTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Bookmarks Table created.")
            } else {
                print("Bookmarks Table could not be created.")
            }
        } else {
            print("Create Table statement not prepare")
        }
        
        sqlite3_finalize(createTableStatement)
        
    }
    
    func queryBookmarksList(db: OpaquePointer?) -> [Bookmark] {
        
        var bookmarks = [Bookmark]()
        
        let queryStatementString = "SELECT * FROM Bookmarks"
        
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare(db, queryStatementString, -1, &queryStatement, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing insert: \(errorMessage)")
        }
        
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            let videoId = String(cString: sqlite3_column_text(queryStatement, 1))
            let title = String(cString: sqlite3_column_text(queryStatement, 2))
            let thumbnail = String(cString: sqlite3_column_text(queryStatement, 3))
            let channelTitle = String(cString: sqlite3_column_text(queryStatement, 4))
            
            let bookmark = Bookmark(
                videoId: String(videoId),
                title: String(title),
                thumbnail: String(thumbnail),
                channelTitle: String(channelTitle)
            )
            
            bookmarks.append(bookmark)
        }
        
        sqlite3_finalize(queryStatement)
        return bookmarks
        
    }
    
}
