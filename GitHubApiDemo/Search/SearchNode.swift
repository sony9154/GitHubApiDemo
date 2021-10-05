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
    var mediaItems = RxVar<[MediaItem]?>(nil)
    var currentPage = RxVar<Int?>(nil)
    var busyFetchingMoreUsers = RxVar<Bool>(false)
    
    // MARK: - Action
    enum Action {
        case setSearchText(text: String?)
        case fetchMediaItems(q: String)
        case showPlayer(mediaItem: MediaItem)
    }
    
    func act(_ action: Action, done: ActionCompletion? = nil) {
        switch action {
        case .setSearchText(let text):
            searchText.accept(text)
            act(.fetchMediaItems(q: text ?? ""))
            done?()
        case .fetchMediaItems(let q):
            busyFetchingMoreUsers.accept(true)
            
            AccountService.shared.getMediaItems(query: q) { [weak self] result in
                self?.busyFetchingMoreUsers.accept(false)
                switch result {
                case .success(let mediaItems):
                    self?.mediaItems.accept(mediaItems)
                case .failure(let error):
                    print(error)
                }
                done?()
            }
        case .showPlayer(let mediaItem):
            router?.route(MainRouter.Routes.searchToShowPlayer(mediaItem: mediaItem), from: self)
            done?()
        }
    }
    
    // MARK: - Setup
    override func setup() {
        super.setup()
    }
    
}
