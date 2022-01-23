//
//  ActivityDetails.swift
//  fefuactivity
//
//  Created by soFuckingHot on 25.11.2021.
//

import UIKit
import Foundation

class ActivityDetails: UIViewController {
    @IBOutlet weak var comment: CTextField!
    
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var activityImg: UIImageView!
    @IBOutlet weak var startEnd: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var timeAgo: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var startBtn: CStyledButton!
    
    
    //  formatters
    private let duratinFormatter: DateComponentsFormatter = DateComponentsFormatter()
    private let dateFormatter: DateFormatter = DateFormatter()
    
    
    var model: ActivitiesTableViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        duratinFormatter.allowedUnits = [.hour, .minute, .second]
        duratinFormatter.zeroFormattingBehavior = .pad
        
        dateFormatter.dateStyle = .medium
               
        
    }
    @IBAction func didTapStartActivity(_ sender: Any) {
        let startActivityController = ActivityBeginViewController(nibName: "ActivityBeginViewController", bundle: nil)
        
        navigationController?.pushViewController(startActivityController, animated: true)
        
    }
    
    
    func bind(_ model: ActivitiesTableViewModel) {
        //  unpack a model
        let dist =  String(format: "%.2f km", model.distance / 1000)
        
        
        //  setting up UI
        distance.text = dist
        duration.text = duratinFormatter.string(from: model.duration)
        timeLeft.text = dateFormatter.string(from:  model.timeAgo)
        activityImg.image = model.icon
        startEnd.text = "Cтарт: \(model.startTime) Финиш: \(model.endTime)"
        activityTitle.text = model.activityTitle
        
        
        let curD = Date()
        let z = curD.timeIntervalSince(model.timeAgo)
        let secondsInHour: Double = 3600
        timeAgo.text = "\(Int(round(z / secondsInHour))) hours ago"
        //  MARK: - TODO: make 14 hours ago u td
        self.title = activityTitle.text
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startBtn.setTitle("start activity", for: .normal
        )
        
        bind(model!)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: nil, action: nil)
        
    }
    
    

}
