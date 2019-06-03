//
//  NetworkRouter.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 3/8/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//
import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()

/*
 A NetworkRouter has an Endpoint which it uses to make requests
 and once the request is made it passes the response to the completion.
 
 - cancel() is used to be able to cancel requests at any point
 */
protocol NetworkRouter: class {
    
    // The router should be able to handle _ANY_ EndPointType
    associatedtype EndPoint: EndPointType
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
    
    func cancel()
    
}
