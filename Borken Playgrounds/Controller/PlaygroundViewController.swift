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
    
    @IBOutlet var downVoteButton: UIBarButtonItem!
    @IBOutlet var upVoteButton: UIBarButtonItem!
    @IBOutlet var playgroundElementsCollectionView: UICollectionView!
    var playgroundId: String  = ""
    var playgroundElements: [PlaygroundElement] = []
    var selectedPlayground: Playground? = nil
    var defaultButtonColor: UIColor? = nil
    @IBOutlet var descriptions: UITextView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    
    @IBOutlet var headline: UITextField!
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 4,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 30,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    
    @IBAction func backButtonClicked(_ sender: UIBarButtonItem){
        
        let navigationController = self.presentingViewController as? UINavigationController
        
        self.dismiss(animated: true) {
            let _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    fileprivate func updateButtons() {
        self.upVoteButton.tintColor = defaultButtonColor
        self.downVoteButton.tintColor = defaultButtonColor
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.user?.downVotedPlaygrounds.contains(where: { (playgroundId) -> Bool in
            return playgroundId == selectedPlayground?.id
        }) ?? false {
            self.downVoteButton.tintColor = UIColor.red
        }
        if appDelegate.user?.upVotedPlaygrounds.contains(where: { (playgroundId) -> Bool in
            return playgroundId == selectedPlayground?.id
        }) ?? false {
            self.upVoteButton.tintColor = UIColor.green
        }
    }
    
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
                        self.checkIfControlsShouldBeShown()
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
        
        self.defaultButtonColor = upVoteButton.tintColor
        updateButtons()
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
                
                if (distanceBetweenTwoLocations < 200) {
                    
                    if (!user.visitedPlaygrounds.contains(playground.id)) {
                        user.visitedPlaygrounds.append(playground.id)
                        user.save()
                    }
                    toolbar.isHidden = false
                }
            }
        }
    }
    
    func setContraints() {
        
        scrollView.snp.makeConstraints { (make) in
            
            make.top.equalTo(imageSlideshow.snp.bottom).offset(12)
            make.right.equalTo(view).offset(-12)
            make.left.equalTo(view).offset(12)
            
            if (toolbar.isHidden) {
                make.bottom.equalTo(view)
            } else {
                make.bottom.equalTo(toolbar.snp.top)
            }
        }
        headline.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView)
            make.right.equalTo(view).offset(-12)
            make.left.equalTo(view).offset(12)
            make.bottom.equalTo(descriptions.snp.top)
        }
        
        descriptions.snp.makeConstraints { (make) in
            make.top.equalTo(headline.snp.bottom)
            make.right.equalTo(view).offset(-12)
            make.left.equalTo(view).offset(12)
            make.height.greaterThanOrEqualTo(100)
        }
        
        playgroundElementsCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptions.snp.bottom)
            make.right.equalTo(view).offset(-12)
            make.left.equalTo(view).offset(12)
            make.height.greaterThanOrEqualTo(100)
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        descriptions.snp.makeConstraints { (make) in
            
            make.height.equalTo(descriptions.bounds.size.height + 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playgroundElements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let viewCell = self.playgroundElementsCollectionView.dequeueReusableCell(withReuseIdentifier: "simplePlaygroundElementViewCell", for: indexPath) as! SimplePlaygroundElementViewCell
        
        viewCell.displayContent(playgroundElement: self.playgroundElements[indexPath.row])
        
        playgroundElementsCollectionView.snp.makeConstraints { (make) in
            make.height.equalTo(playgroundElementsCollectionView.collectionViewLayout.collectionViewContentSize.height + 20)
        }
        
        return viewCell
    }
    
    @objc func didTap() {
        let fullScreenController = self.imageSlideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func initPlayground(playground: Playground) {
        
        self.selectedPlayground = playground
        self.headline.text = playground.name
        
        let images = playground.images.map { (String) -> KingfisherSource in
            KingfisherSource(urlString: String)!
        }
        self.imageSlideshow.setImageInputs(images)
        self.descriptions.text = playground.description?.htmlToString
        self.descriptions.sizeToFit()
        setContraints()
    }
    @IBAction func upVotePlayground(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.user?.upVotedPlaygrounds.first(where: { (playground) -> Bool in
            return playground == selectedPlayground?.id
        }) == nil {
            if let playgroundId = selectedPlayground?.id {
                appDelegate.user?.upVotedPlaygrounds.append(playgroundId)
            }
        } else {
            appDelegate.user?.upVotedPlaygrounds.removeAll(where: { (playgroundId) -> Bool in
                return playgroundId == selectedPlayground?.id
            })
        }
        appDelegate.user?.downVotedPlaygrounds.removeAll(where: { (playgroundId) -> Bool in
            return playgroundId == selectedPlayground?.id
        })
        updateButtons()
        appDelegate.user?.save()
    }
    @IBAction func downVotePlayground(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.user?.downVotedPlaygrounds.first(where: { (playground) -> Bool in
            return playground == selectedPlayground?.id
        }) == nil {
            if let playgroundId = selectedPlayground?.id {
                appDelegate.user?.downVotedPlaygrounds.append(playgroundId)
            }
        } else {
            appDelegate.user?.downVotedPlaygrounds.removeAll(where: { (playgroundId) -> Bool in
                return playgroundId == selectedPlayground?.id
            })
        }
        appDelegate.user?.upVotedPlaygrounds.removeAll(where: { (playgroundId) -> Bool in
            return playgroundId == selectedPlayground?.id
        })
        
        updateButtons()
        appDelegate.user?.save()
    }
    @IBAction func addRemark(_ sender: Any) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Spielplatz kommentieren", message: "Hinterlasse doch einen Kommentar zum Spielplatz. Keine Angst die Kommentare kann kein anderer sehen, aber wir schauen uns diese an und reparieren Geräte falls Sie kaputt sind. Wir freuen uns aber auch über Lob ;-)", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = "Kommentar"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Absenden", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            
            if let comment = textField?.text {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.user?.userRemarks.append(comment)
                appDelegate.user?.saveRemark(comment: comment, playground: self.selectedPlayground)
                appDelegate.user?.save()
            }
        }))
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .default, handler: { (_) in
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
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
