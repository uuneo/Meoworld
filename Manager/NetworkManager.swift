//
//  NetworkManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import Foundation


class NetworkManager{
    static let shared = NetworkManager()
    
    private init() {}
    
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



extension NetworkManager{
    enum RequestError: Error {
        case urlError
        case rquestError
        case jsonError
    }
    
    func get<T:Codable>(_ url: String,
             params: [String: Any]? = nil,
             headers: [String: String]? = nil
    ) async -> Result<T, RequestError>{
        
        let response  = await fetch(url, params: params, headers: headers)
        
        switch response {
        case .success(let data):
            do{
                let jsonData = try JSONDecoder().decode(T.self, from: data)
                return .success(jsonData)
            }catch{
                return .failure(.jsonError)
            }
        case .failure(_):
            return .failure(.rquestError)
            
        }
        
    }
    
    
    
    
    
    
    func fetch(
            _ url: String,
            params: [String: Any]? = nil,
            headers: [String: String]? = nil,
            body: Data? = nil,
            method: String = "GET"
        ) async  -> Result<Data, RequestError> {
            
            // Construct the URL with parameters
            guard var urlComponents = URLComponents(string: url) else { return .failure(.urlError) }
           
            
            if let params = params {
                urlComponents.queryItems = urlComponents.getParams(from: params)
            }
            guard let finalUrl = urlComponents.url else { return .failure(.urlError) }
            
            // Create URLRequest and configure it
            var request = URLRequest(url: finalUrl)
            request.httpMethod = method
            
            // Add headers
            if let headers = headers {
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
            
            // Set body if provided
            if let body = body {
                request.httpBody = body
            }
            do{
                // Perform the request
                let data = try await session.data(for: request)
                return .success(data)
                
            }catch{
                return .failure(.rquestError)
            }
            
           
 
            
        }
}
