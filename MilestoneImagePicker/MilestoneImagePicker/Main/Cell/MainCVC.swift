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
    @IBOutlet weak var checkBox: M13Checkbox!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        checkBox.boxType = .circle
        
        NotificationCenter.default.addObserver(self, selector: #selector(uncheckedState), name: NSNotification.Name("checkBox"), object: nil)
    }
    
    // MARK: - Functions
    
    // Action when cancel button was clicked
    @objc func uncheckedState() {
        checkBox.checkState = .unchecked
    }
    
    // Action when checkbox is selected
    @IBAction func changeCheckBoxState(_ sender: Any) {
        if checkBox.checkState == .checked {
            NotificationCenter.default.post(name: NSNotification.Name("unhide"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: nil)
        }
    }
}
