//
//  ViewController.swift
//  CZCustomLayout
//
//  Created by Edwin Peña on 4/9/17.
//  Copyright © 2017 Edwin Peña. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, BaseCollectionViewLayoutProtocol {
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: dataSource
    let dataSource = ModelItems()
    
    //number Of Columns we want to display
    let numberOfColumns = 2
    
    //hash
    private var hashCell : [String : UICollectionViewCell] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.buildDataSource()
        dataSource.buildHeader()
        dataSource.buildFooter()
        // Attach datasource and delegate
        self.collectionView.dataSource  = self
        self.collectionView.delegate = self
        
        //configure Outlets
        configureOutlets()
        
        //Register nibs
        registerNibs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UI Configuration
    private func configureOutlets()  {
        self.automaticallyAdjustsScrollViewInsets = false
        //create the Layout
        let layout = BaseCollectionViewLayout()
        
        //config margin
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        // The minimum spacing to use between rows.
        layout.minimumInteritemSpacing = 10
        // The minimum spacing to use between columns
        layout.minimumLineSpacing = 10
        
        // Add the waterfall layout to your collection view
        self.collectionView.collectionViewLayout = layout
        //add delegate
        layout.delegate = self
        
    }
    
    // Register CollectionView Nibs
    private func registerNibs(){
        let viewNib = UINib(nibName: "ItemCollectionViewCell", bundle: nil)
        collectionView.register(viewNib, forCellWithReuseIdentifier: "cell")
        
        let headerViewNib = UINib(nibName: "HeaderCollectionViewCell", bundle: nil)
        collectionView.register(headerViewNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        let footerViewNib = UINib(nibName: "FooterCollectionViewCell", bundle: nil)
        collectionView.register(footerViewNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer")
    }
    
    //MARK: - Accessible Methods
    func calculateCellHeight(item: ItemViewModel, _ indexPath: IndexPath, _ availableWidth: CGFloat) -> CGFloat {
        
        let bundle = Bundle(for: type(of: self))
        
        //calculate automatic size
        let cellNibName = String(describing: ItemCollectionViewCell.self)
        
        /// it should be exits always
        guard !cellNibName.isEmpty else {
            return 0.0
        }
        
        //look it the view is already create to no create always a new one
        var existingCell = hashCell[cellNibName]
        
        if existingCell == nil {
            let nib = UINib(nibName: cellNibName, bundle: bundle)
            existingCell = nib.instantiate(withOwner: nil, options: nil)[0] as? ItemCollectionViewCell
            hashCell[cellNibName] = existingCell
        }
        
        /// it should be exits always
        guard let currentCell = existingCell else {
            return 0.0
        }
        //config the cell with the datasource
        if let cell = currentCell as? ItemCollectionViewCell {
           cell.configureView(viewModel: item)
        }
        
        //use systemLayoutSizeFitting to calculate the height base in the width
        let targetSize = CGSize(width: availableWidth, height: 0)
        let autoLayoutSize = currentCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        
        return autoLayoutSize.height
    }
    
    //MARK: BaseCollectionViewLayoutProtocol
    
    func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        if let item = dataSource.ds[indexPath.section]?[indexPath.row]{
            return calculateCellHeight(item: item, indexPath,availableWidth)
        }
        return 0
    }
    
    func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 50 : 0
    }
    
    func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 50 : 0
    }
    
    func collectionView (_ collectionView: UICollectionView, columnCountForSection section: Int) -> Int {
        return section == 0 ? 2 : 3
    }
    
    func collectionViewBiggerCell(_ indexPath: IndexPath) -> Bool {
        //make the first item bigger
        if(indexPath.row == 0 && indexPath.section == 0){
            return true
        }
        return false
    }
    
    //MARK: CollectionView Delegate Methods
    
    //** Number of Cells in the CollectionView */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfRow = dataSource.ds[section]?.count {
            return numberOfRow
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return dataSource.ds.count
    }
    
    // Create a CollectionView Cell */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! ItemCollectionViewCell
        // confic cell
        if let model = dataSource.ds[indexPath.section]?[indexPath.row] {
            cell.configureView(viewModel: model)
            return cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        /// review when there are not header of footer for section
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! HeaderCollectionViewCell
            if indexPath.section < dataSource.headerViewModel.count {
                headerView.configureView(viewModel: dataSource.headerViewModel[indexPath.section])
                return headerView
            }
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath as IndexPath)
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! FooterCollectionViewCell
            if indexPath.section < dataSource.headerViewModel.count {
                footerView.configureView(viewModel: dataSource.footerViewModel[indexPath.section])
                return footerView
            }
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath as IndexPath)
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
}

