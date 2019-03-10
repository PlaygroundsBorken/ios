//
//  PlaygroundViewController.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 01.12.18.
//  Copyright © 2018 Jugendwerk Borken. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import ImageSlideshow
import Kingfisher
import SkeletonView
import SnapKit
import CoreLocation

class PlaygroundViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var playgroundElementsCollectionView: UICollectionView!
    var playgroundId: String  = ""
    var playgroundElements: [PlaygroundElement] = []
    var selectedPlayground: Playground? = nil
    
    @IBOutlet var descriptions: UITextView!
    
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 4,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 30,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !playgroundId.isEmpty {
            
            let db = Firestore.firestore()
            
            db.collection("playgrounds").document(playgroundId).getDocument { (document, err) in
                
                if let document = document, document.exists {
                    let playground = Playground(documentId: document.documentID, dictionary: document.data()!, completion: {
                        (playgroundElement: PlaygroundElement) -> Void in
                        self.playgroundElements.append(playgroundElement)
                        self.playgroundElementsCollectionView.reloadData()
                    })
                    if (playground != nil) {
                        self.initPlayground(playground: playground!)
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
        
        self.imageSlideshow.slideshowInterval = 5.0
        self.imageSlideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        self.imageSlideshow.contentScaleMode = UIView.ContentMode.scaleToFill
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        self.imageSlideshow.pageIndicator = pageControl
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(PlaygroundViewController.didTap))
        self.imageSlideshow.addGestureRecognizer(recognizer)
        
        self.playgroundElementsCollectionView.collectionViewLayout = self.columnLayout
        self.playgroundElementsCollectionView.contentInsetAdjustmentBehavior = .always
        
        self.playgroundElementsCollectionView.allowsMultipleSelection = true
    }
    
    private func checkIfControlsShouldBeShown() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let user = appDelegate.user {
            
            let locationManager = CLLocationManager()
            guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
            
            if let playground = selectedPlayground {
                let playgroundLocation = CLLocation(latitude: CLLocationDegrees(playground.lat!), longitude: CLLocationDegrees(playground.lng!))
                
                let userLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
                
                let distanceBetweenTwoLocations = playgroundLocation.distance(from: userLocation)
                
                if (distanceBetweenTwoLocations < 100) {
                    
                    if (!user.visitedPlaygrounds.contains(playground.id)) {
                        user.visitedPlaygrounds.append(playground.id)
                        user.save()
                    }
                }
            }
        }
    }
    
    func setContraints() {
        
        /*
         imageSlideshow.translatesAutoresizingMaskIntoConstraints = false
         imageSlideshow.snp.makeConstraints { (make) in
         make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
         make.width.equalTo(view.snp.width)
         make.left.right.equalTo(view)
         }
         
         imageSlideshow.snp.makeConstraints { (make) in
         make.height.equalTo(imageSlideshow.snp.width).multipliedBy(9 / 16)
         }*/
        
        /*
         scrollView.snp.makeConstraints { (make) in
         make.top.equalTo(imageSlideshow.snp.bottom)
         make.left.right.equalTo(view)
         make.bottom.equalTo(toolbar.snp.top)
         }
         contentView.snp.makeConstraints { (make) in
         make.top.bottom.equalTo(scrollView)
         make.left.right.equalTo(view) // => IMPORTANT: this makes the width of the contentview static (= size of the screen), while the contentview will stretch vertically
         }
         
         descriptions.snp.makeConstraints { (make) in
         make.top.equalTo(imageSlideshow)
         make.left.right.equalTo(view)
         }
         
         playgroundElementsCollectionView.snp.makeConstraints { (make) in
         make.top.equalTo(descriptions.snp.bottom)
         make.left.right.equalTo(view)
         make.height.equalTo(50)
         make.bottom.equalTo(scrollView)
         }
         toolbar.translatesAutoresizingMaskIntoConstraints = false
         toolbar.snp.makeConstraints { (make) in
         make.top.equalTo(scrollView.snp.bottom)
         make.height.equalTo(48)
         make.left.right.equalTo(view)
         if #available(iOS 11, *) {
         make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
         } else {
         make.bottom.equalTo(view)
         }
         }*/
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playgroundElements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let viewCell = self.playgroundElementsCollectionView.dequeueReusableCell(withReuseIdentifier: "simplePlaygroundElementViewCell", for: indexPath) as! SimplePlaygroundElementViewCell
        
        viewCell.displayContent(playgroundElement: self.playgroundElements[indexPath.row])
        
        return viewCell
    }
    
    @objc func didTap() {
        let fullScreenController = self.imageSlideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func initPlayground(playground: Playground) {
        
        self.selectedPlayground = playground
        self.title = playground.name
        
        let images = playground.images.map { (String) -> KingfisherSource in
            KingfisherSource(urlString: String)!
        }
        self.imageSlideshow.setImageInputs(images)
        self.descriptions.text = playground.description?.htmlToString
        self.descriptions.sizeToFit()
        setContraints()
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
