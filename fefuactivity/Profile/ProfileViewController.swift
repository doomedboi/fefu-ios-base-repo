//
//  ProfileViewController.swift
//  fefuactivity
//
//  Created by soFuckingHot on 20.11.2021.
//

import UIKit
import Charts

var ddata: [[profileTableStringModel]] = {
    let profileSection: [profileTableStringModel] = [
        profileTableStringModel(type: "xx1", value: "xx1"), profileTableStringModel(type: "xx2", value: "xx2"),
        profileTableStringModel(type: "xx3", value: "xx3")
    ]
    let genderSection: [profileTableStringModel] = [
        profileTableStringModel(type: "xx4", value: "xx4")
    ]
    
    return [profileSection, genderSection]
}()

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate {
    
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var profileSexTable: UITableView!
    @IBOutlet weak var profileDataTableView: UITableView!
    
    var userM: UserModel? {
        didSet {
            setUserInfo(user: userM)
        }
    }
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .blue
        chartView.rightAxis.enabled = false
        
        return chartView
    }()
    
    func setData() {
        let set = LineChartDataSet(entries: [], label: "")
        
        let data = LineChartData(dataSet: set)
        lineChartView.data = data
    }
    //  MARK:- table view content
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            navigationController?.pushViewController(UIViewController(nibName: "ChangePasswViewController", bundle: nil), animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ddata[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ddata[indexPath.section][indexPath.row]
        let deqCell = profileDataTableView.dequeueReusableCell(withIdentifier: "ProfileDataTableViewCell", for: indexPath)
        
        if indexPath.row == 2 {
            deqCell.accessoryType = .disclosureIndicator
        }
        
        guard let castedCell = deqCell as? ProfileDataTableViewCell else { return UITableViewCell() }
        castedCell.bind(cell)
        
        return castedCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ddata.count
    }
    
    //  MARK:- end table view content
    
    @IBAction func exitBtnDidTap(_ sender: Any) {
        AuthRegUrlManager.logout {
            DispatchQueue.main.async {
                //  remove user token ang go out to the basic page
                AuthRegDataManager.intance.deleteKey(nameOfKey: AuthRegDataManager.userPublickKey)
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                
                vc?.modalPresentationStyle = .overFullScreen
                self.present(vc!, animated: true)
            }
        }
    }
    
    private func setUserInfo(user: UserModel?) {
        let login = user?.login ?? "error"
        let name = user?.name ?? "error"
        let sex = user?.gender ?? Gender(code: 0, name: "error")
        
        ddata = {
            let profileSection: [profileTableStringModel] = [
                profileTableStringModel(type: "login:", value: login),
                profileTableStringModel(type: "name:", value: name),
                profileTableStringModel(type: "password", value: "****")
            ]
            let genderSection: [profileTableStringModel] = [
                profileTableStringModel(type: "sex:", value: sex.name)
            ]
            
            return [profileSection, genderSection]
        }()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AuthRegUrlManager.profile { user in
            DispatchQueue.main.async {
                self.userM = user
                self.profileDataTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Профиль"
        
        profileDataTableView.delegate = self
        profileDataTableView.dataSource = self
        
        profileDataTableView.register(UINib(nibName: "ProfileDataTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileDataTableViewCell")
        
        chartView.addSubview(lineChartView)
        setData()
        exitBtn.layer.cornerRadius = 10
        
    }
}

