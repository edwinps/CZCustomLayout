//
//  ItemCollectionViewCell.swift
//  CZCustomLayout
//
//  Created by Edwin Peña on 4/9/17.
//  Copyright © 2017 Edwin Peña. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    //MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    //MARK: - View Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
        // Initialization code
    }
    
    //MARK: - Private methods
    
    private func commonInit() {
        configureOutlets()
    }
    //MARK: - UI Configuration
    
    private func configureOutlets(){
        //Content View
        contentView.backgroundColor = UIColor.lightGray
        //image
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        //label
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    }
    //MARK: - Accessible Methods
    func configureView(viewModel: ItemViewModel) {
        
        titleLabel.text = viewModel.title
        
        if let imageName = viewModel.image{
           imageView.image = UIImage(named: imageName)
        }
    }

}
