//
//  CollectionViewTableViewCell.swift
//  BespinApp
//
//  Created by DJ McKay on 7/3/19.
//

import UIKit

protocol CollectionViewData {
    func configureCell(cell: UICollectionViewCell, cellForItemAt indexPath: IndexPath)
    func numberOfItemsInSection(section: Int) -> Int
    func numberOfSections() -> Int
    func registerCell(collectionView: UICollectionView) -> String
    func didSelectCell(cell: UICollectionViewCell)
    func sizeForItemAt(indexPath: IndexPath) -> CGSize
    func backgroundColor() -> UIColor
}

class CollectionViewTableViewCell: UITableViewCell {
    
    static var nib = UINib(nibName: "CollectionViewTableViewCell", bundle: nil)
    
    var data: CollectionViewData?
    var dataReuseIdentifier: String!
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
    }
    
    func configure(data: CollectionViewData) {
        self.data = data
        dataReuseIdentifier = data.registerCell(collectionView: self.collectionView)
        self.collectionView.backgroundColor = data.backgroundColor()
        self.collectionView.reloadData()
    }
    
}

extension CollectionViewTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.numberOfItemsInSection(section: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dataReuseIdentifier, for: indexPath)
        data!.configureCell(cell: cell, cellForItemAt: indexPath)
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data?.numberOfSections() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView(self.collectionView, cellForItemAt: indexPath)
        data?.didSelectCell(cell: cell)
    }
    
}

extension CollectionViewTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return data?.sizeForItemAt(indexPath: indexPath) ?? CGSize(width: 100, height: 100)
    }
}
