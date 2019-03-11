//
//  ViewController.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 3/4/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
        
        networkManager.searchVideoItems(params: search_params) { items, error in
            
            var r = [String]()
            
            if let error = error {
                print(error)
            }
            
            if let items = items {
                print(items)
            }
            
        }
        
    }


}

