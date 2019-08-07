//
//  SearchView.swift
//  Fastflix
//
//  Created by Jeon-heaji on 27/07/2019.
//  Copyright © 2019 hyeoktae kwon. All rights reserved.
//

import UIKit
import SnapKit

protocol SearchViewDelegate: class {
  func searchMovies(key: String, completion: @escaping (Result<SearchMovie, ErrorType>) -> ())
}

class SearchView: UIView {
  
  weak var delegate: SearchViewDelegate?
  
  var searchMovies: SearchMovie? {
    didSet(new) {
      guard let data = new else { return }
      data.firstMovie.forEach { self.imgPaths.append($0.verticalImage ?? "") }
      data.otherMovie.forEach { self.imgPaths.append($0.verticalImage ?? "") }
      collectionView.reloadData()
    }
  }
  
  lazy var imgPaths: [String] = []
  
  
  private let layout = UICollectionViewFlowLayout()
  
  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    return collectionView
  }()
  
  lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: topPadding + 5, width: UIScreen.main.bounds.size.width, height: 30))
    return searchBar
  }()
  lazy var offset = UIOffset(horizontal: (searchBar.frame.width - 100) / 2, vertical: 0)
  let noOffset = UIOffset(horizontal: 0, vertical: 0)
  
  
  
  override func didMoveToSuperview() {
    addSubViews()
    setupCollectionView()
    setupSNP()
    setupSearch()
    registerCollectionViewCell()
    searchBar.becomeFirstResponder()
    
  }
  
  private func addSubViews() {
    [collectionView, searchBar]
      .forEach { self.addSubview($0) }
    
  }
  
  private func setupSNP() {
    
    collectionView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.top.equalToSuperview().offset((topPadding + searchBar.frame.height + 5))
    }
    
  }
  
  private func setupSearch() {
    searchBar.delegate = self
    searchBar.placeholder = "검색"
    
    searchBar.searchBarStyle = .minimal
    searchBar.keyboardAppearance = UIKeyboardAppearance.dark
    searchBar.barStyle = .black
    searchBar.setPositionAdjustment(offset, for: .search)
    
  }
  
  private func registerCollectionViewCell() {
    collectionView.register(SearchCollectionCell.self, forCellWithReuseIdentifier: SearchCollectionCell.identifier)
  }
  private func setupCollectionView() {
    collectionView.dataSource = self
    collectionView.delegate = self
    layout.scrollDirection = .vertical
    collectionView.backgroundColor = #colorLiteral(red: 0.07762928299, green: 0.07762928299, blue: 0.07762928299, alpha: 1)
    self.collectionView.collectionViewLayout = layout
    layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    layout.minimumLineSpacing = 12
    layout.minimumInteritemSpacing = 14
    
    let width = (UIScreen.main.bounds.width - 44)/3
    let height = width * 1.4
    
    layout.itemSize = CGSize(width: width, height: height)
    layout.sectionHeadersPinToVisibleBounds = true
    collectionView.showsHorizontalScrollIndicator = false
  }
  
}

extension SearchView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imgPaths.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionCell.identifier, for: indexPath) as! SearchCollectionCell
    cell.delegate = self
    cell.configure(imageUrlString: imgPaths[indexPath.row])
    return cell
  }
  
  
}
extension SearchView: UICollectionViewDelegate {
  
}

extension SearchView: UISearchBarDelegate {
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.setPositionAdjustment(noOffset, for: .search)
    print("should begin")
    return true
  }
  
  func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    
    searchBar.setPositionAdjustment(offset, for: .search)
    print("end")
    return true
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    print("서치중")
    delegate?.searchMovies(key: searchText) { res in
      switch res {
      case .success(let value):
        self.searchMovies = value
      case .failure(let err):
        dump(err)
      }
    }
    
  }
  // searchButton 클릭시 키보드 내려감
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}


extension SearchView: SearchCollectionCellDelegate {
  func resignKeyboard() {
    self.searchBar.resignFirstResponder()
  }
  
  
}
