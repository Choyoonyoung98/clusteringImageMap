//
//  UIViewExtension.swift
//  MapClustering
//
//  Created by 조윤영 on 2020/05/14.
//  Copyright © 2020 Yoo Hwa Park. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func circleRadius() {
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 1.0
    }
    
    func round(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func customShadow(width: CGFloat, height: CGFloat, radius: CGFloat, opacity: Float) {
        self.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.layer.shadowOffset = CGSize(width: width, height: height)
        
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.masksToBounds = false
    }
}
