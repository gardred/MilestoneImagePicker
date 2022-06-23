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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkBox: M13Checkbox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        configureCheckBox()
        
    }
    
    private func configureCheckBox() {
        checkBox.boxType = .circle
        
    }
    
    @IBAction func changeCheckBoxState(_ sender: Any) {
        if checkBox.checkState == .checked {
            NotificationCenter.default.post(name: NSNotification.Name("unhidden"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hidden"), object: nil)
        }
    }
    
}
