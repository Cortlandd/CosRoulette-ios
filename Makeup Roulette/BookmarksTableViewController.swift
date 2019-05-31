//
//  BookmarksTableViewController.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 5/20/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import UIKit

class BookmarksTableViewController: UITableViewController {

    var bookmarkStore: BookmarkStore!
    
    var bookmarks = [Bookmark]()
    
    var dbHelper: BookmarkDBHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookmarkStore = BookmarkStore()
        
        bookmarks = bookmarkStore.allBookmarks
        
        dbHelper = BookmarkDBHelper()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bookmarks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath) as! BookmarkCell
        
        let bookmark = bookmarks[indexPath.row]
        let url = URL(string: bookmark.thumbnail)
        
        if url != nil {
            cell._bookmarkVideoThumbnail.load(url: url!)
        } else {
            cell._bookmarkVideoThumbnail.image = #imageLiteral(resourceName: "blackCircle")
        }
        cell._bookmarkVideoChannelTitle.text = bookmark.channelTitle
        cell._bookmarkVideoTitle.text = bookmark.title

        return cell
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bookmarkStore = BookmarkStore()
        
        bookmarks = bookmarkStore.allBookmarks
        
        tableView.reloadData()
    }

    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
 
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let dbConn = dbHelper.openConnection()
            var removedBookmark = bookmarks.remove(at: indexPath.row)
            
            dbHelper.removeBookmark(connection: dbConn, videoId: removedBookmark.videoId)
            dbHelper.closeConnection(db: dbConn)
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.reloadData()
        }
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
