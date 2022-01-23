//
//  passwordInput.swift
//  fefuactivity
//
//  Created by soFuckingHot on 23.01.2022.
//

import Foundation
import UIKit


class passwordInput : UITextField {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selfInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        selfInit()
    }
    
    private func selfInit() {
        self.layer.cornerRadius = 8
        self.layer.backgroundColor = UIColor(red: 0.471, green: 0.471, blue: 0.52, alpha: 0.16).cgColor
        self.backgroundColor = UIColor(red: 0.471, green: 0.471, blue: 0.52, alpha: 0.16)
        
    }
}
