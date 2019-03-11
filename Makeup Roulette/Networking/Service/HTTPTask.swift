//
//  HTTPTask.swift
//  Fedha
//
//  Created by Cortland Walker on 2/26/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String:String]

/*
   Responsible for configuring parameters for a specific endPoint.
 */
public enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?, urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?, urlParameters: Parameters?, additionalHeaders: HTTPHeaders?)
    
    // case download, upload...etc
}
