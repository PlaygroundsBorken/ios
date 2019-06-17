//
//  AvatarViewController.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 10.03.19.
//  Copyright © 2019 Jugendwerk Borken. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import SparrowKit
import Eureka

class AvatarViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBAction func backButtonClicked(_ sender: UIBarButtonItem) {
        let navigationController = self.presentingViewController as? UINavigationController
        
        self.dismiss(animated: true) {
            let _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let avatarUrl = appDelegate.avatars?.createAvatarUrl() {
            
            appDelegate.user?.avatarUrl = avatarUrl
            appDelegate.user?.save()
        }
        
        let navigationController = self.presentingViewController as? UINavigationController
        
        self.dismiss(animated: true) {
            let _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    let optionsHeadlines = [
        "topType": "Kopfbedeckung",
        "accessoriesType": "Accessoire",
        "hairColor": "Haarfarbe",
        "facialHairType": "Gesichtsbeharung",
        "clotheType": "Bekleidung",
        "eyeType": "Augen",
        "eyebrowType": "Augenbrauen",
        "mouthType": "Mund",
        "skinColor": "Hautfarbe",
    ]
    let avatarImageSteps = [1:1,2:2,3:3,5:4,8:5,11:6,15:7,21:8,25:9]
    var showAmountOfWrapper = 1
    var pickerToAvatarSetting: [UIPickerView: AvatarSetting] = [UIPickerView: AvatarSetting]()
    var pickerToPickerText: [UIPickerView: UITextField] = [UIPickerView: UITextField]()
    var pickerTextToPicker: [UITextField: UIPickerView] = [UITextField: UIPickerView]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let avatarUrl = appDelegate.user?.avatarUrl {
            let url = URL(string: avatarUrl)
            self.avatarImageView.kf.setImage(with: url)
            
            self.avatarImageView.snp.makeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
                } else {
                    make.top.equalTo(view)
                }
                make.centerX.equalTo(self.view)
                make.width.equalTo(200)
                make.height.equalTo(200)
            }
            
            appDelegate.avatars?.fromAvatarUrl(avatarUrl: avatarUrl)
        }
        
        if var visitedPlaygroundCount = appDelegate.user?.visitedPlaygrounds.count {
            
            if (visitedPlaygroundCount == 0) {
                visitedPlaygroundCount = 1
            }
            
            if let availableAvatarSpinner = avatarImageSteps[visitedPlaygroundCount] {
                
                showAmountOfWrapper = availableAvatarSpinner
            } else {
                
                showAmountOfWrapper = appDelegate.avatars?.avatarSetting.count ?? 1
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        switch segue.destination {
            
        case let formViewController as FormViewController:
            let rows = appDelegate.avatars?.avatarSetting.prefix(showAmountOfWrapper).map({ (avatarSetting) -> PushRow<String> in
                var selected: String = ""
                if let selectedOption = avatarSetting.options.first(where: { (part) -> Bool in
                    return part.selected != nil && part.selected!
                }) {
                    selected = selectedOption.value
                } else {
                    selected = ""
                }
                
                
                return PushRow<String>() {
                    $0.title = String(describing: optionsHeadlines[avatarSetting.body_part]!)
                    $0.selectorTitle = "Wähle \(String(describing: optionsHeadlines[avatarSetting.body_part]!)) aus"
                    $0.options = avatarSetting.options.map({ (part) -> String in
                        part.value
                    })
                    $0.value = selected
                    
                    }.onChange({ (row) in
                    
                        let key = self.optionsHeadlines.swapKeyValues()[row.title!]
                        appDelegate.avatars?.selectBodyPartOption(bodyPart: key, option: row.value)
                        
                        if let avatarUrl = appDelegate.avatars?.createAvatarUrl() {
                            
                            let url = URL(string: avatarUrl)
                            self.avatarImageView.kf.setImage(with: url)
                        }
                    })
            })
            
            if ((rows) != nil) {
                let section = Section()
                rows?.forEach({ (row) in
                    section <<< row
                })
                formViewController.form +++ section
            }
            formViewController.viewDidLoad()
            
        default:
            break
        }
    }
}

extension Dictionary where Value : Hashable {
    
    func swapKeyValues() -> [Value : Key] {
        assert(Set(self.values).count == self.keys.count, "Values must be unique")
        var newDict = [Value : Key]()
        for (key, value) in self {
            newDict[value] = key
        }
        return newDict
    }
}
