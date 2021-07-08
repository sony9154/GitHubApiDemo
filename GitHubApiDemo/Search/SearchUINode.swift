//
//  SearchUINode.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/7/8.
//

import UIKit

class SearchUINode: SearchNode,
                    UINodeWithAnyView {
    
    typealias ViewT = SearchVC
    var _viewController: ViewT?
    
}
