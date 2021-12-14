//
//  LoginController.swift
//  fefuactivity
//
//  Created by soFuckingHot on 11.11.2021.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    struct RegUserModel: Decodable, Encodable {
        let login: String
        let pasword: String
        let name: String
        let genre: Int
    }
    
    struct RegUserResp: Decodable {
        let token: String
    }
    
    
    
    @IBAction func didLoginBtnTap(_ sender: Any) {
        //  la-la-la & post
        let username = loginTextField.text ?? ""
        let passw = passTextField.text ?? ""
        
        //  check fields are not empty
        if (username == "" || passw == "") {
            let alert = UIAlertController(title: "Wrong data", message: "Fields cannot be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        if !checkPassCorrect(password: passw) {
            let alert = UIAlertController(title: "Password is too small.",
                                          message: "Minimal size is 8 characters!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let userData =  UserLoginReq(login: username, password: passw)
        do {
            let jsonUserData = try AuthRegUrlManager.encoder.encode(userData)
            
            AuthRegUrlManager.instance.login(jsonUserData) { user in
                print(user.token)
                //  save user data
                AuthRegDataManager.intance.saveUser(login: username, password: passw, pabKey: user.token)
                //  change view
                DispatchQueue.main.async {
                    let view = TabsViewController(nibName: "TabsViewController", bundle: nil)
                    view.modalPresentationStyle = .fullScreen
                    self.present(view, animated: true, completion: nil)
                }
            }
        } catch {
            print("error: unpacking json")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        selfInit()
    }

    
    private func fetchUserData() {
        //  fetch data via RegAuthManager
        loginTextField.text = AuthRegDataManager.intance.getKey(nameOfKey: AuthRegDataManager.userNameKey) ?? ""
        passTextField.text = AuthRegDataManager.intance.getKey(nameOfKey: AuthRegDataManager.userPassKey) ?? ""
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func selfInit() {
        let backBtn = UIBarButtonItem()
        backBtn.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem = backBtn
        
        
    }

}
