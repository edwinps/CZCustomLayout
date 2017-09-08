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
    /**
     ask the height of each item in index with the available width
     
     - parameter collectionView: the collection view requesting this information.
     - parameter availableWidth: available width for item.
     - parameter heightForItemAtIndexPath: The indexpath of the item.
     
     - returns: CGFloat height of each item.
     */
    func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
    /**
     ask the height of each header in section with the available width
     
     - parameter collectionView: the collection view requesting this information.
     - parameter availableWidth: available width for header.
     - parameter heightForHeaderInSection: The section of the header.
     
     - returns: CGFloat height of each header.
     */
    @objc optional func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForHeaderInSection section: Int) -> CGFloat
    /**
     ask the height of each footer in section with the available width
     
     - parameter collectionView: the collection view requesting this information.
     - parameter availableWidth: available width for footer.
     - parameter heightForFooterInSection: The section of the footer.
     
     - returns: CGFloat height of each footer.
     */
    @objc optional func collectionView (_ collectionView: UICollectionView, availableWidth: CGFloat, heightForFooterInSection section: Int) -> CGFloat
    /**
     ask the number of columns for each section
     
     - parameter collectionView: the collection view requesting this information.
     - parameter heightForFooterInSection: The section of the footer.
     
     - returns: column number.
     */
    @objc optional func collectionView (_ collectionView: UICollectionView, columnCountForSection section: Int) -> Int
    /**
     ask if the item will use all available width
     - parameter indexPath: The indexpath of the item.
     
     - returns: true if the item will use all the available width.
     */
    @objc optional func collectionViewBiggerCell(_ indexPath: IndexPath) -> Bool
}


open class BaseCollectionViewLayout : UICollectionViewFlowLayout {
    
    public weak var delegate: BaseCollectionViewLayoutProtocol?
    public var numberOfColumns: Int {
        didSet {
            invalidateLayout()
        }}
    override open var sectionInset: UIEdgeInsets {
        didSet {
            invalidateLayout()
        }}
    public var sectionItemAttributes: [[UICollectionViewLayoutAttributes]]
    public var headersAttributes: [Int: UICollectionViewLayoutAttributes]
    public var footersAttributes: [Int: UICollectionViewLayoutAttributes]
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat  = 0.0
    private var contentWidth: CGFloat {
        return collectionView!.bounds.width - (sectionInset.left + sectionInset.right)
    }
    
    override public init() {
        headersAttributes = [:]
        footersAttributes = [:]
        sectionItemAttributes = []
        numberOfColumns = 2
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func prepare() {
        /*
         * if there are not section finish the process
         */
        let numberOfSections = self.collectionView!.numberOfSections
        if numberOfSections == 0 {
            return
        }
        if cache.isEmpty {
            /*
             * valuas uses to save the point x, y for each item
             */
            var xOffset = [CGFloat]()
            var yOffset = [CGFloat]()
            /*
             * Loop for each sections
             */
            for section in 0 ..< numberOfSections {
                var column = 0
                let numberOfColumnsInSection = self.numberOfColumnsInSection(section)
                xOffset.removeAll()
                /*
                 * calculate maximum available width, it take in count:
                 *   - SectionInset (left and right)
                 *   - The minimum spacing to use between columns (minimumLineSpacing)
                 *   - Number of columms
                 */
                let columnWidth = (contentWidth - (minimumLineSpacing * CGFloat(numberOfColumnsInSection - 1))) / CGFloat(numberOfColumnsInSection)
                for column in 0 ..< numberOfColumnsInSection {
                    xOffset.append(CGFloat(column) * (columnWidth) + (minimumLineSpacing * CGFloat(column)))
                }
                /*
                 * valuas uses to save the point x, y for each item
                 */
                if xOffset.count <= 0 {
                    assert(false, "it should to be at least one column")
                }
                
                let itemCount = collectionView!.numberOfItems(inSection: section)
                for _ in 0 ..< numberOfColumnsInSection {
                    yOffset.append(0)
                }
                /*
                 * add header if exits for each section
                 */
                var maxYframe: CGFloat
                if let yHeaderPosition = yOffset.max() {
                    let headerHeight = createHeader(forSetion: section, yPosition: yHeaderPosition)
                    /*
                     * after a header the next columns number should be 0
                     * and add the header height space for the next rows
                     */
                    if headerHeight > 0 {
                        column = 0
                    }
                    maxYframe = yHeaderPosition
                    yOffset = yOffset.flatMap { _ in return maxYframe + sectionInset.top + headerHeight }
                    
                }
                /*
                 * Loop for each row in the section
                 */
                var sectionAttributes: [UICollectionViewLayoutAttributes] = []
                for idx in 0 ..< itemCount {
                    let indexPath = IndexPath(row: idx, section: section)
                    /*
                     * calculate:
                     *  - the cell heigh
                     *  - the cell widht
                     *  - if the cell is bigger
                     */
                    let (biggerCell, width, cellHeight) = self.calculateVariableAttributes(indexPath: indexPath, columnWidth)
                    
                    /*
                     *  change the colum to 0 if the cell is bigger
                     */
                    var yPosition = CGFloat(0)
                    if(biggerCell){
                        column = 0;
                        yPosition = yOffset.max() ?? 0
                    }
                    else{
                        yPosition = yOffset[column]
                    }
                    /*
                     * add the left margin in the column position
                     */
                    let xPosition: CGFloat = xOffset[column] + sectionInset.left
                    
                    /*
                     * it create the frame for each cell
                     */
                    let frame = CGRect(x: xPosition, y: yPosition, width: width, height: cellHeight)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = frame
                    sectionAttributes.append(attributes)
                    cache.append(attributes)
                    /*
                     * sum the frame to the contentHeight of the collectionView
                     */
                    contentHeight = max(contentHeight, frame.maxY)
                    
                    /*
                     * it needs to update the Y position of the following rows, when the cell is shown wider or not
                     */
                    if biggerCell {
                        for columnIdx in 0 ..< numberOfColumnsInSection {
                            yOffset[columnIdx] = yPosition + cellHeight + minimumInteritemSpacing
                        }
                    }
                    else{
                        yOffset[column] = yOffset[column] + cellHeight + minimumInteritemSpacing
                    }
                    /*
                     * choose the column with more space to add the next cell
                     */
                    column = self.shorterColumn(yOffset, numberOfColumnSection: numberOfColumnsInSection)
                }
                sectionItemAttributes.append(sectionAttributes)
                /*
                 * add footer if exits for each section
                 * and add the footer heigt to the yOffset
                 */
                if let maxY = yOffset.max() {
                    let yFooterPosition = maxY - minimumInteritemSpacing + sectionInset.bottom
                    let footerHeight = self.createFooter(forSetion: section, yPosition: yFooterPosition)
                    yOffset = yOffset.flatMap { _ in return maxY + footerHeight }
                }
                
            }
            
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
        let ctx = super.invalidationContext(forBoundsChange: newBounds)
        if let context = ctx as? UICollectionViewFlowLayoutInvalidationContext {
            context.invalidateFlowLayoutDelegateMetrics = self.boundsChange(with: newBounds)
            return context
        }
        return ctx
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if (indexPath as NSIndexPath).section >= self.sectionItemAttributes.count {
            return nil
        }
        let list = self.sectionItemAttributes[indexPath.section]
        if (indexPath as NSIndexPath).item >= list.count {
            return nil
        }
        return list[indexPath.item]
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
    /**
     Ask the number of columns for setions
     - parameter forSetion: The section of the header.
     
     - returns: number of columns.
     */
    private func numberOfColumnsInSection(_ section: Int) -> Int {
        var numberOfColumns = self.numberOfColumns
        if let delegate = self.delegate , let numberColumns = delegate.collectionView?(collectionView!, columnCountForSection: section) {
            numberOfColumns =  numberColumns
        }
        return numberOfColumns
    }
    /**
     Create the header for a section with y position
     - parameter forSetion: The section of the header.
     - parameter yPosition: the y position of the header.
     
     - returns: height of the header.
     */
    private func createHeader(forSetion: Int, yPosition: CGFloat ) -> CGFloat {
        let width = collectionView!.bounds.width
        var height = CGFloat(0)
        if let delegate = delegate {
            height = delegate.collectionView?(collectionView!, availableWidth: width, heightForHeaderInSection: forSetion) ?? 0.0
        }
        if(height > 0){
            let frame = CGRect(x: 0, y: yPosition, width: width, height: height)
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(row: 0, section: forSetion))
            attributes.frame = frame
            cache.append(attributes)
            headersAttributes[forSetion] = attributes
        }
        return height
    }
    /**
     Create the footer for a section with y position
     - parameter forSetion: The section of the footer.
     - parameter yPosition: the y position of the footer.
     
     - returns: height of the footer.
     */
    private func createFooter(forSetion: Int, yPosition: CGFloat) -> CGFloat{
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
            /*
             * sum the frame to the contentHeight of the collectionView
             */
            self.contentHeight = max(self.contentHeight, frame.maxY)
        }else{
            /*
             * if there are not footer add the sectionInset.bottom to the contentHeight
             */
            contentHeight = contentHeight + sectionInset.bottom
        }
        return height
    }
    /**
     Calculate if the bounds change
     - parameter newBounds: The bounds of the view.
     
     - returns: true if the bounds change.
     */
    private func boundsChange(with newBounds: CGRect) -> Bool{
        let oldBounds = collectionView!.bounds
        if newBounds.width != oldBounds.width {
            return true
        }
        return false
    }
    /**
     clean all the item from cache to recaculate again
     */
    private func cleanCache() {
        contentHeight = 0.0
        headersAttributes.removeAll()
        footersAttributes.removeAll()
        sectionItemAttributes.removeAll()
        cache.removeAll()
    }
    /**
     Choose the shortest column to add the nex item
     - parameter columnsArray: the arrary where it's going to look
     
     - returns: the shortest column.
     */
    private func shorterColumn(_ columnsArray: [CGFloat] = [], numberOfColumnSection: Int) -> Int {
        var shorterColumn = 0
        for columnIdx in 0 ..< numberOfColumnSection {
            if columnsArray[columnIdx] < columnsArray[shorterColumn] {
                shorterColumn = columnIdx
            }
        }
        return shorterColumn
    }
    /**
     Calculate the width, height , and if the cell will be bigger through the delegate
     - parameter indexPath: The indexpath of the item
     - parameter columnWidth: the available width
     
     - returns: (Bool, CGFloat, CGFloat) -> (if it's a bigger cell, width, height).
     */
    private func calculateVariableAttributes(indexPath: IndexPath, _ columnWidth: CGFloat = 0.0) -> (Bool, CGFloat, CGFloat) {
        if let delegate = delegate {
            let biggerCell = delegate.collectionViewBiggerCell?(indexPath) ?? false
            let width = biggerCell ? contentWidth : columnWidth
            let cellHeight = delegate.collectionView(collectionView!, availableWidth: width, heightForItemAtIndexPath: indexPath)
            return (biggerCell, width, cellHeight)
        }else {
            print("cell height = 0 because delegete is nil ")
        }
        return (false, 0.0, 0.0)
    }
}
