//
//  ViewController.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 3/4/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import UIKit
import YoutubePlayerView

class ViewController: UIViewController {
    
    var youtubeArray = [String]()
    
    var API_KEY: String = "AIzaSyB3sP8V6Ufg0BUaf7YntWUv1aygEAP2lfQ"
    
    var filters = [String]()
    
    var networkManager: NetworkManager!
    
    var allFiltersText = [String]()
    
    @IBOutlet var _playerView: YoutubePlayerView!
    @IBOutlet var _tableView: UITableView!
    @IBOutlet weak var _addFilterText: UITextField!
    
    @IBAction func AddFilterButton(_ sender: Any) {
        insertFilter()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        networkManager = NetworkManager()
        
        // Remove repeating rows at bottom of filter
        _tableView.tableFooterView = UIView()
    }
    
    @IBAction func _getVideo(_ sender: Any) {
        
        // Assign the search query based on the filters
        allFiltersText = getAllTableViewRowsText()
        let allFiltersStringText = allFiltersText.joined(separator: " ")
        
        var search_params = Parameters()
        
        if allFiltersStringText.isEmpty {
            search_params = [
                "q": "makeup tutorials",
                "part": "id,snippet",
                "key": API_KEY,
                "safeSearch": "none",
                "type": "video"
            ]
        } else {
            search_params = [
                "q": "makeup tutorials \(allFiltersStringText)",
                "part": "id,snippet",
                "key": API_KEY,
                "safeSearch": "none",
                "type": "video"
            ]
        }
        
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
        
    }
    
}
