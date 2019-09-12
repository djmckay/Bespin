//
//  ResourceRequest.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import Foundation

enum GetResourcesRequest<ResourceType> {
    case success([ResourceType])
    case failure
}

enum GetResourceRequest<ResourceType> {
    case success(ResourceType)
    case failure
}

enum SaveResult<ResourceType> {
    case success(ResourceType)
    case failure
}

enum DeleteResult<ResourceType> {
    case success
    case failure
}

struct ResourceRequest<ResourceType> where ResourceType: Codable {
    let baseURL = "https://bespin-mail-api.vapor.cloud/api/"
    let resourceURL: URL
    
    init(resourcePath: String) {
        guard let resourceURL = URL(string: baseURL) else {
            fatalError()
        }
        self.resourceURL = resourceURL.appendingPathComponent(resourcePath)
    }
    
    func getAll(completion: @escaping (GetResourcesRequest<ResourceType>) -> Void) {
        var urlRequest = URLRequest(url: resourceURL)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authorization = DataManager.sharedInstance.basicAuthorization {
            urlRequest.addValue("Basic \(authorization)", forHTTPHeaderField: "Authorization")
        }
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let jsonData = data else {
                    completion(.failure)
                    return
            }
            do {
                let decoder = JSONDecoder()
                let resources = try decoder.decode([ResourceType].self, from: jsonData)
                completion(.success(resources))
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
    
    func save(_ resourceToSave: ResourceType, completion: @escaping (SaveResult<ResourceType>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let authorization = DataManager.sharedInstance.basicAuthorization {
                urlRequest.addValue("Basic \(authorization)", forHTTPHeaderField: "Authorization")
            }
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(resourceToSave)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    let jsonData = data else {
                        completion(.failure)
                        return
                }
                
                do {
                    let resource = try JSONDecoder().decode(ResourceType.self, from: jsonData)
                    completion(.success(resource))
                } catch {
                    completion(.failure)
                }
            }
            dataTask.resume()
        } catch {
            completion(.failure)
        }
    }
    
    func update(_ resourceToSave: ResourceType, completion: @escaping (SaveResult<ResourceType>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "PUT"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let authorization = DataManager.sharedInstance.basicAuthorization {
                urlRequest.addValue("Basic \(authorization)", forHTTPHeaderField: "Authorization")
            }
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let body = try encoder.encode(resourceToSave)
            print(body)
            urlRequest.httpBody = body
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    let jsonData = data else {
                        completion(.failure)
                        return
                }
                
                do {
                    let resource = try JSONDecoder().decode(ResourceType.self, from: jsonData)
                    completion(.success(resource))
                } catch {
                    completion(.failure)
                }
            }
            dataTask.resume()
        } catch {
            completion(.failure)
        }
    }
    
    func delete(_ completion: @escaping (DeleteResult<ResourceType>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "DELETE"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let authorization = DataManager.sharedInstance.basicAuthorization {
                urlRequest.addValue("Basic \(authorization)", forHTTPHeaderField: "Authorization")
            }
            
           
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 204,
                    let _ = data else {
                        completion(.failure)
                        return
                }
                
                do {
                    completion(.success)
                } 
            }
            dataTask.resume()
        }
    }
    
    
}
