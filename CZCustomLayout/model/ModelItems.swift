//
//  ModelItems.swift
//  CZCustomLayout
//
//  Created by Edwin Peña on 4/9/17.
//  Copyright © 2017 Edwin Peña. All rights reserved.
//

import UIKit

class ModelItems: NSObject {
    
    var headerViewModel: [HeaderViewModel] = []
    var footerViewModel: [FooterViewModel] = []
    var ds: [Int: [ItemViewModel]] = [:]
    
    func buildDataSource(){
        
        var itemViewModel: [ItemViewModel] = []
        var item2ViewModel: [ItemViewModel] = []
        
        let item1 = ItemViewModel.init(identifier: 0, image: "image1", title:"typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem")
        
        let item2 = ItemViewModel.init(identifier: 1, image: "image2", title:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. ")
        
        let item3 = ItemViewModel.init(identifier: 2, image: "image3", title:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic ")
        
        let item4 = ItemViewModel.init(identifier: 3, image: "image4", title:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has ")
        
        let item5 = ItemViewModel.init(identifier: 4, image: "image5", title:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley ")
        
        let item6 = ItemViewModel.init(identifier: 5, image: "image6", title:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's  ")
        
        let item7 = ItemViewModel.init(identifier: 6, image: "image7", title:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, ")
        
        let item8 = ItemViewModel.init(identifier: 7, image: "image1", title:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in ")
        
        let item9 = ItemViewModel.init(identifier: 9, image: "image4", title:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has ")
        
        let item10 = ItemViewModel.init(identifier: 10, image: "image5", title:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley ")
        
        let item11 = ItemViewModel.init(identifier: 11, image: "image6", title:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's  ")
        
        let item12 = ItemViewModel.init(identifier: 12, image: "image7", title:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, ")
        
        itemViewModel.append(item1)
        itemViewModel.append(item2)
        itemViewModel.append(item3)
        itemViewModel.append(item4)
        itemViewModel.append(item5)
        itemViewModel.append(item6)
        itemViewModel.append(item7)
        itemViewModel.append(item8)
        item2ViewModel.append(item9)
        item2ViewModel.append(item10)
        item2ViewModel.append(item11)
        item2ViewModel.append(item12)
        
        ds[0] = itemViewModel
        ds[1] = item2ViewModel
    }
    
    func buildHeader() {
        let header = HeaderViewModel(title: "Header Title")
        headerViewModel.append(header)
    }
    
    func buildFooter() {
        let footer = FooterViewModel(title: "Footer Title")
        footerViewModel.append(footer)
    }
}
