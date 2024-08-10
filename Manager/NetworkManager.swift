//
//  NetworkManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import Foundation


class NetworkManager{
    static let shared = NetworkManager()
    
    private let session = URLSession(configuration: .default)
    
    func fetch<T:Codable>(url:String) async throws -> T?{
        guard let requestUrl = URL(string: url) else {return  nil}
        let data = try await session.data(for: URLRequest(url: requestUrl))
        let result = try JSONDecoder().decode(baseResponse<T>.self, from: data)
        return result.data
    }
    
    func fetchRaw<T:Codable>(url:String) async throws -> T?{
        guard let requestUrl = URL(string: url) else {return  nil}
        let data = try await session.data(for: URLRequest(url: requestUrl))
        let result = try JSONDecoder().decode(T.self, from: data)
        return result
    }
    
    func fetchVoid(url:String) async-> Bool {
        guard let requestUrl = URL(string: url) else { return false }
        do{
            _ = try await session.data(for: URLRequest(url: requestUrl))
            return true
        }catch{
           return false
        }
        
    }
    
    func fetch<T:Codable>(_ url:String) async throws -> T?{
        guard let requestUrl = URL(string: url) else {return  nil}
        let data = try await session.data(for: URLRequest(url: requestUrl))
        let result = try JSONDecoder().decode(T.self, from: data)
        return result
    }
}
