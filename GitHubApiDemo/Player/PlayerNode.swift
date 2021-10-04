//
//  PlayerNode.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/10/4.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class PlayerNode: Node {
    // MARK: - Store -
    var mediaItem = RxVar<MediaItem?>(nil)
    
    // MARK: - Action -
    enum Action {
        case setMediaItem(mediaItem: MediaItem)
    }
    
    func act(_ action: Action, done: ActionCompletion? = nil) {
        switch action {
        case .setMediaItem(let mediaItem):
            self.mediaItem.accept(mediaItem)
            print("MediaItem: \(mediaItem.previewUrl)")
            done?()
        }
    }
    
    // MARK: - Setup -
    override func setup() {
        super.setup()
    }
}
