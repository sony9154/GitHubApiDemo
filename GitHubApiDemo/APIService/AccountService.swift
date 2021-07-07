//
//  AccountService.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/7/7.
//

import Foundation

class AccountService {
    static var shared = AccountService()
    
    var currentPage: Int = 1
    let pageIndex = 1
    let pageSize = 30
    var users = [User]()
    var searchText: String?
    
    func getUsers(q: String,
                    completion: @escaping (Result<[User], Error>) -> Void) {
        self.searchText = q
        self.currentPage = 1
        APIService.shared.getUsers(q: q, page: pageIndex, per_page: pageSize) { result in
            switch result {
            case .success(let users):
                self.currentPage = (users.count / self.pageSize) + 1
                self.users = users
                completion(.success(users))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func getMoreUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let pageIndex = currentPage 
        guard let text = self.searchText else { return }
        APIService.shared.getUsers(q: text, page: pageIndex, per_page: pageSize) { result in
            switch result {
            case .success(let fetchedUsers):
                var users = self.users 
                let fetchedUsers = fetchedUsers.filter { user in
                    !users.contains(where: { $0.id == user.id })
                }
                users.append(contentsOf: fetchedUsers)
                self.users = users
                self.currentPage = (users.count / self.pageSize) + 1
                completion(.success(users))
            case.failure(let error):
                print(error)
            }
        }
    }
    
}
