//
//  DetailImgCollectionviewCellCollectionViewCell.swift
//  MyUnsplash
//
//  Created by kisoo Um on 2020/11/19.
//  Copyright © 2020 kisoo Um. All rights reserved.
//

import UIKit

class DetailImgCollectionviewCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setImg(i : UIImage)
    {
        self.setSize()
        self.img.image = i
        
    }
    func setSize(){
        img.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)

    }
    
}
