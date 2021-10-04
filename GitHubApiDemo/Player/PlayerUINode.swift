//
//  PlayerUINode.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/10/4.
//

import UIKit

class PlayerUINode: PlayerNode,
                    UINodeWithAnyView {
    
    typealias ViewT = PlayerVC
    var _viewController: ViewT?
}
