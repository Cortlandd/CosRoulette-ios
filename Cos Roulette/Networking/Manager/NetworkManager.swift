//
//  NetworkManager.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 3/8/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import Foundation

enum NetworkResponse : String {
    
    case success
    case authenticationError = "You need to be authenticated first"
    case badRequest = "Bad Request"
    case failed = "Network Request failed"
    case noData = "Response returned with no data to decode"
    
}

enum Result<String> {
    case success
    case failure(String)
}

struct NetworkManager {
    static let environment : NetworkEnvironment = .development
    let youtubeAPIRouter = Router<YouTubeApi>()
    
    // Function for searching Query
    func searchVideoItems(params: Parameters, completion: @escaping (_ items: [Items]?, _ error: String?) -> ()) {
        
        youtubeAPIRouter.request(.search(params: params)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                print("Result: \(result)")
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    do {
                        
                        let searchApiResponse = try JSONDecoder().decode(YouTubeApiSearchResponse.self, from: responseData)
                        
                        completion(searchApiResponse.items, nil)
                    } catch {
                        completion(nil, "Unable to decode")
                    }
                    
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    // Function for searching for Related Videos to videoId
    func searchRelatedVideos(params: Parameters, completion: @escaping (_ items: [Items]?, _ error: String?) -> ()) {
        
        youtubeAPIRouter.request(.fetchRelatedVideos(params: params)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                print("Result: \(result)")
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    do {
                        let searchApiResponse = try JSONDecoder().decode(YouTubeApiSearchResponse.self, from: responseData)
                        
                        completion(searchApiResponse.items, nil)
                    } catch {
                        completion(nil, "Unable to decode")
                    }
                    
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
