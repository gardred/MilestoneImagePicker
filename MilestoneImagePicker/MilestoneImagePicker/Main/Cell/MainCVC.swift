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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        resetViews()
    }
    
    let link = ViewController()
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(uncheckedState), name: NSNotification.Name("checkBox"), object: nil)
    }
    
    // MARK: - Functions
    
    // Action when cancel button was clicked
    @objc func uncheckedState() {
        selectButton.isSelected = false
        selectButton.tintColor = .systemGray
        layer.borderWidth = 0
    }
    
    func setup(isSelected: Bool) {
        selectButton.isSelected = isSelected
        selectButton.tintColor = isSelected ? .link : .systemGray
    }
    
    @IBAction private func selectButtonAction(_ sender: UIButton) {
        checkBoxStateChecked?()
    }
    
    private func resetViews() {
        imageView.image = nil
        selectButton.isSelected = false
        selectButton.tintColor = .systemGray
        layer.borderWidth = 0
        layer.borderColor = .none
    }
}
