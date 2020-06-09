//
//  CategoryCVCell.swift
//  MapClustering
//
//  Created by 조윤영 on 2020/05/14.
//  Copyright © 2020 Yoo Hwa Park. All rights reserved.
//

import UIKit

class CategoryCVCell: UICollectionViewCell {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var baseInnerView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        baseInnerView.circleRadius()
        baseInnerView.layer.borderColor = UIColor.clear.cgColor
        baseInnerView.customShadow(width: 0, height: 3, radius: 3, opacity: 0.12)
        baseInnerView.layer.borderWidth = 1.6
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                baseInnerView.layer.borderColor =   #colorLiteral(red: 0.5333333333, green: 0.8039215686, blue: 0.9647058824, alpha: 1)
        } else {
                baseInnerView.layer.borderColor  = UIColor.clear.cgColor
            }
        }
    }
    
}
