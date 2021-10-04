//
//  MediaItem.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/10/4.
//

import Foundation


struct MediaItem: Codable {
    var id: Int64
    var artistName: String?
    var artworkUrl100: String?
    var longDescription: String?
    var previewUrl: String?
}
