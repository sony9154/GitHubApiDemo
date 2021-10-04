//
//  AccountService.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/7/7.
//

import Foundation

class AccountService {
    static var shared = AccountService()
    
    func getUsers(q: String, pageIndex: Int, pageSize: Int,
                    completion: @escaping (Result<[MediaItem], Error>) -> Void) {
        APIService.shared.getUsers(q: q) { result in
            switch result {
            case .success(let mediaItems):
                completion(.success(mediaItems))
            case .failure(let error):
                print(error)
            }
        }
    }
}
