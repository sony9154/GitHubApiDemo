//
//  ViewController.swift
//  GitHubApiDemo
//
//  Created by Peter Yo on Jul/7/21.
//

import UIKit
import Kingfisher
import CCBottomRefreshControl

class ViewController: UIViewController,
                      UICollectionViewDataSource,
                      UICollectionViewDelegateFlowLayout,
                      UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionSearchBar: UISearchBar!
    
    var cellIdentifier = "Cell"
    var numberOfItemsPerRow : Int = 2
    var dataSource:[String]?
    var dataSourceForSearchResult:[String]?
    var searchBarActive:Bool = false
    var searchBarBoundsY:CGFloat?
    var refreshControl:UIRefreshControl?
    var users: [User]?
    var searchText: String?
    var cellWidth:CGFloat{
        return collectionView.frame.size.width/2
    }
    
    override func viewDidLoad() {

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        collectionSearchBar.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
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
        self.collectionSearchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBarActive = false
        self.collectionSearchBar.setShowsCancelButton(false, animated: false)
    }
    func cancelSearching(){
        self.searchBarActive = false
        self.collectionSearchBar.resignFirstResponder()
        self.collectionSearchBar.text = ""
    }
    
    
    // MARK: <UICollectionViewDataSource>
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.layer.borderWidth = 1.0;
        cell.layer.borderColor = UIColor.green.cgColor
        cell.nameLabel.textColor = .black
        
        if (self.searchBarActive) {
            guard let users = self.users else { return UICollectionViewCell() }
            cell.nameLabel.text = users[indexPath.item].accountName
            let imageUrl = URL(string: users[indexPath.item].avatar ?? "")
            cell.avatarImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "bgExplore"))
            cell.indexLabel.text = String(indexPath.item + 1)
        }else{
            cell.nameLabel.text = self.users?[indexPath.row].accountName;
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.searchBarActive {
            return self.users?.count ?? 0
        }
        return self.users?.count ?? 0
    }
    
    func buttonTapped(indexPath: IndexPath) {
        print("success")
    }
    
    // MARK: <UICollectionViewDelegateFlowLayout>
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        return CGSize(width: size, height: size)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
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

