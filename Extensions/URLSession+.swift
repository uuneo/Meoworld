//
//  URLSession+.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import Foundation


extension URLSession{
    enum APIError:Error{
        case invalidURL
        case invalidCode(Int)
    }
    
    
    func data(for urlRequest:URLRequest) async throws -> Data{
        let (data,response) = try await self.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else{ throw APIError.invalidURL }
        guard 200...299 ~= response.statusCode else {throw APIError.invalidCode(response.statusCode) }
        return data
    }
  
}



extension URLComponents{
    func getParams()-> [String:String]{
        var parameters = [String: String]()
        // 遍历查询项目并将它们添加到字典中
        if let queryItems = self.queryItems {
         
            for queryItem in queryItems {
                if let value = queryItem.value {
                    parameters[queryItem.name] = value
                }
            }
        }
        return parameters
    }
    
    func getParams(from params: [String: Any])-> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        return queryItems
    }
    
    
    
}



func == <T, Value: Equatable>( keyPath: KeyPath<T, Value>, value: Value) -> (T) -> Bool {
    { $0[keyPath: keyPath] == value }
}
