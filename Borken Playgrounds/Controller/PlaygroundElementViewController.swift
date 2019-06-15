//
//  PlaygroundElementViewController.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 01.12.18.
//  Copyright © 2018 Jugendwerk Borken. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PlaygroundElementViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource{
    @IBOutlet var collectionView: UICollectionView!
    
    @IBAction func backButtonClicked(_ sender: Any) {
        let navigationController = self.presentingViewController as? UINavigationController
        
        self.dismiss(animated: true) {
            let _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 2,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 30,
        sectionInset: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    )
    
    @IBOutlet var playgroundElementCollectionView: UICollectionView!
    var playgroundElements: [PlaygroundElement] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playgroundElements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let viewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "playgroundElementViewCell", for: indexPath) as! PlaygroundElementViewCell
        
        viewCell.displayContent(playgroundElement: self.playgroundElements[indexPath.row])
        if playgroundElementIsSelected(playgroundElement: self.playgroundElements[indexPath.row]) {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            
            viewCell.isSelected = true
            viewCell.layoutIfNeeded()
        }
        
        return viewCell
    }
    
    private func playgroundElementIsSelected(playgroundElement: PlaygroundElement) -> Bool {
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.selectedPlaygroundElements.contains { (element) -> Bool in
            element.id == playgroundElement.id
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedPlayground = self.playgroundElements[indexPath.row]
        
        addPlaygroundElementToSelection(playgroundElement: selectedPlayground)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let deselectedPlayground = self.playgroundElements[indexPath.row]
        removePlaygroundElementFromSelection(playgroundElement: deselectedPlayground)
    }
    
    private func removePlaygroundElementFromSelection(playgroundElement: PlaygroundElement) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.selectedPlaygroundElements.removeAll { (element) -> Bool in
            return element.id == playgroundElement.id
        }
    }
    
    private func addPlaygroundElementToSelection(playgroundElement: PlaygroundElement) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.selectedPlaygroundElements.append(playgroundElement)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playgroundElementCollectionView.contentInsetAdjustmentBehavior = .always
        
        let db = Firestore.firestore()
        
        db.collection("playgroundelements").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let element = PlaygroundElement(documentId: document.documentID, dictionary: document.data())
                    
                    if element != nil {
                        self.playgroundElements.append(element!)
                    }
                }
                
                self.playgroundElementCollectionView.reloadData()
            }
        }
        self.playgroundElementCollectionView.collectionViewLayout = self.columnLayout
        self.playgroundElementCollectionView.contentInsetAdjustmentBehavior = .always
        self.playgroundElementCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.playgroundElementCollectionView.allowsMultipleSelection = true 
    }
}
