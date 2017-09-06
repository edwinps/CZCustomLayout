//
//  HeaderCollectionViewCell.swift
//  CZCustomLayout
//
//  Created by Edwin Peña on 5/9/17.
//  Copyright © 2017 Edwin Peña. All rights reserved.
//

import UIKit

class HeaderCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets
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
        contentView.backgroundColor = UIColor.darkGray
        
        //label
        titleLabel.tintColor = UIColor.white
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
    }
    
    //MARK: - Accessible Methods
    func configureView(viewModel: HeaderViewModel) {
        titleLabel.text = viewModel.title
    }

}
