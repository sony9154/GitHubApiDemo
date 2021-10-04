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
                UICollectionViewDataSource,
                UICollectionViewDelegate,
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
        collectionView.collectionViewLayout = UICollectionViewLeftAlignedLayout()
        collectionView.contentInset = UIEdgeInsets(top: 18, left: 25, bottom: 0, right: 0)
        // Setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.triggerVerticalOffset = 100
        collectionView.bottomRefreshControl = refreshControl
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
        
        node.busyFetchingMoreUsers
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
            .filter { !$0 }
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.bottomRefreshControl?.endRefreshing()
            }).disposed(by: disposeBag)
        
        collectionView.bottomRefreshControl?.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak node] in
                node?.act(.fetchMoreUsers)
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return node?.mediaItems.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaItemCell", for: indexPath) as! MediaItemCell
        guard let mediaItems = node?.mediaItems.value else { return UICollectionViewCell() }
        for mediaItem in mediaItems {
            cell.delegate = self
            cell.configure(with: mediaItem)
        }
        cell.indexLabel?.text = String(indexPath.item + 1)
        return cell
        
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let width = UIScreen.main.bounds.width
        layout.minimumLineSpacing = 15.0
        layout.minimumInteritemSpacing = 20.0
        collectionView.collectionViewLayout = layout
        let cellWidth: CGFloat = width * 155 / 375
//        return CGSize(width: cellWidth, height: cellWidth * (168/162))
        return CGSize(width: UIScreen.main.bounds.width, height: cellWidth * (168/162))
    }
 
    
    func playAndPauseMusic(mediaItem: MediaItem) {
        node?.act(.showPlayer(mediaItem: mediaItem))
        
    }
    
}
