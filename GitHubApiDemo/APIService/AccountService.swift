//
//  AccountService.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/7/7.
//

import Foundation

class AccountService {
    static var shared = AccountService()
    
    func getMediaItems(query: String,
                    completion: @escaping (Result<[MediaItem], Error>) -> Void) {
        APIService.shared.getMediaItems(query: query) { result in
            switch result {
            case .success(let mediaItems):
                completion(.success(mediaItems))
            case .failure(let error):
                print(error)
            }
        }
    }
}
