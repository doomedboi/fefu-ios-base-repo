//
//  StartActivityBtn.swift
//  fefuactivity
//
//  Created by soFuckingHot on 01.12.2021.
//

//  y menya misl: a est' li smisl sozdavat' class pod knopcku,
//  kotoruy ispolzuem vsego 1 raz, nu da ladno...
import Foundation
import UIKit

class FinishActivityBtn: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        selfInit()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selfInit()
    }
    
    private func selfInit() {
        self.setTitle("", for: .normal)
        self.layer.cornerRadius = self.bounds.size.width * 0.5
        self.backgroundColor = UIColor(named: "BlueBtnColor")
        self.setImage(UIImage(named: "i_finish"), for: .normal)
    }
}
