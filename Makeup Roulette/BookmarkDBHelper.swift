//
//  BookmarkDBHelper.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 5/18/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import Foundation
import SQLite3

struct BookmarkDBHelper {
    
    
    // Create SQLite Database File
//    sqliteDatabaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//    .appendingPathComponent("Bookmarks.sqlite")
//
//    if sqlite3_open(sqliteDatabaseURL?.path, &db) != SQLITE_OK {
//    print("error opening database")
//    }
//
//    if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Bookmarks (id INTEGER PRIMARY KEY AUTOINCREMENT, videoId TEXT, title TEXT, thumbnail TEXT, channelTitle TEXT)", nil, nil, nil) != SQLITE_OK {
//    let errmsg = String(cString: sqlite3_errmsg(db)!)
//    print("error creating table: \(errmsg)")
//    }
    
    init() {
        let db = openConnection()
        createTable(db: db)
        closeConnection(db: db)
    }
    
    let createBookmarksTableString = """
        CREATE TABLE IF NOT EXISTS Bookmarks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            videoId TEXT,
            title TEXT,
            thumbnail TEXT,
            channelTitle TEXT
        );
        """
    
    func openConnection() -> OpaquePointer? {
        
        var db: OpaquePointer? = nil
        
        let sqliteDatabaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Bookmarks.sqlite")
        
        if sqlite3_open(sqliteDatabaseURL.path, &db) == SQLITE_OK {
            print("Successfully opened connection to Database at \(sqliteDatabaseURL)")
            return db
        } else {
            print("Unable to open database.")
            return nil
        }
    }
    
    func closeConnection(db: OpaquePointer?) {
        sqlite3_close(db)
    }
    
    func addBookmark(connection: OpaquePointer?,videoId: String, title: String, thumbnail: String, channelTitle: String) {
        
        let insertStatementString = "INSERT INTO Bookmarks (videoId, title, thumbnail, channelTitle) VALUES (?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(connection, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            // 1-4 here represents the position of the `?` inside insertStatementString
            sqlite3_bind_text(insertStatement, 1, videoId, -1, nil)
            sqlite3_bind_text(insertStatement, 2, title, -1, nil)
            sqlite3_bind_text(insertStatement, 3, thumbnail, -1, nil)
            sqlite3_bind_text(insertStatement, 4, channelTitle, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully Added Bookmark.")
            } else {
                print("Bookmark could not be added.")
            }
            
        } else {
            print("INSERT statement could not be prepared.")
        }
        
        sqlite3_finalize(insertStatement)
        
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
            
            bookmarks.append(Bookmark(videoId: String(videoId), title: String(title), thumbnail: String(thumbnail), channelTitle: String(channelTitle)))
        }
        return bookmarks
        
    }
    
}
