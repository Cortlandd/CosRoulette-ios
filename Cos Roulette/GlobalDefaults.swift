//
//  GlobalDefaults.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 6/6/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import Foundation

struct GlobalDefaults {
    
    init() {
        defaults.register(defaults: [cosCategoryDefaults : 0])
    }
    
    private let defaults = UserDefaults.standard
    
    private let cosCategoryDefaults = "CosCategoryDefault"
    
    func setSelectedCategory(selected: Int) {
        defaults.set(selected, forKey: cosCategoryDefaults)
    }
    
    func getSelectedCategory() -> Int {
        let selected = defaults.integer(forKey: cosCategoryDefaults)
        return selected
    }
    
}
