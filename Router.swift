//
//  Router.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 3/8/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//
import Foundation

class Router<EndPoint: EndPointType>: NetworkRouter {
    
    // This task is essentially what will do all the work as far as requests
    private var task: URLSessionTask?
    private let session = URLSession(configuration: .default)
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        
        do {
            let request = try self.buildRequest(from: route)
            NetworkLogger.log(request: request)
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                completion(data, response, error)
            })
        } catch {
            completion(nil, nil, error)
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
                
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters
                ):
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request
                )
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders
                ):
                
                self.addAdditionalHeaders(additionalHeaders, request: &request)
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request
                )
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
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        
        do {
            try bodyEncoding.encode(urlRequest: &request, bodyParameters: bodyParameters, urlParameters: urlParameters)
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
