//
//  CTopCornersView.swift
//  fefuactivity
//
//  Created by soFuckingHot on 02.12.2021.
//

import UIKit


class TopCornersView: UIView {
    private func selfInit() {
        self.layer.cornerRadius = 25
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        selfInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selfInit()
    }
    
}
