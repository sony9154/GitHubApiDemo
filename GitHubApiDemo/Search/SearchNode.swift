//
//  SearchNode.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/7/8.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class SearchNode: Node {
    // MARK: - Store
    var searchText = RxVar<String?>(nil)
    var users = RxVar<[User]?>(nil)
    var currentPage = RxVar<Int?>(nil)
    var busyFetchingMoreUsers = RxVar<Bool>(false)
    
    // MARK: - Action
    enum Action {
        case setSearchText(text: String?)
        case fetchUsers(q: String)
        case fetchMoreUsers
    }
    
    func act(_ action: Action, done: ActionCompletion? = nil) {
        switch action {
        case .setSearchText(let text):
            searchText.accept(text)
            act(.fetchUsers(q: text ?? ""))
            done?()
        case .fetchUsers(let q):
            busyFetchingMoreUsers.accept(true)
            
            let pageIndex = 1
            let pageSize = 30
            AccountService.shared.getUsers(q: q, pageIndex: pageIndex, pageSize: pageSize) { [weak self] result in
                self?.busyFetchingMoreUsers.accept(false)
                switch result {
                case .success(let users):
//                    self.currentPage = (users.count / self.pageSize) + 1
                    self?.users.accept(users)
                    self?.currentPage.accept(users.count / pageSize)
                    self?.searchText.accept(q)
                case .failure(let error):
                    print(error)
                }
                done?()
            }
            
        case .fetchMoreUsers:
//            guard busyFetchingMoreUsers.value else {
//                done?()
//                break
//            }
            let pageIndex = currentPage.value ?? 0
            let pageSize = 30
//            busyFetchingMoreUsers.accept(true)
            guard let q = self.searchText.value else { return }
            AccountService.shared.getUsers(q: q, pageIndex: pageIndex + 1, pageSize: pageSize) { [weak self] result in
                self?.busyFetchingMoreUsers.accept(false)
                switch result {
                case .success(let fetchedNotices):
                    var users = self?.users.value ?? []
                    let fetchedNotices = fetchedNotices.filter { notice in
                        !users.contains(where: { $0.id == notice.id })
                    }
                    users.append(contentsOf: fetchedNotices)
                    self?.users.accept(users)
                    self?.currentPage.accept(users.count / pageSize)
                    
                case .failure(let error):
                    print(error)
                }
                done?()
            }
            
        }
    }
    
    // MARK: - Setup
    override func setup() {
        super.setup()
    }
    
}
