//
//  ActivityBeginViewController.swift
//  fefuactivity
//
//  Created by soFuckingHot on 26.11.2021.
//

import UIKit
import CoreLocation
import MapKit
import CoreData



private let activitiesTypeData: [ActivityTypeCellModel] =
[
    ActivityTypeCellModel(nameOfType: "Bycicle", imageType: UIImage(named: "i_lilBackground") ?? UIImage(), manageStateTitle: "On bycicle"),
    ActivityTypeCellModel(nameOfType: "Run", imageType: UIImage(named: "i_lilBackground") ?? UIImage(), manageStateTitle: "Run")
]


class ActivityBeginViewController: UIViewController {

    //  MARK: - fields:
    //  MARK: - start tracking screen views
    @IBOutlet weak var createScreen: UIView!
    @IBOutlet weak var createTitle: UILabel!
    @IBOutlet weak var listActivitiesType: UICollectionView!
    @IBOutlet weak var startBtn: CStyledButton!
    
    //  MARK: - manage tracking screen views
    @IBOutlet weak var manageScreen: UIView!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var pauseBtn: CStyledButton!
    @IBOutlet weak var typeActivity: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    private var pickedActivityType: String?
    private let userLocationIdentifier = "user_icon"
    
    @IBOutlet weak var mapView: MKMapView!
    private var m_activityType: String?
    
    
    // for deleting
    private var prevSegment: MKPolyline?
    
    private let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return manager
    }()
    
    @IBAction func didTapBeginActivity(_ sender: Any) {
        createScreen.isHidden = true
        manageScreen.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Новая активность"
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.tag = 1
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    
        listActivitiesType.register(
            UINib(nibName: "ActivityTypeCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier:
                String(describing: ActivityTypeCollectionViewCell.self
            )
        )
        
        listActivitiesType.delegate = self
        listActivitiesType.dataSource = self
        
        initCreateActivityScr()
        initManageActivityScr()
    }

    //  MARK: - screens initializers
    private func initCreateActivityScr() {
        //listActivitiesType.dataSource = self
        listActivitiesType.delegate = self
        
        createScreen.layer.cornerRadius = 25
        
        createScreen.isHidden = false
        
        createTitle.text = "Погнали? :)"
        startBtn.setTitle("Старт", for: .normal)
    }

    private func initManageActivityScr() {
        manageScreen.layer.cornerRadius = 25
        
        manageScreen.isHidden = true
        
        typeActivity.text = "Activity"
        distance.text = "0.00 km"
        timeLabel.text = "00:00:00"
    }
   var userLocation: CLLocation? {
        didSet {
            if let userLocation = userLocation {
                let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                
                mapView.setRegion(region, animated: true)
                
                userLocationsHistory.append(userLocation)
            }
        }
    }
    
    
    fileprivate var userLocationsHistory: [CLLocation] = [] {
        didSet {
            let coordinates = userLocationsHistory.map { $0.coordinate }
            
            
            
            let route = MKPolyline(coordinates: coordinates, count: coordinates.count)
            route.title = "Ваш маршрут"
            
            prevSegment = route
            
            mapView.addOverlay(route)
        }
    }
    
}

extension ActivityBeginViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("im here")
        //print(locations)
        guard let currentLocation = locations.first else {
            return
        }
        userLocation = currentLocation
        
    }
}


extension ActivityBeginViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let render = MKPolylineRenderer(polyline: polyline)
            
            render.fillColor = UIColor(named: "BlueBtnColor")
            render.strokeColor = UIColor(named: "BlueBtnColor")
            render.lineWidth = 5
            
            return render
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKUserLocation {
            let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: userLocationIdentifier)
                
            let view = dequedView ?? MKAnnotationView(annotation: annotation, reuseIdentifier: userLocationIdentifier)
            
            view.image = UIImage(named: "UserLocation")
            return view
        }
        return nil
    }
}

//  MARK: - delegates
extension ActivityBeginViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //  we want to make blue silhoute uppon our btn
        if let cell = collectionView.cellForItem(at: indexPath) as? ActivityTypeCollectionViewCell {
            cell.cardView.layer.borderColor = UIColor(named: "BlueBtnColor")?.cgColor
            
            cell.cardView.layer.borderWidth = 2
            m_activityType = cell.gTypeName
            pickedActivityType = cell.gTypeName
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ActivityTypeCollectionViewCell {
            cell.cardView.layer.borderWidth = 0
        }
    }
}



//  MARK: - data sources

extension ActivityBeginViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  activitiesTypeData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentActivity = activitiesTypeData[indexPath.row]
        
        if let deqCell = listActivitiesType.dequeueReusableCell(withReuseIdentifier: "ActivityTypeCollectionViewCell", for: indexPath) as? ActivityTypeCollectionViewCell {
            deqCell.bind(currentActivity)
            return deqCell
        } else {
            return UICollectionViewCell()
        }
    }
}


