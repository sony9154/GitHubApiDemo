//
//  AccountService.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/7/7.
//

import Foundation

class AccountService {
    static var shared = AccountService()
    
    func getUsers(q: String,
                    completion: @escaping (Result<[User], Error>) -> Void) {
        APIService.shared.getUsers(q: q, page: 1, per_page: 100) { result in
            switch result {
            case .success(let users):
                completion(.success(users))
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
