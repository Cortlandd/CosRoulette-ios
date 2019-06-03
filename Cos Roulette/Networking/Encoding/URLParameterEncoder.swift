//
//  URLParameterEncoder.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 3/4/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import Foundation

public struct URLParameterEncoder: ParameterEncoder {
    
    /*
     Here, encode takes parameters and makes them safe to be passed as URL parameters.
     */
    public static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        guard let url = urlRequest.url else { throw NetworkError.missingUrl }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                
                urlComponents.queryItems?.append(queryItem)
                
                print("QueryItem: \(queryItem.description)")
            }
            
            urlRequest.url = urlComponents.url
            
        }
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
    
 
    
}

