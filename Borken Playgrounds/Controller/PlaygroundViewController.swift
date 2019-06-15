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
import Cosmos

class PlaygroundViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var ratingBarWrapper: UIView!
    @IBOutlet var ratingBar: CosmosView!
    @IBOutlet var downVoteButton: UIBarButtonItem!
    @IBOutlet var upVoteButton: UIBarButtonItem!
    @IBOutlet var playgroundElementsCollectionView: UICollectionView!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    
    @IBOutlet var elementsHeaderView: PlaygroundHeaderView!
    var playgroundId: String  = ""
    var playgroundElements: [PlaygroundElement] = []
    var selectedPlayground: Playground? = nil
    var defaultButtonColor: UIColor? = nil
    var referenceHeadSize:CGFloat = 40.0
    
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
                        self.updateViewConstraints()
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
                    
                    updateButtons()
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        view.setNeedsUpdateConstraints()
    }
    
    func setContraints() {
        
        imageSlideshow.snp.makeConstraints { (make) in
            
            make.top.left.equalTo(view)
            if UIDevice.current.orientation.isLandscape {
                make.right.equalTo(view.snp.centerX)
            } else {
                make.right.equalTo(view)
            }
            make.height.lessThanOrEqualTo(355)
        }
        
        playgroundElementsCollectionView.snp.makeConstraints { (make) in
            
            make.right.equalTo(view).offset(-12)
            if UIDevice.current.orientation.isLandscape {
                make.top.equalTo(view)
                make.left.equalTo(view.snp.centerX).offset(12)
            } else {
                make.left.equalTo(view).offset(12)
                make.top.equalTo(imageSlideshow.snp.bottom)
            }
            
            make.height.greaterThanOrEqualTo(100)
            
            if (toolbar.isHidden) {
                make.bottom.equalTo(view)
            } else {
                make.bottom.equalTo(toolbar.snp.top)
            }
        }
        
        ratingBarWrapper.snp.makeConstraints { (make) in
            make.bottom.equalTo(imageSlideshow).offset(-40)
            make.right.equalTo(imageSlideshow)
            //make.height.equalTo(60)
        }
        
        ratingBar.snp.makeConstraints { (make) in
            make.left.top.equalTo(ratingBarWrapper).offset(6)
            make.right.equalTo(ratingBarWrapper).offset(-24)
            make.bottom.equalTo(ratingBarWrapper).offset(-6)
        }
        
        //ratingBar.bounds = ratingBar.frame.insetBy(dx: 10.0, dy: 10.0)
    }
    
    @objc func didTap() {
        let fullScreenController = self.imageSlideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func initPlayground(playground: Playground) {
        
        self.selectedPlayground = playground
        
        let images = playground.images.map { (String) -> KingfisherSource in
            KingfisherSource(urlString: String)!
        }
        self.imageSlideshow.setImageInputs(images)
        
        self.ratingBar.rating = playground.rating ?? 1
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
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width), height: referenceHeadSize)
    }
    
}

extension PlaygroundViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playgroundElements.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let viewCell = self.playgroundElementsCollectionView.dequeueReusableCell(withReuseIdentifier: "simplePlaygroundElementViewCell", for: indexPath) as! SimplePlaygroundElementViewCell
        
        viewCell.displayContent(playgroundElement: self.playgroundElements[indexPath.row])
        
        return viewCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        // 2
        case UICollectionView.elementKindSectionHeader:
            // 3
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "playgroundHeaderView",
                    for: indexPath) as? PlaygroundHeaderView
                else {
                    fatalError("Invalid view type")
            }
            
            headerView.playgroundHeadline.text = selectedPlayground?.name
            headerView.playgroundDescription.text = selectedPlayground?.description?.htmlToString
            headerView.playgroundDescription.sizeToFit()
            
            headerView.playgroundDescription.snp.makeConstraints { (make) in
                make.top.equalTo(headerView.playgroundHeadline.snp.bottom).offset(12)
                
                let height = headerView.playgroundDescription.bounds.size.height + 40
                make.height.equalTo(height)
                
                referenceHeadSize = height
                
                playgroundElementsCollectionView.layoutIfNeeded()
            }
            
            return headerView
        default:
            // 4
            fatalError("Unexpected element kind")
        }
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
