//
//  HTTPTask.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 3/8/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String:String]

/*
 Responsible for configuring parameters for a specific endPoint.
 */
public enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?, bodyEncoding: ParameterEncoding, urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?, bodyEncoding: ParameterEncoding, urlParameters: Parameters?, additionalHeaders: HTTPHeaders?)
    
    // case download, upload...etc
}
