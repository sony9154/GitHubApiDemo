//
//  SearchViewController.swift
//  GitHubApiDemo
//
//  Created by Hsu Hua on 2021/7/8.
//

import UIKit
import UICollectionViewLeftAlignedLayout

class SearchViewController: UIViewController,
                            UICollectionViewDataSource,
                            UICollectionViewDelegate,
                            UICollectionViewDelegateFlowLayout,
                            UISearchBarDelegate {
    
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource:[String]?
    var dataSourceForSearchResult:[String]?
    var searchBarActive:Bool = false
    var refreshControl:UIRefreshControl?
    var users: [User]?
    var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.collectionViewLayout = UICollectionViewLeftAlignedLayout()
        collectionView.contentInset = UIEdgeInsets(top: 18, left: 25, bottom: 0, right: 0)
        // Setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.triggerVerticalOffset = 100
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.bottomRefreshControl = refreshControl
        self.dataSource = []
        self.dataSourceForSearchResult = [String]()
    }
    
    // MARK: Search
    func filterContentForSearchText(searchText:String){
        self.dataSourceForSearchResult = self.dataSource?.filter({ (text:String) -> Bool in
            return text.contains(searchText)
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            self.searchBarActive = true
            self.filterContentForSearchText(searchText: searchText)
            AccountService.shared.getUsers(q: searchText) { result in
                switch result {
                case .success(let users):
                    self.users = users
                    self.collectionView?.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }else{
            self.searchBarActive = false
            self.collectionView?.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self .cancelSearching()
        self.collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarActive = true
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBarActive = false
        self.searchBar.setShowsCancelButton(false, animated: false)
    }
    func cancelSearching(){
        self.searchBarActive = false
        self.searchBar.resignFirstResponder()
        self.searchBar.text = ""
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell
        
        if (self.searchBarActive) {
            guard let users = self.users else { return UICollectionViewCell() }
            cell.nameLabel?.text = users[indexPath.item].accountName
            let imageUrl = URL(string: users[indexPath.item].avatar ?? "")
            cell.avatarImageView?.kf.setImage(with: imageUrl, placeholder: UIImage(named: "bgExplore"))
            cell.indexLabel?.text = String(indexPath.item + 1)
        }else{
            cell.nameLabel?.text = self.users?[indexPath.row].accountName;
        }
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
        return CGSize(width: cellWidth, height: cellWidth * (168/162))
    }
 
    @objc func refresh() {
        collectionView.bottomRefreshControl?.beginRefreshing()
        AccountService.shared.getMoreUsers { result in
            switch result {
            case .success(let users):
                self.users = users
                self.collectionView?.reloadData()
                self.collectionView.bottomRefreshControl?.endRefreshing()
            case .failure(let error):
                self.collectionView.bottomRefreshControl?.endRefreshing()
                print(error)
            }
        }
    }
    
}
