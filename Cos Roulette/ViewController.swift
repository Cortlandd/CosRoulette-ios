//
//  ViewController.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 3/4/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
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
    @IBOutlet weak var _cylinderImage:    UIImageView!
    @IBOutlet weak var _noFiltersText:    UILabel!
    @IBOutlet weak var _videoPlaceholderText: UITextView!
    @IBOutlet weak var _refBookmarkButton: UIButton!
    @IBOutlet weak var _cosCategoryRef: UIButton!
    
    @IBAction func _bookmarkButton(_ sender: Any) {
        
        var videoId = ""
        var title = ""
        var thumbnail = ""
        var channelTitle = ""
        
        _playerView.fetchVideoUrl { video in
            
            let dbConn = self.dbHelper.openConnection()
            
            if video != nil{
                let index = (video!.range(of: "=")?.upperBound)
                videoId = String(video!.suffix(from: index!))
            }
            
            let newdict = self.searchMap.filter { ($0["videoId"] as! String) == videoId }
            for i in newdict {
                videoId = i["videoId"] as! String
                thumbnail = i["thumbnails"] as! String
                title = i["title"] as! String
                channelTitle = i["channelTitle"] as! String
            }
            
            if self._refBookmarkButton.isSelected == false {
                self.dbHelper.addBookmark(connection: dbConn, videoId: videoId as NSString, title: title as NSString, thumbnail: thumbnail as NSString, channelTitle: channelTitle as NSString)
                self.dbHelper.closeConnection(db: dbConn)
                self._refBookmarkButton.isSelected = true
                return
            }
            
            if self._refBookmarkButton.isSelected == true {
                self.dbHelper.removeBookmark(connection: dbConn, videoId: videoId)
                self.dbHelper.closeConnection(db: dbConn)
                self._refBookmarkButton.isSelected = false
                return
            }
        }
    }
    
    @IBAction func _cosCategoryButton(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Select Category", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alertController.isModalInPopover = true
        
        let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        
        alertController.view.addSubview(pickerFrame)
        pickerFrame.dataSource = self
        pickerFrame.delegate = self
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self._cosCategoryRef.setTitle(self.cosCategoryValue, for: .normal)
            self.youtubeArray.removeAll()
            self.searchMap.removeAll()
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    // Array of string videoId's
    var youtubeArray = [String]()
    
    // Array of Categories for filter
    var cosCategories = ["Makeup", "Hair", "Skin", "Nails"]
    var cosCategoryValue = String() // Category picker value
    
    // Cos Category Picker View
    var pickerView = UIPickerView()
    
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
            print("Removed everything from youtube array and search map")
            self.youtubeArray.removeAll()
            self.searchMap.removeAll()
        }
    }
    
    // A variable to get access to bookmarkStore
    var bookmarkStore: BookmarkStore!
    
    // Reference to SQLite Database Manager
    var dbHelper: BookmarkDBHelper!
    
    // A variable to handle the NetworkManager
    var networkManager: NetworkManager!
    
    // A variable to handle Filter UserDefaults
    var filterDefaults: FilterDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _playerView.delegate = self
        
        // Placeholder text over player
        _playerView.bringSubviewToFront(_videoPlaceholderText)
        
        // Do any additional setup after loading the view, typically from a nib.
        networkManager = NetworkManager()
        
        // Initialize BookmarkStore
        bookmarkStore = BookmarkStore()
        
        filterDefaults = FilterDefaults()
        
        filters.append(contentsOf: filterDefaults.getFilters())
        
        // Initialize Bookmarks Database Helper
        dbHelper = BookmarkDBHelper()
        
        // Remove repeating rows at bottom of filter
        _tableView.tableFooterView = UIView()
        
        // Button Settings
        _refBookmarkButton.setImage(#imageLiteral(resourceName: "whiteBookmark"), for: .normal)
        _refBookmarkButton.setImage(#imageLiteral(resourceName: "blackBookmark"), for: .selected)
        
        // Set carousel styling, etc.
        //_carouselView.backgroundColor = UIColor.red
        //_carouselView.clipsToBounds = true
        _carouselView.type = .wheel
    
    }
    
    /*
     * Add button to add filters
     */
    @IBAction func AddFilterButton(_ sender: Any) {
        
        // Alert Controller. Set title and message
        let alertController = UIAlertController(title: "Add Filter", message: "Enter the name of the filter to add.", preferredStyle: .alert)
        
        // Create filter text field in alert
        alertController.addTextField { (textField) in
            textField.placeholder = "i.e. Black Women, Fenty, Alissa Ashley"
        }
        
        // MARK: Implement validation to not save if text is blank
        let confirmAction = UIAlertAction(title: "Save", style: .default) { (_) in
            
            let filterText = alertController.textFields?[0].text
            self.insertFilter(filterText: filterText!)
        
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    /*
     * Function used to append a filter to table view.
     */
    func insertFilter(filterText: String) {
        
        if filterText.description == "" {
            print("Add Video Text Field is empty")
        } else {
            
            filterDefaults.addFilter(filter: filterText.description)
            
            filters.removeAll()
            
            filters.append(contentsOf: filterDefaults.getFilters())

            let indexPath = IndexPath(row: filters.count, section: 0)
            
            _tableView.reloadData()
            
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
    
    func bookmarkValidation() {
        
        let dbConn = dbHelper.openConnection()
        var bookmarks = [Bookmark]()
        dbHelper.queryBookmarksList(db: dbConn).forEach { bookmark in
            bookmarks.append(bookmark)
        }
        dbHelper.closeConnection(db: dbConn)
        
        _playerView.fetchVideoUrl { video in
            let index = (video!.range(of: "=")?.upperBound)
            let currentVideo = String(video!.suffix(from: index!))
            
            //let newdict = self.searchMap.filter { ($0["videoId"] as! String) == videoId }
            
            if bookmarks.contains(where: { $0.videoId == currentVideo }) {
                self._refBookmarkButton.isSelected = true
                print("Is Bookmarked")
                return
            } else {
                self._refBookmarkButton.isSelected = false
                print("Is NOT Bookmarked")
                return

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
        
        self._refBookmarkButton.isHidden = true
        
        allFiltersText = getAllTableViewRowsText()
        
        let baseCategory = self._cosCategoryRef.titleLabel!.text
        allFiltersStringText = allFiltersText.joined(separator: " ")
        
        var randomVideo: String = ""
        
        var search_params = Parameters()
        
        var newMap = Parameters()
        
        search_params = [
            "q": "\(baseCategory!) \(allFiltersStringText)",
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
            
            filterDefaults.removeFilter(index: indexPath.row)
            
            filters.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            tableView.reloadData()
        }
        // After deleting a row, get the newly visible filters
        allFiltersText = getAllTableViewRowsText()
    }
    
}

extension ViewController: YoutubePlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YoutubePlayerView) {

        _refBookmarkButton.isHidden = false
        bookmarkValidation()
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
            _refBookmarkButton.isHidden = false
            print("Video")
        }
    }
    
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cosCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cosCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cosCategoryValue = cosCategories[row]
    }
    
    
}
