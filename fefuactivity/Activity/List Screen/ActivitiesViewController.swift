//
//  ActivitiesViewController.swift
//  fefuactivity
//
//  Created by soFuckingHot on 20.11.2021.
//

import UIKit
import CoreData
import CoreLocation


struct ActivitiesViewModel {
    let date: Date
    let activities: [ActivitiesTableViewModel]
}

class ActivitiesViewController: UIViewController {
    
    private var data: [ActivitiesViewModel] = [ActivitiesViewModel]()
    
    @IBOutlet weak var emptyActivitiesScreen: UIView!
    @IBOutlet weak var activitiesTable: UITableView!
    @IBOutlet weak var emptyActivitiesDesc: UILabel!
    @IBOutlet weak var emptyActivitiesTitile: UILabel!
    @IBOutlet weak var startBtn: CStyledButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    var selectedSection: Int = 0
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selfInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentOutlet.selectedSegmentIndex = 0
        fetch(index: 0)
        self.activitiesTable.reloadData()
    }
    
    private func fetch(index: Int) {
        if index == 0 {
            fetchFromCoreData()
        } else {
            fetchSocialActivity()
        }
    }
    
    @objc func segmentHandler(_ sender: UISegmentedControl) {
        
        
        fetch(index: self.segmentOutlet.selectedSegmentIndex)
    }
    
    private func createDateComponents(_ activityDate: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: activityDate)
        return calendar.date(from: components) ?? Date()
    }
    
    private func reloadContent() {
        DispatchQueue.main.async {
            self.activitiesTable.reloadData()
        }
    }
    
    private func fetchFromCoreData() {
        print("data")
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
            
            self.data = groupByDate.map {(key, value) in
                return ActivitiesViewModel(date: key, activities: value)
            }
            
            reloadContent()
            
        } catch {
            
        }
        
    }
    
    private func fetchSocialActivity() {
        print("social")
        AuthRegUrlManager.activities { row in
            print(row)
            DispatchQueue.main.async {
                let activityModels: [ActivitiesTableViewModel] = row.items.map{activity in
                    let img = UIImage(systemName: "bicycle.circle.fill") ?? UIImage()
                    var prevlocation: CLLocation?
                    var dist = 0.0
                    activity.geo_track.forEach({ location in
                        let loc = CLLocation(latitude: location.lat, longitude: location.lon)
                        if prevlocation != nil {
                            dist += loc.distance(from: prevlocation!) / 1000
                        }
                        prevlocation = loc
                    })
                    
                    /* section of UB aims to convert strings to date*/
                    let dataFormatter = DateFormatter()
                    dataFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dataFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let startTime = dataFormatter.date(from: activity.starts_at)
                    let endTime = dataFormatter.date(from: activity.ends_at)
                    
                    let formatter = RelativeDateTimeFormatter()
                    formatter.unitsStyle = .full
                    
                    let calendar = Calendar.current
                    let dur = formatter.localizedString(for: startTime!, relativeTo: endTime!)
                    let durH = Double(dur.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
                    
                    let startTimeHour = calendar.component(.hour, from: startTime!)
                    let startTimeMinutes = calendar.component(.minute, from: startTime!)
                    
                    let finishHour = calendar.component(.hour, from: endTime!)
                    let finishMins = calendar.component(.minute, from: endTime!)
                    
                    
                    return ActivitiesTableViewModel(distance: String(format: "%.2f",  dist), duration: String(describing:  durH!)+"h", activityTitle: activity.activity_type.name , timeAgo: endTime! , icon: img, startTime: String(describing: "\(startTimeHour):\(startTimeMinutes)"), endTime: String(describing: "\(finishHour):\(finishMins)"), nickname: "@" + activity.user.name)
                }
                
                let groupByDate = Dictionary(grouping: activityModels) {
                    activ in
                    return self.createDateComponents(activ.timeAgo)
                }
                
                self.data = groupByDate.map {(key, value) in
                    return ActivitiesViewModel(date: key, activities: value)
                }
                
                self.reloadContent()
            }
        }
    }
    
    
    private func selfInit() {
        self.title = "Активности"
        
        startBtn.setTitle("Старт", for: .normal)
        startBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        
        emptyActivitiesTitile.text = "Время потренить"
        emptyActivitiesDesc.text = "Нажимай на кнопку ниже и начинаем трекать активность"
        emptyActivitiesScreen.backgroundColor = .clear
        
        activitiesTable.dataSource  = self
        activitiesTable.delegate = self
        
        activitiesTable.register(UINib(nibName: "ActivitiesCellTableViewCell", bundle: nil), forCellReuseIdentifier: "ActivitiesCellTableViewCell")
        
        activitiesTable.separatorStyle = .none
        activitiesTable.backgroundColor = .clear
        activitiesTable.isHidden = !self.data.isEmpty
        
        //  welcome screen [no activities]
        emptyActivitiesScreen.isHidden = self.data.isEmpty
        
        dateFormatter.dateStyle = .medium
        
        headerView.layer.backgroundColor = UIColor(red: 0.976, green: 0.976, blue: 0.976, alpha: 0.94).cgColor
        segmentOutlet.addTarget(self, action: #selector(segmentHandler(_:)), for: .valueChanged)
    }
    
    
    
    @IBAction func didStartBtnTap(_ sender: Any) {
        let activityController = ActivityBeginViewController(nibName: "ActivityBeginViewController", bundle: nil)
        
        navigationController?.pushViewController(activityController, animated: true)
    }
}


extension ActivitiesViewController: 	UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UILabel()
        header.font = .boldSystemFont(ofSize: 20)
        
        
        
        let date = data[section].date
        let optHeader = dateFormatter.string(from: date)
        header.text = optHeader
        
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let activityData = self.data[indexPath.section].activities[indexPath.row]
        
        let dequeuedCell = activitiesTable.dequeueReusableCell(withIdentifier: "ActivitiesCellTableViewCell", for: indexPath)
        
        // not work without guard asks unwrap
        guard let upcastedCell = dequeuedCell as? ActivitiesCellTableViewCell
        else {
            return UITableViewCell()
        }
        
        upcastedCell.bind(activityData)
        
        return upcastedCell
    }
    
}

extension ActivitiesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let detailsView = ActivityDetails(nibName: "ActivityDetails", bundle: nil)
        
        let activity = self.data[indexPath.section].activities[indexPath.row]
        detailsView.model = activity
        
        navigationController?.pushViewController(detailsView, animated: true)
    }
    
}
