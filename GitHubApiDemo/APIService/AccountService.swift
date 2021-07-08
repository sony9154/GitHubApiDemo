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
                    completion: @escaping (Result<[User], Error>) -> Void) {
        APIService.shared.getUsers(q: q, page: pageIndex, per_page: pageSize) { result in
            switch result {
            case .success(let users):
                completion(.success(users))
            case .failure(let error):
                print(error)
            }
        }
    }
}
