//
//  ProfileViewController.swift
//  fefuactivity
//
//  Created by soFuckingHot on 20.11.2021.
//

import UIKit
import Charts

//  MARK:- test section



var localActivities: [ActivitiesViewModel] = [ActivitiesViewModel]()


var ddata: [[profileTableStringModel]] = {
    let profileSection: [profileTableStringModel] = [
        profileTableStringModel(type: "login:", value: ""), profileTableStringModel(type: "name:", value: ""),
        profileTableStringModel(type: "password:", value: "")
    ]
    let genderSection: [profileTableStringModel] = [
        profileTableStringModel(type: "sex:", value: "")
    ]
    
    return [profileSection, genderSection]
}()

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate {
    
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var profileSexTable: UITableView!
    @IBOutlet weak var profileDataTableView: UITableView!
    
    var chartData: [ChartDataEntry] = []
    
    var localActivities: [ActivitiesViewModel] = [ActivitiesViewModel]()

    
    var userM: UserModel? {
        didSet {
            setUserInfo(user: userM)
        }
    }
    
    private func chartSetup() {
        chartView.backgroundColor = .white
        chartView.rightAxis.enabled = false
        chartView.xAxis.axisLineColor = .gray
        chartView.xAxis.labelTextColor = .gray
        chartView.xAxis.labelPosition = .bottom
        
    
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.axisLineColor = .gray
        chartView.leftAxis.labelTextColor = .gray
        chartView.leftAxis.axisLineColor = .gray
        
        
        chartView.leftAxis.labelCount = 2
        
    }
    
    func setData() {
        let set = LineChartDataSet(entries: chartData, label: "activity distance")
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.drawVerticalHighlightIndicatorEnabled = false
        set.colors =  [.orange]
        set.circleColors = [.orange]
        set.lineWidth = 3
        
        set.fill =  ColorFill(cgColor: UIColor.orange.cgColor)
        set.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set)
        chartView.data = data
    }
    
    func fillChartData() {
        fetchLocalActivities()
        
        //  gets activity duration from sorted activity array
        var durationPerDate: Double = 0.0
        var day = 1
        for activities in localActivities {
            for activity in activities.activities {
                print("========")
                print(activity.duration)
                durationPerDate += atof(activity.duration)
            }
            day = Calendar.current.dateComponents([.day, .year, .month], from: activities.date).day!

            chartData.append(ChartDataEntry(x: Double(day), y: durationPerDate))
            durationPerDate = 0
        }
        print("=====================")
        print(chartData)
        //chartData.append(ChartDataEntry(x: 29.0, y: 30))
        chartData.append(ChartDataEntry(x: 31, y: 10))
        
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
                profileTableStringModel(type: "password:", value: "****")
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
        
        chartSetup()
        exitBtn.layer.cornerRadius = 10
        
        fetchLocalActivities()
        fillChartData()
        setData()
        
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
}

extension ProfileViewController {
    func fetchLocalActivities() {
        let context = FEFUCoreDataContainer.instance.context
        
        let fetching = CDActivity.fetchRequest()
        
        do {
            let raw = try context.fetch(fetching)
            let activityModels: [ActivitiesTableViewModel] = raw.map {
                activity in
                let img = UIImage(systemName: "bicycle.circle.fill") ?? UIImage()
                return ActivitiesTableViewModel(distance: String(format: "%.2f", activity.distance), duration: String(format: "%.2f", activity.duration)+"m", activityTitle: activity.type ?? "", timeAgo: activity.date ?? Date(), icon: img, startTime: String(describing: activity.startTime!), endTime: String(describing: activity.endTime!) , nickname: "")
            }
            
            let groupByDate = Dictionary(grouping: activityModels) {
                activ in return createDateComponents(activ.timeAgo)
            }
            
            self.localActivities = groupByDate.map {(key, value) in
                return ActivitiesViewModel(date: key, activities: value)
            }
            
        } catch {
            
        }
    }
    
    private func createDateComponents(_ activityDate: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: activityDate)
        return calendar.date(from: components) ?? Date()
    }
}
