//
//  PlanTypesTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/14/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class PlanTypesTableViewCell: UITableViewCell {
    
    var collectionView: UICollectionView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = layout.widescreenCards()
        let margin = (Helper.CellHeight.superWide.value - layout.itemSize.height) / 2
        layout.sectionInset = UIEdgeInsetsMake(0, margin, 0, margin)
        layout.minimumLineSpacing = margin
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        let typeNib = UINib(nibName: "TypeCell", bundle: nil)
        collectionView?.registerNib(typeNib, forCellWithReuseIdentifier: CellID.SpecificType.rawValue)
        collectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.contentView.bounds
        collectionView.backgroundColor = UIColor.whiteColor()
    }
    
    
    func configureWithDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDataSource, UICollectionViewDelegate>) {
        collectionView.dataSource = delegate
        collectionView.delegate = delegate
        collectionView.reloadData()
    }
}
