//
//  ViewController.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 22.10.18.
//  Copyright © 2018 Jugendwerk Borken. All rights reserved.
//

import UIKit
import Mapbox
import Firebase
import Kingfisher
import SparrowKit
import SPPermission.Swift
import CircleMenu

class MapboxViewController: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet var circleMenuButton: CircleMenu!
    @IBOutlet weak var mapboxView: MGLMapView!
    
    var locationManager: CLLocationManager? = nil
    var selectedPlayground: String? = ""
    var loadedPlaygrounds:[Playground] = []
    var allPlaygroundAnnotations: [String:MGLPointAnnotation] = [String:MGLPointAnnotation]()
    var meMarker: AvatarAnnotation = AvatarAnnotation()
    
    @IBAction func circleMenu(_ sender: CircleMenu) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.circleMenuButton.delegate = self
        self.circleMenuButton.layer.cornerRadius = self.circleMenuButton.frame.size.width / 2.0
        
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        
        self.mapboxView.annotations?.forEach({ (annotation) in
            self.mapboxView.removeAnnotation(annotation)
        })
        self.mapboxView.setCenter(CLLocationCoordinate2D(latitude: 51.843890, longitude: 6.858330), zoomLevel: 11.0, animated: true)
        self.mapboxView.delegate = self
        
        let db = Firestore.firestore()
        
        db.collection("playgrounds").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let playground = Playground(documentId: document.documentID, dictionary: document.data(), completion: {
                        (playgroundElement: PlaygroundElement) -> Void in
                        
                    })!
                    self.loadedPlaygrounds.append(playground)
                    self.addPlaygroundMarkerToMap(playground: playground)
                    self.addMeMarker()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        let isAllowedLocationWhenInUse = SPPermission.isAllowed(.locationWhenInUse)
        
        if (!isAllowedLocationWhenInUse) {
            SPPermission.Dialog.request(with: [.locationWhenInUse], on: self, delegate: self)
        } else {
            SPPermission.request(.locationWhenInUse, with: {
                
                self.locationManager?.startUpdatingLocation()
            })
        }
        self.filterPlaygroundsOnMap()
        self.addMeMarker()
    }
    
    private func filterPlaygroundsOnMap() {
        
        if (loadedPlaygrounds.count == 0) {
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let selectedPlaygroundElements = Set<PlaygroundElement>(appDelegate.selectedPlaygroundElements)
        
        var playgroundElementIdToAnnotation: [String: MGLAnnotation] = [String: MGLAnnotation]()
        if let annotations = self.mapboxView.annotations {
            
            annotations.forEach { (annotation) in
                if let id = annotation.subtitle {
                    if let id2 = id {
                        playgroundElementIdToAnnotation[id2] = annotation
                    }
                }
            }
        }
        
        loadedPlaygrounds.forEach { (playground) in
            
            let alreadyOnMap = playgroundElementIdToAnnotation.contains(where: { (key, value) -> Bool in
                return playground.id == key
            })
            
            let playgroundPlaygroundElements = Set<PlaygroundElement>(playground.items)
            if let playgroundElementAnnotation = self.allPlaygroundAnnotations[playground.id] {
                if (selectedPlaygroundElements.isSubset(of: playgroundPlaygroundElements)) {
                    if (!alreadyOnMap) {
                        self.mapboxView.addAnnotation(playgroundElementAnnotation)
                    }
                } else {
                    if (alreadyOnMap) {
                        if (playgroundElementAnnotation is PlaygroundAnnotation) {
                            self.mapboxView.removeAnnotation(playgroundElementAnnotation)
                        }
                    }
                }
            }
        }
    }
    
    func addPlaygroundMarkerToMap(playground: Playground) {
        
        if playground.lat == nil || playground.lng == nil {
            return
        }
        
        // Add a point annotation
        let annotation = PlaygroundAnnotation()
        annotation.willUseImage = true
        annotation.coordinate = CLLocationCoordinate2D(latitude: playground.lat!, longitude: playground.lng!)
        annotation.title = playground.name
        annotation.subtitle = playground.id
        self.allPlaygroundAnnotations[playground.id] = annotation
        self.mapboxView.addAnnotation(annotation)
    }
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if let castAnnotation = annotation as? PlaygroundAnnotation {
            if (castAnnotation.willUseImage) {
                // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
                let reuseIdentifier = "reusablePlaygroundView"
                
                // For better performance, always try to reuse existing annotations.
                var annotationView = mapboxView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
                
                // If there’s no reusable annotation view available, initialize a new one.
                if annotationView == nil {
                    annotationView = CustomImageAnnotationView(reuseIdentifier: reuseIdentifier)
                }
                
                return annotationView
            }
        }
        
        if let castAnnotation = annotation as? AvatarAnnotation {
            if (!castAnnotation.avatarUrl.isEmpty) {
                // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
                let reuseIdentifier = "reusableAvatarView"
                
                // For better performance, always try to reuse existing annotations.
                var annotationView = mapboxView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
                
                // If there’s no reusable annotation view available, initialize a new one.
                if annotationView == nil {
                    annotationView = CustomAvatarAnnotationView(reuseIdentifier: reuseIdentifier, avatarUrl: castAnnotation.avatarUrl)
                }
                
                return annotationView
            }
        }
        
        // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
        let reuseIdentifier = "reusableDotView"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapboxView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
            annotationView?.layer.borderWidth = 4.0
            annotationView?.layer.borderColor = UIColor.white.cgColor
            annotationView!.backgroundColor = UIColor(red: 0.03, green: 0.80, blue: 0.69, alpha: 1.0)
        }
        
        return annotationView
    }
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        
        if annotation as? PlaygroundAnnotation != nil {
            self.selectedPlayground = annotation.subtitle ?? ""
            performSegue(withIdentifier: "ShowPlayground", sender: nil)
        }
        
        if annotation as? AvatarAnnotation != nil {
            
            if let currentLocation = self.locationManager?.location?.coordinate {
                loadedPlaygrounds.forEach({ (playground) -> Void in
                    
                    if (playground.lat == nil || playground.lng == nil)
                    {
                        return
                    }
                    let playgroundLocation = CLLocation(latitude: CLLocationDegrees(playground.lat!), longitude: CLLocationDegrees(playground.lng!))
                    
                    let userLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                    
                    let distanceBetweenTwoLocations = playgroundLocation.distance(from: userLocation)
                    
                    if (distanceBetweenTwoLocations < 100) {
                        
                        self.selectedPlayground = playground.id
                        performSegue(withIdentifier: "ShowPlayground", sender: nil)
                    }
                })
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? UINavigationController {
        
            if let rootViewController = viewController.rootViewController as? PlaygroundViewController {
                
                rootViewController.playgroundId = self.selectedPlayground ?? ""
            }
        }
    }
    
    fileprivate func addMeMarker() {
        
        var zoomLevel = 11.0
        if (self.mapboxView.zoomLevel > 11) {
            zoomLevel = self.mapboxView.zoomLevel
        }
        
        if let currentLocation = self.locationManager?.location?.coordinate {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let avatar = appDelegate.user?.avatarUrl {
                
                self.mapboxView.annotations?.forEach({ (annotation) in
                    
                    if let castAnnotation = annotation as? AvatarAnnotation {
                        self.mapboxView.removeAnnotation(castAnnotation)
                    }
                })
                
                self.meMarker = AvatarAnnotation()
                self.meMarker.avatarUrl = avatar
                self.meMarker.coordinate = currentLocation
                self.meMarker.title = "Me"
                self.mapboxView.addAnnotation(meMarker)
                
                visitPlayground(currentLocation)
                self.mapboxView.setCenter(currentLocation, zoomLevel: zoomLevel, animated: true)
                return
            }
        }
        self.mapboxView.setCenter(CLLocationCoordinate2D(latitude: 51.843890, longitude: 6.858330), zoomLevel: zoomLevel, animated: true)
    }
    
    fileprivate func visitPlayground(_ locValue: CLLocationCoordinate2D) {
        loadedPlaygrounds.forEach({ (playground) -> Void in
            
            if (playground.lat == nil || playground.lng == nil)
            {
                return
            }
            let playgroundLocation = CLLocation(latitude: CLLocationDegrees(playground.lat!), longitude: CLLocationDegrees(playground.lng!))
            
            let userLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            
            let distanceBetweenTwoLocations = playgroundLocation.distance(from: userLocation)
            
            if (distanceBetweenTwoLocations <= 200) {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if let user = appDelegate.user {
                    if (!user.visitedPlaygrounds.contains(playground.id)) {
                        user.visitedPlaygrounds.append(playground.id)
                        user.save()
                    }
                }
            }
        })
    }
}

extension UINavigationController {
    var rootViewController : UIViewController? {
        return viewControllers.first
    }
}

extension MapboxViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let _: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        addMeMarker()
    }
}

extension MapboxViewController: CircleMenuDelegate {
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        
        switch atIndex {
        case 0:
            button.setImage(UIImage.init(named: "baseline_filter_list_white_48pt"), for: .normal)
        case 1:
            button.setImage(UIImage.init(named: "baseline_help_outline_white_48pt"), for: .normal)
        default:
            button.setImage(UIImage.init(named: "baseline_more_horiz_white_48pt"), for: .normal)
        }
        button.backgroundColor = UIColor(named: "colorAccent")
        button.tintColor = Color.white
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        
        switch atIndex {
        case 0:
            performSegue(withIdentifier: "showFilterView", sender: nil)
        case 1:
            performSegue(withIdentifier: "showHelpView", sender: nil)
        default:
            performSegue(withIdentifier: "showMoreView", sender: nil)
        }
    }
}

extension MapboxViewController: SPPermissionDialogDelegate {
    func didAllow(permission: SPPermissionType) {
        self.locationManager?.startUpdatingLocation()
    }
}
