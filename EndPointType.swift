//
//  EndPointType.swift
//  Cos Roulette
//
//  Created by Cortland Walker on 3/8/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//
import Foundation

/**
 This protocol will contain all information to configure an EndPoint.
 Comprising of components such as headers, query parameters, and body parameters.
 */
protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}
