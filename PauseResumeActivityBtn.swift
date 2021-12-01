//
//  PauseResumeActivityBtn.swift
//  fefuactivity
//
//  Created by soFuckingHot on 01.12.2021.
//

import Foundation
import UIKit

class PRActivityBtn: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        selfInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selfInit()
    }
    
    //  fill membres
    private func selfInit() {
        self.setTitle("", for: .normal)
        self.backgroundColor = .systemBlue
        self.layer.cornerRadius = self.bounds.size.width * 0.5
        self.isSelected = false
    }
    
    override var isSelected: Bool {
        didSet {
            self.isHighlighted = false
            if isSelected {
                self.setImage(UIImage(named: "i_resume"), for: .normal)
            } else {
                self.setImage(UIImage(named: "i_pause"), for: .normal)
            }
        }
    }
}
