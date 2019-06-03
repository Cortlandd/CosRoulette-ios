//
//  ParameterEncoding.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 3/4/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import Foundation

public typealias Parameters = [String:Any]

public protocol ParameterEncoder {
    
    /*
     - urlRequest: inout defines an argument as a reference argument instead of a value like most functions
     - parameters:
     */
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

public enum ParameterEncoding {
    
    case urlEncoding
    case jsonEncoding
    case urlAndJsonEncoding
    
    public func encode(urlRequest: inout URLRequest, bodyParameters: Parameters?, urlParameters: Parameters?) throws {
        
        do {
            switch self {
            case .urlEncoding:
                guard let urlParameters = urlParameters else { return }
                try URLParameterEncoder.encode(urlRequest: &urlRequest, with: urlParameters)
                
            case .jsonEncoding:
                guard let bodyParameters = bodyParameters else { return }
                try JSONParameterEncoder.encode(urlRequest: &urlRequest, with: bodyParameters)
                
            case .urlAndJsonEncoding:
                guard let bodyParameters = bodyParameters,
                    let urlParameters = urlParameters else { return }
                try URLParameterEncoder.encode(urlRequest: &urlRequest, with: urlParameters)
                try JSONParameterEncoder.encode(urlRequest: &urlRequest, with: bodyParameters)
                
            }
        } catch {
            throw error
        }
    }
}

/*
 An enum used to pass custom errors instead of standard errors from xcode.
 */
public enum NetworkError : String, Error {
    
    case parametersNil = "Parameters were nil."
    
    case encodingFailed = "Parameter encoding failed."
    
    case missingUrl = "URL is nil"
    
}
