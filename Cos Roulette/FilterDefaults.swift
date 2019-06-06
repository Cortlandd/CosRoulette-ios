//
//  FilterDefaults.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 6/5/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import Foundation

struct FilterDefaults {
    
    private let defaults = UserDefaults.standard
    private let filterListDefaults = "FilterListDefaults"
    
    func addFilter(filter: String) {
        var filters = getFilters()
        if filters == nil {
            filters = [String]()
        }
        filters.append(filter)
        defaults.set(filters, forKey: filterListDefaults)
        
    }
    
    func removeFilter(index: Int) {
        var filters = getFilters()
        
        if filters != nil {
            filters.remove(at: index)
            defaults.set(filters, forKey: filterListDefaults)
        }
        print("Remaining Filters: \(filters.description)")
    }
    
    func getFilters() -> [String] {
        var filters = [String]()
        
        if (defaults.stringArray(forKey: filterListDefaults) != nil) {
            let allFilters = defaults.stringArray(forKey: filterListDefaults)
            for i in allFilters! {
                filters.append(i)
            }
        }
        
        print(filters.description)
        return filters
    }
    
    func jsonToString(json: AnyObject) {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print(convertedString ?? "defaultvalue")
        } catch let myJSONError {
            print(myJSONError)
        }
        
    }
    
    func convertIntoJSONString(arrayObject: [Any]) -> String? {
        
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: arrayObject, options: [])
            if  let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
                return jsonString as String
            }
            
        } catch let error as NSError {
            print("Array convertIntoJSON - \(error.description)")
        }
        return nil
    }
    
}
