//
//  MainScrViewController.swift
//  fefuactivity
//
//  Created by soFuckingHot on 11.10.2021.
//

import UIKit

class MainScrViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    @IBAction func RegBtnTap(_ sender: Any) {
        let regView = RegisterController(nibName: "RegisterController", bundle: nil)
        
        navigationController?.pushViewController(regView, animated: true)
    }
    
   
    @IBAction func loginBtnDidTap(_ sender: Any) {
        let logView = LoginController(nibName: "LoginController", bundle: nil)
        
        navigationController?.pushViewController(logView, animated: true)
        
    }
    
    
    
    


}
