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
    
    var baseURL: URL = URL(string:"https://itunes.apple.com")!
    
    var defaultHeaders: HTTPHeaders = [
        "Content-Type" : "application/json; charset=utf-8"
    ]
    
    func getUsers(q: String,
                 completion: @escaping(Result<[MediaItem], Error>) -> Void) {
        
        var urlComponents = URLComponents(string: "\(baseURL)/search")!
        urlComponents.queryItems = [
            URLQueryItem(name: "term", value: q)
        ]

        let url = urlComponents.url!
        let request = AF.request(url, method: .get,
                                 parameters: nil,
                                 headers: defaultHeaders)
                        .validate(statusCode: 200..<300)
        request.response { response in            print(response)
            switch response.result {
            case .success(let data):
                guard let data = data,
                      let dictionary = try? JSONSerialization.jsonObject(with: data, options: [])
                                            as? [String: Any] else  {
                    completion(.failure(APIError.error(with: response.data)))
                    return
                }
                
                guard let resultsArray = dictionary["results"] as? [[String: Any]] else {
                    completion(.failure(APIError.error(with: response.data)))
                    return
                }
                var mediaItems: [MediaItem] = []
                
                for resultData in resultsArray {
                    guard let trackId = resultData["trackId"] as? Int64 else {
                        continue
                    }
                    var item = MediaItem(id: trackId)
                    item.artistName = resultData["artistName"] as? String
                    item.artworkUrl100 = resultData["artworkUrl100"] as? String
                    item.longDescription = resultData["longDescription"] as? String
                    item.previewUrl = resultData["previewUrl"] as? String
                    mediaItems.append(item)
                }
                
                completion(.success(mediaItems))
                
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
