//
//  AuthRegURLManager.swift
//  fefuactivity
//
//  Created by soFuckingHot on 13.12.2021.
//

import Foundation

//  Models

struct ActivityType: Decodable, Identifiable {
    let id: Int
    let name: String
}

struct GeoPoint: Decodable, Encodable {
    let lat: Float //  [-90;90] let's make func to work with it or make own smart object???
    let lon: Float //  [-180;180]
}

struct UserActivity: Decodable {
    let id: Int
    let createdAt: String
    let startsAt: String
    let endsAt: String
    let activityType: ActivityType
    let geoTrack: [GeoPoint]
    let user: UserModel
}

struct Gender: Decodable {
    let code: Int
    let name: String
}

struct UserLoginReq: Encodable {
    let login: String
    let password: String
}

struct UserResp: Decodable {
    let token: String
    let user: UserModel
}

struct UserRegBody: Encodable {
    let login: String
    let password: String
    let name: String
    let gender: Int
}


struct UserModel: Decodable, Identifiable {
    let id: Int
    let name: String
    let login: String
    let gender: Gender
}

class AuthRegUrlManager {
    
    static let instance = AuthRegUrlManager()
    
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    static let baseUrl = "https://fefu.t.feip.co/api"
    
    private init() {
        AuthRegUrlManager.encoder.keyEncodingStrategy = .convertToSnakeCase
        AuthRegUrlManager.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    static func createGet(url: URL) -> URLRequest{
        var req = URLRequest(url: url)
        
        req.addValue("Bearer " + AuthRegDataManager.intance.getKey(nameOfKey:
                                                                    AuthRegDataManager.userPublickKey)!, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return req
    }
    
    static func createPost(url: URL, body: Data?) -> URLRequest {
        var req = URLRequest(url: url)
        
        req.addValue("Bearer " + AuthRegDataManager.intance.getKey(nameOfKey:
                                                                    AuthRegDataManager.userPublickKey)!, forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        req.httpMethod = "POST"
        req.httpBody = body
        
        return req
    }
    
    static func login(_ body: Data,
               completion: @escaping ((UserResp) -> Void)) {
        
        guard let url = URL(string: baseUrl + "/auth/login") else {
            return //   URL! Andrew zapretil (ban!)
        }
        
        var urlReq = URLRequest(url: url)
        
        urlReq.httpMethod = "POST"
        urlReq.httpBody = body
        urlReq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlReq) { data, response, error in
            
            guard let data = data else {
                return
            }
            do {
                let userData = try AuthRegUrlManager.decoder.decode(UserResp.self, from: data)
                completion(userData)
                return
            } catch _ {
                if let res = response as? HTTPURLResponse {
                    print("Eror:", res.statusCode)
                } else {
                    print("Something very very bad")
                }
            }
            
        }
        
        task.resume()
    }
    
    static func reg(_ body: Data,
                    completion: @escaping ((UserResp) -> Void)) {
        
        guard let url = URL(string: "https://fefu.t.feip.co/api/auth/register") else {
            return
        }
        
        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "POST"
        urlReq.httpBody = body
        urlReq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlReq) { data, response, error in
            
            guard let data = data else {
                return
            }
            do {
                let userData = try AuthRegUrlManager.decoder.decode(UserResp.self, from: data)
                completion(userData)
            } catch _ {
                if let res = response as? HTTPURLResponse {
                    print("Eror:", res.statusCode)
                } else {
                    print("Something very very bad")
                }
                
            }
        }
        
        task.resume()
    }
    
    static func logout(completion: @escaping (()-> Void)) {
        guard let url = URL(string: baseUrl + "/auth/logout") else { return }
        
        let req = createPost(url: url, body: nil)
        let session = URLSession.shared
        
        let task = session.dataTask(with: req) { data, response, error in
            guard let res = response as? HTTPURLResponse else { return }
            
            switch res.statusCode {
            case 200:
                completion()
            default:
                print(res.statusCode)
                break
            }
        }
        
        task.resume()
    }
    
    static func profile(completion: @escaping ((UserModel)-> Void)) {
        guard let url = URL(string: baseUrl + "/user/profile") else {return}
        
        let req = createGet(url: url)
        
        let session = URLSession.shared
        
        
        
        let task = session.dataTask(with: req) { data, response, error in
            
            guard let res = response as? HTTPURLResponse else {return}
            
            guard let data = data else {return}
            
            switch res.statusCode {
            case 200:
                do {
                    let decodedData = try AuthRegUrlManager.decoder.decode(UserModel.self, from: data)
                    completion(decodedData)
                } catch _ {
                    print("Error \(res.statusCode)")
                }
            default:
                print(res.statusCode)
            }
        }
        
        task.resume()
    }
}
    

