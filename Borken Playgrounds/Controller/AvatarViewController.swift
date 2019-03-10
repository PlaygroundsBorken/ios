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

class AvatarViewController: UIViewController {
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var avatarWrapper: UIStackView!
    
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
                make.top.equalTo(self.safeArea.top).offset(UIApplication.shared.statusBarFrame.size.height)
                make.centerX.equalTo(self.view)
                make.width.equalTo(200)
                make.height.equalTo(200)
            }
            
            appDelegate.avatars?.fromAvatarUrl(avatarUrl: avatarUrl)
        }
        
        avatarWrapper.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView.snp.bottom)
            make.bottom.left.right.equalTo(view)
        }
        
        
        var lastPickerText: UITextField?
        appDelegate.avatars?.avatarSetting.forEach({ (avatarSetting) in
            
            let pickerView = UIPickerView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 216)))
            
            pickerView.dataSource = self
            pickerView.delegate = self
            pickerView.isHidden = true
            
            pickerToAvatarSetting[pickerView] = avatarSetting
            avatarWrapper.addSubview(pickerView)
            
            pickerView.snp.makeConstraints({ (make) in
                make.left.right.bottom.equalTo(avatarWrapper)
            })
            
            let pickerTextField = UITextField(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 216)))
            
            if let selectedOption = avatarSetting.options.first(where: { (part) -> Bool in
                return part.selected != nil && part.selected!
            }) {
                pickerTextField.text = selectedOption.value
            } else {
                pickerTextField.text = avatarSetting.body_part
            }
            pickerTextField.delegate = self
            
            avatarWrapper.addSubview(pickerTextField)
            
            pickerToPickerText[pickerView] = pickerTextField
            pickerTextToPicker[pickerTextField] = pickerView
            pickerTextField.snp.makeConstraints({ (make) in
                make.left.right.equalTo(avatarWrapper)
            })
            if (lastPickerText != nil) {
                
                pickerTextField.snp.makeConstraints({ (make) in
                    make.top.equalTo(lastPickerText!.snp.bottom)
                })
            }
            lastPickerText = pickerTextField
        })
    }
}

extension AvatarViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerToAvatarSetting[pickerView]?.options.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerToAvatarSetting[pickerView]?.options[row].value
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let avatarSetting = pickerToAvatarSetting[pickerView]
        pickerToPickerText[pickerView]?.text = avatarSetting?.options[row].value;
        
        pickerToPickerText.keys.forEach { (pickerView) in
            pickerView.isHidden = true
        }
        pickerToPickerText.values.forEach { (textField) in
            textField.isHidden = false
        }
        
        pickerToAvatarSetting[pickerView]?.options[row].selected = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.avatars?.selectBodyPartOption(bodyPart: avatarSetting?.body_part, option: avatarSetting?.options[row].id)
        
        if let avatarUrl = appDelegate.avatars?.createAvatarUrl() {
         
            let url = URL(string: avatarUrl)
            self.avatarImageView.kf.setImage(with: url)
            
            appDelegate.user?.avatarUrl = avatarUrl
            appDelegate.user?.save()
        }
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        pickerTextToPicker[textField]?.isHidden = false
        return false
    }
}
