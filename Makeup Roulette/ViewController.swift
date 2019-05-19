//
//  ViewController.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 3/4/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import UIKit
import YoutubePlayerView
import SQLite3

class ViewController: UIViewController, iCarouselDelegate, iCarouselDataSource {
    
    var items: [Int] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for i in 1...6 {
            items.append(i)
        }
    }
    
    @IBOutlet weak var _carouselView:     iCarousel!
    @IBOutlet var      _playerView:       YoutubePlayerView!
    @IBOutlet var      _tableView:        UITableView!
    @IBOutlet weak var _addFilterText:    UITextField!
    @IBOutlet weak var _cylinderImage:    UIImageView!
    @IBOutlet weak var _noFiltersText:    UILabel!
    @IBOutlet weak var _videoPlaceholderText: UITextView!
    @IBOutlet weak var _refBookmarkButton: UIButton!
    
    
    @IBAction func _bookmarkButton(_ sender: Any) {
        
        let dbConn = self.dbHelper.openConnection()
        
        var videoId = ""
        var title = ""
        var thumbnail = ""
        var channelTitle = ""
        
        _playerView.fetchVideoUrl { video in
            if video != nil{
                let index = (video!.range(of: "=")?.upperBound)
                videoId = String(video!.suffix(from: index!))
                let newdict = self.searchMap.filter { ($0["videoId"] as! String) == videoId }
                for i in newdict {
                    videoId = i["videoId"] as! String
                    thumbnail = i["thumbnails"] as! String
                    title = i["title"] as! String
                    channelTitle = i["channelTitle"] as! String
                }
                self.dbHelper.addBookmark(connection: dbConn, videoId: videoId, title: title, thumbnail: thumbnail, channelTitle: channelTitle)
                self.dbHelper.closeConnection(db: dbConn)
            }
        }
    
        
    }
    
    // Array of string videoId's
    var youtubeArray = [String]()
    
    // A Dictionary of youtube search results
    var searchMap = [Dictionary<String, Any>]()
    
    // YouTube API Key
    var API_KEY: String = "AIzaSyB3sP8V6Ufg0BUaf7YntWUv1aygEAP2lfQ"
    
    // The list of filters inside the Filters Table
    var filters = [String]()
    
    // String representation of the filters created in the tableview. Separated with a space.
    var allFiltersStringText: String = ""
    
    // List representing all filters added to the tableview.
    var allFiltersText = [String]() {
        // If a new row is inserted or deleted delete the youtube array to start a new search
        willSet {
            print("Removed everything from youtube array because filters changed.")
            self.youtubeArray.removeAll()
        }
    }
    
    var dbHelper: BookmarkDBHelper!
    
    // A variable to handle the NetworkManager
    var networkManager: NetworkManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss Keyboard on touch outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        _playerView.delegate = self
        
        // Placeholder text over player
        _playerView.bringSubviewToFront(_videoPlaceholderText)
        
        // Do any additional setup after loading the view, typically from a nib.
        networkManager = NetworkManager()
        
        // Initialize Bookmarks Database Helper
        dbHelper = BookmarkDBHelper()
        let conn = dbHelper.openConnection()
        let b = dbHelper.queryBookmarksList(db: conn)
        b.forEach { bookmark in
            print(bookmark)
        }
        
        // Remove repeating rows at bottom of filter
        _tableView.tableFooterView = UIView()
        
        // Set carousel styling, etc.
        //_carouselView.backgroundColor = UIColor.red
        //_carouselView.clipsToBounds = true
        _carouselView.type = .wheel
    
    }
    
    /*
     * Add button to add filters
     */
    @IBAction func AddFilterButton(_ sender: Any) {
        insertFilter()
    }
    
    /*
     * Function used to drop down Keyboard when touching outside in _addFilterText
     */
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        _addFilterText.resignFirstResponder()
    }
    
    /*
     * Function used to append a filter to table view.
     */
    func insertFilter() {
        
        if _addFilterText.text == "" {
            print("Add Video Text Field is empty")
        } else {
            filters.append(_addFilterText.text!)
            
            let indexPath = IndexPath(row: filters.count - 1, section: 0)
            
            _tableView.beginUpdates()
            _tableView.insertRows(at: [indexPath], with: .automatic)
            _tableView.endUpdates()
            
            _addFilterText.text = ""
            view.endEditing(true)
            
            // After inserting a new row, get the newly visible filters
            allFiltersText = getAllTableViewRowsText()
            
            _tableView.isHidden = false
        }
    }
    
    /*
     * Function for finding related videos
     */
    func fetchRelatedVideos(videoId: String) {
        
        var related_params = Parameters()
        
        related_params = [
            "key": API_KEY,
            "part": "id",
            "type": "video",
            "maxResults": 20,
            "relatedToVideoId": videoId
        ]
        
        networkManager.searchRelatedVideos(params: related_params) { items, error in
            
            if let error = error {
                print(error)
            }
            
            if let items = items {
                for item in items {
                    self.youtubeArray.append(item.id.videoId)
                }
            }
        }
    }
    
    /*
     * For each visible tablecell, put the text into an array and return it
     */
    func getAllTableViewRowsText() -> [String] {
        var r = [String]()
        
        for cell in _tableView.visibleCells as! [FilterCell] {
            r.append(cell._filterText.text!)
        }
        return r
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return items.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        var imageView: UIImageView
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        //imageView.image = UIImage(named: "blackCircle.png")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
        
    }
    
    func carouselWillBeginDecelerating(_ carousel: iCarousel) {
        print("Started spinning")
    }
    
    func carouselDidEndDecelerating(_ carousel: iCarousel) {
        
        searchVideo()
    }
    
    func searchVideo() {
        
        allFiltersStringText = allFiltersText.joined(separator: " ")
        
        var randomVideo: String = ""
        
        var search_params = Parameters()
        var newMap = Parameters()
        
        search_params = [
            "q": "makeup tutorials \(allFiltersStringText)",
            "part": "id,snippet",
            "key": API_KEY,
            "safeSearch": "none",
            "type": "video"
        ]
        
        let playerVars: [String: Any] = [
            "controls": 1,
            "modestBranding": 1,
            "playsinline": 1,
            "rel": 0,
            "autoplay": 1
        ]
        
        if self.youtubeArray.isEmpty {
            
            networkManager.searchVideoItems(params: search_params) { items, error in
                
                if let error = error {
                    print(error)
                }
                
                if let items = items {
                    for item in items {
                        newMap = [
                            "videoId": item.id.videoId,
                            "title": item.snippet.title,
                            "thumbnails": item.snippet.thumbnails.medium.url,
                            "channelTitle": item.snippet.channelTitle
                        ]
                        
                        self.searchMap.append(newMap)
                        
                    }
                    
                    // Append VideoIds from searchMap to youtubeArray
                    for all in self.searchMap {
                        for i in all {
                            if i.key == "videoId" {
                                self.youtubeArray.append(i.value as! String)
                            }
                        }
                    }
                    
                }
                
                // Get random videoId
                randomVideo = self.youtubeArray.randomElement()!
                // Play @ random videoId
                self._playerView.loadWithVideoId(randomVideo, with: playerVars)
                // Get random element position
                let index = self.youtubeArray.firstIndex(of: randomVideo)
                // Remove random element from list
                self.youtubeArray.remove(at: index!)
                // Print remaining videos
                print(self.youtubeArray.description)
                
            }
            
        } else {
            
            // Get random videoId from youtubeArray
            let randomVideo = self.youtubeArray.randomElement()
            
            // Play video of random array
            self._playerView.loadWithVideoId(randomVideo!, with: playerVars)
            
            // Get random element position
            let index = self.youtubeArray.firstIndex(of: randomVideo!)
            
            // Remove random element from list
            self.youtubeArray.remove(at: index!)
            
            // Print remaining videos
            print(self.youtubeArray.description)
            
        }
        
        _videoPlaceholderText.isHidden = true
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .spacing {
            return value * 1.0
        }
        return value
    }
    
    func carouselDidScroll(_ carousel: iCarousel) {
        let scroll: CGFloat = carousel.scrollOffset
        let rotPercentage = scroll / CGFloat(carousel.numberOfVisibleItems)
        _cylinderImage.transform = CGAffineTransform(rotationAngle: 2 * .pi * -rotPercentage)
        
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filters.count > 0 {
            _noFiltersText.isHidden = true
        }
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let filterTitle = filters[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell") as! FilterCell
        cell._filterText.text = filterTitle
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            filters.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        // After deleting a row, get the newly visible filters
        allFiltersText = getAllTableViewRowsText()
    }
    
}

extension ViewController: YoutubePlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YoutubePlayerView) {
        _refBookmarkButton.isHidden = false
    }

    func playerView(_ playerView: YoutubePlayerView, didChangedToState state: YoutubePlayerState) {
        switch state {
        case .unknown:
            print("Unknown")
            _refBookmarkButton.isHidden = true
            searchVideo()
        case .unstarted:
            print("Unstarted")
            _refBookmarkButton.isHidden = true
            searchVideo()
        case .ended:
            print("Ended")
            searchVideo()
        case .buffering:
            print("Buffering")
        default:
            print("Video")
        }
    }
    
}
