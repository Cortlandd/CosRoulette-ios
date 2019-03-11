//
//  Router.swift
//  Fedha
//
//  Created by Cortland Walker on 2/26/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import Foundation

class Router<EndPoint: EndPointType>: NetworkRouter {
    
    // This task is essentially what will do all the work as far as requests
    private var task: URLSessionTask?
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        do {
            let request = try self.buildRequest(from: route)
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                completion(data, response, error)
            })
        } catch {
            completion(nil, nil, nil)
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    /*
     Function responsible for converting EndPointType to URLRequest. Once the EndPoint is
     a request, it is passed to the session.
     */
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        
        var request = URLRequest(
            url: route.baseURL.appendingPathComponent(route.path),
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10.0
        )
        
        request.httpMethod = route.httpMethod.rawValue
        
        do {
            
            switch route.task {
                
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            case .requestParameters(let bodyParameters, let urlParameters):
                try self.configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
                
                
            case .requestParametersAndHeaders(let bodyParameters, let urlParameters, let additionalHeaders):
                self.addAdditionalHeaders(additionalHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
            }
            return request
        } catch {
            throw error
        }
        
    }

    /*
     Responsible for encoding parmeters. Since the API is expecting bodyParameters as JSON and URLParameters
     to be URL encoded, we only need to pass the appropriate parameters to the designed encoder.
     */
    fileprivate func configureParameters(bodyParameters: Parameters?, urlParameters: Parameters?, request: inout URLRequest) throws {
        
        do {
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters = urlParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
        
    }
    
    /*
     Add additional headers to request header
     */
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

}
