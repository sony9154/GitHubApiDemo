//
//  SearchCollectionViewCell.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/7/8.
//

import UIKit
import SnapKit
import Kingfisher

class SearchCollectionViewCell: UICollectionViewCell {
    var containerView: UIView?
    var avatarImageView: UIImageView?
    var nameLabel: UILabel?
    var placeID: String?
    var indexLabel: UILabel?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    func setupUI() {
        
        containerView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 10
            self.contentView.addSubview(view)
            return view
        }()
        
        avatarImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            self.containerView?.addSubview(imageView)
            imageView.snp.makeConstraints{
                $0.top.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-20)
            }
            return imageView
        }()
        
        indexLabel = {
            let label  = UILabel()
            label.backgroundColor = .white
            self.containerView?.addSubview(label)
            label.snp.makeConstraints {
                $0.leading.top.equalToSuperview()
            }
            return label
        }()
        
        nameLabel = {
            let label = UILabel()
            label.textColor = .systemBlue
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textAlignment = .center
            self.containerView?.addSubview(label)
            label.snp.makeConstraints {
                $0.leading.equalTo(10)
                $0.trailing.equalTo(-10)
                $0.bottom.equalToSuperview()
            }
            return label
        }()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView?.frame = contentView.bounds
    }
    
}



