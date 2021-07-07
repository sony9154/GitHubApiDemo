//
//  APIService.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/7/7.
//

import Foundation
import Alamofire

class APIService {
    static var shared = APIService()
    
    var accessToken: String?
    var idToken: String?
    var refreshToken: String?
    
    var baseURL: URL = URL(string:"https://api.github.com")!
    
    var defaultHeaders: HTTPHeaders = [
        "Accept" : "application/vnd.github.v3+json",
        "Content-Type" : "application/json; charset=utf-8"
    ]
    
    func getUsers(q: String, page: Int, per_page: Int,
                 completion: @escaping(Result<[User], Error>) -> Void) {
        
        var params: [String: Any] = [:]
        params["q"] = q
        params["page"] = page
        params["per_page"] = per_page
        
        let url = baseURL.appendingPathComponent("/search/users")
        let request = AF.request(url, method: .get,
                                 parameters: params,
                                 headers: defaultHeaders)
                        .validate(statusCode: 200..<300)
        request.response { response in
            print(response)
            switch response.result {
            case .success(let data):
                guard let data = data,
                      let dictionary = try? JSONSerialization.jsonObject(with: data, options: [])
                                            as? [String: Any] else  {
                    completion(.failure(APIError.error(with: response.data)))
                    return
                }
                
                guard let usersArray = dictionary["items"] as? [[String: Any]] else {
                    completion(.failure(APIError.error(with: response.data)))
                    return
                }
                var users: [User] = []
                
                for userData in usersArray {
                    guard let userID = userData["id"] as? Int64 else {
                        continue
                    }
                    var user = User(id: userID)
                    user.accountName = userData["login"] as? String
                    user.avatar = userData["avatar_url"] as? String
                    
                    users.append(user)
                }
                
                completion(.success(users))
                
            case .failure(let error):
                completion(.failure(APIError.error(with: response.data,
                                                   fallback: error)))
            }
        }
    }
    

}


// MARK: - Type Definitio
enum APIError: String, Error {
    case accessTokenIsNil
    case dataNotFound = "100001"    // 查無資料
    case userNotFound = "200001"    // 用戶不存在
    case undefined
    
    // MARK: - Helpers
    static func apiError(with responseData: Data?) -> APIError? {
        if let data = responseData,
           let dictionary = try? JSONSerialization.jsonObject(with: data, options: [])
                                    as? [String: Any],
           let code = dictionary["code"] as? String,
           let apiError = APIError(rawValue: code) {
            return apiError
        } else {
            return nil
        }
    }
    
    static func error(with responseData: Data?, fallback: Error? = nil) -> Error {
        if let data = responseData,
           let dictionary = try? JSONSerialization.jsonObject(with: data, options: [])
                                    as? [String: Any],
           let code = dictionary["code"] as? String,
           let apiError = APIError(rawValue: code) {
            return apiError
        } else {
            return fallback ?? DummyError()
        }
    }
}

struct DummyError: Error {
}
