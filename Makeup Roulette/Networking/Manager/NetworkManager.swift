//
//  NetworkManager.swift
//  Fedha
//
//  Created by Cortland Walker on 2/26/19.
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
    let userRouter = Router<UserApi>()
    
    /*
     Pass in the email, password, and a completion which returns
     an optional User model object or optional error message
     */
    func login(email: String, password: String, completion: @escaping (_ user: User?, _ error: String?) ->()) {
        
        userRouter.request(.login(email: email, password: password)) { data, response, error in
            // URLSession returns an error if there is no network connectivity
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            // Assign response to HTTPURLResponse so we can access the statusCode property
            if let response = response as? HTTPURLResponse {
                
                //  Handling the result of the request in a switch statement
                let result = self.handleNetworkResponse(response)
                switch result {
                
                case .success:
                    
                    // If the result is has no data exit the login method
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    // If the result has data, decode the data to the model, passto completion
                    do {
                        let loginApiResponse = try JSONDecoder().decode(UserLoginResponse.self, from: responseData)
                        completion(loginApiResponse.user, nil)
                    } catch {
                        completion(nil, "Unable to decode")
                    }
                // 8
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func register(name: String, email: String, password: String, password_confirmation: String, completion: @escaping (_ user: User?, _ error: String?) -> ()) {
        
        userRouter.request(.register(email: email, name: name, password: password, password_confirmation: password_confirmation)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let registerApiResponse = try JSONDecoder().decode(UserRegisterResponse.self, from: responseData)
                        completion(registerApiResponse.user, nil)
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
