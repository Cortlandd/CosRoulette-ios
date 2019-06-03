//
//  JSONParameterEncoder.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 3/4/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import Foundation

public struct JSONParameterEncoder: ParameterEncoder {
    
    /*
     Encoding the parameters to JSON and adding the appropriate headers.
     */
    public static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            
            urlRequest.httpBody = jsonAsData
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw NetworkError.encodingFailed
        }
    }
    
}
