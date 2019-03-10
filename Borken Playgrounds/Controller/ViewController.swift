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
import SPPermission

class MapboxViewController: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet weak var mapboxView: MGLMapView!
    
    var locationManager: CLLocationManager? = nil
    var selectedPlayground: String? = ""
    var loadedPlaygrounds:[Playground] = []
    var allPlaygroundAnnotations: [String:MGLPointAnnotation] = [String:MGLPointAnnotation]()
    var meMarker: AvatarAnnotation = AvatarAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.requestWhenInUseAuthorization()
        if let currentLocation = self.locationManager?.location?.coordinate {
            self.mapboxView.setCenter(currentLocation, zoomLevel: 11, animated: false)
        } else {
            self.mapboxView.setCenter(CLLocationCoordinate2D(latitude: 51.843890, longitude: 6.858330), zoomLevel: 11, animated: false)
        }
        
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
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isAllowedLocationWhenInUse = SPPermission.isAllowed(.locationWhenInUse)
        let isAllowedNotification = SPPermission.isAllowed(.notification)
        
        if (!isAllowedNotification && !isAllowedLocationWhenInUse) {
            SPPermission.Dialog.request(with: [.locationWhenInUse, .notification], on: self)
        } else if (!isAllowedNotification) {
            SPPermission.Dialog.request(with: [.notification], on: self)
            SPPermission.request(.locationWhenInUse, with: {
                
                self.locationManager?.startUpdatingLocation()
            })
        } else if (!isAllowedLocationWhenInUse) {
            SPPermission.Dialog.request(with: [.locationWhenInUse], on: self)
            SPPermission.request(.notification, with: {
                // Callback
            })
        } else {
            SPPermission.request(.notification, with: {
                // Callback
            })
            SPPermission.request(.locationWhenInUse, with: {
                
                self.locationManager?.startUpdatingLocation()
            })
        }
        filterPlaygroundsOnMap()
        addMeMarker()
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
                        self.mapboxView.removeAnnotation(playgroundElementAnnotation)
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
                let reuseIdentifier = "reusableDotView"
                
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
                let reuseIdentifier = "reusableDotView"
                
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
        //performSegue(withIdentifier: "ShowAvatarView", sender: nil)
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? PlaygroundViewController {
            
            viewController.playgroundId = self.selectedPlayground ?? ""
        }
    }
    
    fileprivate func addMeMarker() {
        if let currentLocation = self.locationManager?.location?.coordinate {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let avatar = appDelegate.user?.avatarUrl {
                self.mapboxView.removeAnnotation(meMarker)
                self.meMarker = AvatarAnnotation()
                self.meMarker.avatarUrl = avatar
                self.meMarker.coordinate = currentLocation
                self.meMarker.title = "Me"
                self.mapboxView.addAnnotation(meMarker)
            }
        }
    }
}

extension UINavigationController {
    var rootViewController : UIViewController? {
        return viewControllers.first
    }
}

extension MapboxViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        addMeMarker()
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        loadedPlaygrounds.forEach({ (playground) -> Void in
            
            if (playground.lat == nil || playground.lng == nil)
            {
                return
            }
            let playgroundLocation = CLLocation(latitude: CLLocationDegrees(playground.lat!), longitude: CLLocationDegrees(playground.lng!))
            
            let userLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            
            let distanceBetweenTwoLocations = playgroundLocation.distance(from: userLocation)
            
            if (distanceBetweenTwoLocations < 100) {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if let user = appDelegate.user {
                    if (!user.visitedPlaygrounds.contains(playground.id)) {
                        user.visitedPlaygrounds.append(playground.id)
                        let visitedPlaygroundsByUser = user.visitedPlaygrounds.count
                        let firstNotification = appDelegate.notifications?.visitedPlaygroundsNotifications.first(where: { (notification) -> Bool in
                            return notification.visitedPlaygrounds == visitedPlaygroundsByUser
                        })
                        
                        if let notification = firstNotification {
                            let userInfo = notification.toHashMap()
                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: notification.title), object: self, userInfo: userInfo))
                        }
                        user.save()
                    }
                }
            }
        })
    }
}
