//
//  BaseCollectionViewLayout.swift
//  CZCustomLayout
//
//  Created by Edwin Peña on 4/9/17.
//  Copyright © 2017 Edwin Peña. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol BaseCollectionViewLayoutProtocol : class {
    func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
    @objc optional func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForHeaderInSection section: Int) -> CGFloat
    @objc optional func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForFooterInSection section: Int) -> CGFloat
    @objc optional func collectionViewCellBigger(_ indexPath: IndexPath) -> Bool
}


open class BaseCollectionViewLayout : UICollectionViewFlowLayout {
    
    public weak var delegate: BaseCollectionViewLayoutProtocol?
    var numberOfColumns: Int = 2 {
        didSet {
            invalidateLayout()
        }}
    override open var sectionInset: UIEdgeInsets {
        didSet {
            invalidateLayout()
        }}
    
    public var headersAttributes: [Int: UICollectionViewLayoutAttributes]
    public var footersAttributes: [Int: UICollectionViewLayoutAttributes]
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat  = 0.0
    private var contentWidth: CGFloat {
        return collectionView!.bounds.width - (sectionInset.left + sectionInset.right)
    }
    
    override init() {
        headersAttributes = [:]
        footersAttributes = [:]
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func prepare() {
        
        if cache.isEmpty {
            let columnWidth = (contentWidth - (minimumLineSpacing * CGFloat(numberOfColumns - 1))) / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * (columnWidth) + (minimumLineSpacing * CGFloat(column)))
            }
            var yOffset = [CGFloat]()
            
            //add header
            let headerHeight = createHeader(forSetion: 0)
            for _ in 0 ..< numberOfColumns {
                yOffset.append(sectionInset.top + headerHeight)
            }
            var column = 0
            let itemCount = collectionView!.numberOfItems(inSection: 0)

            for idx in 0 ..< itemCount {
                let indexPath = IndexPath(row: idx, section: 0)
                //calculate the heigh necessary
                let (cellBigger, width, cellHeight) = self.calculateVariableAttributes(indexPath: indexPath, columnWidth)
               
                // change the colum if the cell is bigger
                var yPosition = CGFloat(0)
                if(cellBigger){
                    column = 0;
                    yPosition = yOffset.max()!
                }
                else{
                   yPosition = yOffset[column]
                }
                // add the margin depending of the column position
                let xPosition: CGFloat = xOffset[column] + sectionInset.left
                
                // it create the frame for each cell
                let frame = CGRect(x: xPosition, y: yPosition, width: width, height: cellHeight)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
                
                //sum the total contentHeight of the collectionView
                contentHeight = max(contentHeight, frame.maxY)
                
                //When the cell is show big, it needs add the Y position for the next to rows
                if cellBigger {
                    for columnIdx in 0 ..< numberOfColumns {
                        yOffset[columnIdx] = yPosition + cellHeight + minimumInteritemSpacing
                    }
                }
                else{
                    yOffset[column] = yOffset[column] + cellHeight + minimumInteritemSpacing
                }
                
                // choose the column with more space to put the next cell
                column = self.shorterColumn(yOffset)
            }
            
            //add footer
            let yFooterPosition = yOffset.max()! - minimumInteritemSpacing + sectionInset.bottom
            self.createFooter(forSetion: 0, yPosition: yFooterPosition)
        }
    }
    
    override open var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override open func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    
    override open func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return self.boundsChange(with: newBounds)
    }
    
    override open func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        if context.invalidateDataSourceCounts {
            self.cleanCache()
        }
        else if let ctx = context as? UICollectionViewFlowLayoutInvalidationContext {
            if ctx.invalidateFlowLayoutDelegateMetrics {
                self.cleanCache()
            }
        }

    }
    
    override open func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context: UICollectionViewFlowLayoutInvalidationContext = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        // invalidate layout if the bounds change
        context.invalidateFlowLayoutDelegateMetrics = self.boundsChange(with: newBounds)
        return context;
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.row + 1]
    }
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            return self.headersAttributes[indexPath.section] ?? UICollectionViewLayoutAttributes()
        case UICollectionElementKindSectionFooter:
            return self.footersAttributes[indexPath.section] ?? UICollectionViewLayoutAttributes()
        default:
            return UICollectionViewLayoutAttributes()
        }
    }
    
    //MARK: - Private Methods
    private func createHeader(forSetion: Int) -> CGFloat {
        let width = collectionView!.bounds.width
        var height = CGFloat(0)
        if let delegate = delegate {
            height = delegate.collectionView?(collectionView!, availableWidth: width, heightForHeaderInSection: forSetion) ?? 0.0
        }
        if(height > CGFloat(0)){
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(row: 0, section: forSetion))
            attributes.frame = frame
            cache.append(attributes)
            headersAttributes[forSetion] = attributes
        }
        return height
    }
    
    private func createFooter(forSetion: Int, yPosition: CGFloat){
        let width = collectionView!.bounds.width
        var height = CGFloat(0)
        if let delegate = delegate {
            height = delegate.collectionView?(collectionView!, availableWidth: width, heightForFooterInSection: forSetion) ?? 0.0
        }
        if(height > CGFloat(0)){
            let frame = CGRect(x: 0, y: yPosition, width: width, height: height)
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(row: 0, section: forSetion))
            attributes.frame = frame
            cache.append(attributes)
            footersAttributes[forSetion] = attributes
            self.contentHeight = max(self.contentHeight, frame.maxY)
        }else{
            //if there are not footer add the sectionInset.bottom to the contentHeight
             contentHeight = contentHeight + sectionInset.bottom
        }
    }
    
    private func boundsChange(with newBounds: CGRect) -> Bool{
        let oldBounds = collectionView!.bounds
        if !oldBounds.equalTo(newBounds) {
            return true
        }
        return false
    }
    private func cleanCache() {
        contentHeight = 0.0
        cache.removeAll()
    }
    
    private func shorterColumn(_ columnsArray: [CGFloat] = []) -> Int {
        // choose the column with more space to put the next cell
        var shorterColumn = 0
        for columnIdx in 0 ..< numberOfColumns {
            if columnsArray[columnIdx] < columnsArray[shorterColumn] {
                shorterColumn = columnIdx
            }
        }
        return shorterColumn
    }

    private func calculateVariableAttributes(indexPath: IndexPath, _ columnWidth: CGFloat = 0.0) -> (Bool, CGFloat, CGFloat) {
        //calculate the heigh necessary
        if let delegate = delegate {
            let cellBigger = delegate.collectionViewCellBigger?(indexPath) ?? false
            let width = cellBigger ? contentWidth : columnWidth
            let cellHeight = delegate.collectionView(collectionView!, availableWidth: width, heightForItemAtIndexPath: indexPath)
            return (cellBigger, width, cellHeight)
        }else {
            print("cell height = 0 because delegete is nil ")
        }
        return (false, 0.0, 0.0)
    }
}
