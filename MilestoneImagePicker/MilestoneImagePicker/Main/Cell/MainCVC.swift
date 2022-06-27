//
//  MainCVC.swift
//  MilestoneImagePicker
//
//  Created by Сережа Присяжнюк on 23.06.2022.
//

import UIKit
import M13Checkbox

class MainCVC: UICollectionViewCell {
    
    static let identifier = "MainCVC"
    
    // MARK: UI Elements
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var selectButton: UIButton!
    var checkBoxStateChecked: (() -> Void)?
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        
        NotificationCenter.default.addObserver(self, selector: #selector(uncheckedState), name: NSNotification.Name("checkBox"), object: nil)
    }
    
    // MARK: - Functions
    
    // Action when cancel button was clicked
    @objc func uncheckedState() {
        selectButton.isSelected = false
        selectButton.tintColor = .systemGray
        layer.borderWidth = 0
    }
    
    @IBAction func selectButtonAction(_ sender: Any) {
        
        if selectButton.isSelected == false{
            
            selectButton.isSelected = true
            selectButton.tintColor = .link
            
            layer.borderWidth = 1
//            layer.borderColor = .init(red: 44, green: 138, blue: 241, alpha: 1)
            
            NotificationCenter.default.post(name: NSNotification.Name("unhide"), object: nil)
            checkBoxStateChecked?()
            
        } else {
            selectButton.isSelected = false
            selectButton.tintColor = .systemGray
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: nil)
            layer.borderWidth = 0
        }
    }
    
}
