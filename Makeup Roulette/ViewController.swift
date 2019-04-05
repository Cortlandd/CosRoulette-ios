//
//  ViewController.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 3/4/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import UIKit
import YoutubePlayerView

class ViewController: UIViewController, iCarouselDelegate, iCarouselDataSource {
    
    var items: [Int] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for i in 0...6 {
            items.append(i)
        }
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return items.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var imageView: UIImageView
        
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imageView.image = UIImage(named: "blackCircle.png")
        imageView.contentMode = .scaleAspectFit
    
        return imageView
        
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .spacing {
            print(value)
            return value * 1.1
        }
        return value
    }
    
    
    @IBOutlet weak var _carouselView: iCarousel!
    @IBOutlet var _playerView: YoutubePlayerView!
    @IBOutlet var _tableView: UITableView!
    @IBOutlet weak var _addFilterText: UITextField!
    
    
    
    // Array of string videoId's
    var youtubeArray = [String]()
    
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
            print("Removed everything from youtube array")
            youtubeArray.removeAll()
        }
        
    }
    
    // A variable to handle the NetworkManager
    var networkManager: NetworkManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss Keyboard on touch outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view, typically from a nib.
        networkManager = NetworkManager()
        
        // Remove repeating rows at bottom of filter
        _tableView.tableFooterView = UIView()
        
        //let targetRadius: CGFloat = (_carouselView.layer.cornerRadius == 0.0) ? 100.0 : 0.0
        
        _carouselView.backgroundColor = UIColor.red
        //_carouselView.layer.cornerRadius = targetRadius
        _carouselView.clipsToBounds = true
        _carouselView.type = .wheel
    
    }
    
    
    
    @IBAction func AddFilterButton(_ sender: Any) {
        insertFilter()
    }
    
    @IBAction func _getVideo(_ sender: Any) {
        
        allFiltersStringText = allFiltersText.joined(separator: " ")

        var search_params = Parameters()
        
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
                        self.youtubeArray.append(item.id.videoId)
                    }
                    print(self.youtubeArray)
                    self._playerView.loadWithVideoId(self.youtubeArray.randomElement()!, with: playerVars)
                }
            }
            
        } else {
            
            // Get random element
            let randomEl = self.youtubeArray.randomElement()
            
            // Play video of random array
            self._playerView.loadWithVideoId(randomEl!, with: playerVars)
            
            // Get random element position
            let index = self.youtubeArray.firstIndex(of: randomEl!)
            
            // Remove random element from list
            self.youtubeArray.remove(at: index!)
            
            // Print remaining videos
            print(self.youtubeArray.description)
            
        }
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
     * For each visible tablecell, put the text into an array and return it
     */
    func getAllTableViewRowsText() -> [String] {
        var r = [String]()
        
        for cell in _tableView.visibleCells as! [FilterCell] {
            r.append(cell._filterText.text!)
        }
        return r
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
