//
//  MediaItemCell.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/10/4.
//

import UIKit
import AVFoundation

protocol MediaItemDelegate: AnyObject {
    func playAndPauseMusic(mediaItem: MediaItem)
}

class MediaItemCell: UICollectionViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var longDescription: UITextView!
    @IBOutlet weak var playButton: UIButton!
    
    var player:AVPlayer?
    var audioPlayer: AVAudioPlayer?
    var playerItem:AVPlayerItem?
    var mediaItem: MediaItem?
    var previewUrl: String?
    weak var delegate: MediaItemDelegate?
        
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with mediaItem: MediaItem) {
        self.mediaItem = mediaItem
        nameLabel.text = mediaItem.artistName
        let imageUrl = URL(string: mediaItem.artworkUrl100 ?? "")
        longDescription.text = mediaItem.longDescription
        avatarImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "bgExplore"))
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        guard let mediaItem = self.mediaItem else { return }

        delegate?.playAndPauseMusic(mediaItem: mediaItem)

    }
    
    
}
