//
//  SearchViewController.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/7/8.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import RxViewController
import CCBottomRefreshControl
import UICollectionViewLeftAlignedLayout

class SearchVC: NodeVC,
                StoryboardMakable,
                UICollectionViewDelegateFlowLayout,
                MediaItemDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!

    var node: SearchUINode? { return ownerNode as? SearchUINode }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.placeholder = "Please Enter Search Text Here"
//        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(UINib(nibName: "MediaItemCell", bundle: nil), forCellWithReuseIdentifier: "MediaItemCell")
        collectionView.delegate = self
        collectionView.dataSource = nil
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()        
    }
    
    // MARK: - Binding
    override func bindNode(_ node: Node) {
        guard let node = node as? SearchNode else { return }
        
        node.searchText
            .distinctUntilChanged()
            .bind(to: searchTextField.rx.text)
            .disposed(by: disposeBag)
        
        searchTextField.rx.text
            .distinctUntilChanged()
            .subscribe(onNext: { [weak node] text in
                node?.act(.setSearchText(text: text))
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        node.mediaItems
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        node.mediaItems
            .map { $0 ?? [] }
            .filterNil()
            .bind(to: self.collectionView.rx.items(cellIdentifier: "MediaItemCell", cellType: MediaItemCell.self))
                { index, mediaItem, cell in
                    cell.delegate = self
                    cell.indexLabel?.text = String(index + 1)
                    cell.configure(with: mediaItem)
                }
            .disposed(by: disposeBag)
        
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let cell = Bundle.main.loadNibNamed("MediaItemCell", owner: self, options: nil)?.first as! MediaItemCell
//        cell.longDescription.contentSize = cell.longDescription.intrinsicContentSize
        let width = UIScreen.main.bounds.width
        layout.minimumLineSpacing = 15.0
        layout.minimumInteritemSpacing = 20.0
        collectionView.collectionViewLayout = layout
        guard let item  = node?.mediaItems.value?[indexPath.row] else { return CGSize() }
        if (item.longDescription != nil) {
            return CGSize(width: width, height: cell.avatarImageView.frame.size.height +
                                                cell.nameLabel.frame.size.height +
                                                cell.longDescription.contentSize.height)
        } else {
            return CGSize(width: width, height: cell.avatarImageView.frame.size.height +
                                                cell.nameLabel.frame.size.height)
        }
    }
    
    func playAndPauseMusic(mediaItem: MediaItem) {
        node?.act(.showPlayer(mediaItem: mediaItem))
        
    }
    
}
