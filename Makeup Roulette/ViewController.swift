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
    
    @IBOutlet var _playerView: YoutubePlayerView!
    @IBOutlet var _tableView: UITableView!
    var youtubeArray = [String]()
    

    @IBAction func AddFilterButton(_ sender: Any) {
    }
    
    var API_KEY: String = "AIzaSyB3sP8V6Ufg0BUaf7YntWUv1aygEAP2lfQ"
    
    var networkManager: NetworkManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        networkManager = NetworkManager()
    }
    
    @IBAction func _getVideo(_ sender: Any) {
        
        let search_params: Parameters = [
            "q": "makeup tutorials",
            "part": "id,snippet",
            "key": API_KEY,
            "safeSearch": "none",
            "type": "video"
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
                    self._playerView.loadWithVideoId(self.youtubeArray.randomElement()!)
                }
            }
            
        } else {
            
            // Get random element
            var randomEl = self.youtubeArray.randomElement()
            
            // Play video of random array
            self._playerView.loadWithVideoId(randomEl!)
            
            // Get random element position
            var index = self.youtubeArray.firstIndex(of: randomEl!)
            
            // Remove random element from list
            self.youtubeArray.remove(at: index!)
            
            // Print remaining videos
            print(self.youtubeArray.description)
            
        }
    }
    
    
}

