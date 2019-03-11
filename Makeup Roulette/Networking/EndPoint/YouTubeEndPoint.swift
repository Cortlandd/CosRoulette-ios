//
//  UserEndPoint.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 3/8/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import Foundation

enum NetworkEnvironment {
    case development
    case production
    case testing
}

public enum YouTubeApi {
    case search(params: [String: Any])
}

extension YouTubeApi : EndPointType {
    
    var environmentBaseURL : String {
        switch NetworkManager.environment {
        case .development: return "https://www.googleapis.com/youtube/v3"
        case .production:  return "https://www.googleapis.com/youtube/v3"
        case .testing:     return "https://www.googleapis.com/youtube/v3"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.") }
        return url
    }
    
    var path: String {
        switch self {
        case .search:
            return "/search"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .search:
            return .get
        default:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .search(let params):
            
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: params
            )
            
        default:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
}