//
//  ViewController.swift
//  MilestoneImagePicker
//
//  Created by Сережа Присяжнюк on 22.06.2022.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var shareWithButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(hide), name: NSNotification.Name("unhide"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideButton), name: NSNotification.Name("hide"), object: nil)
    }

    // MARK: - Functions
    private func configureUI() {
        cameraButton.layer.cornerRadius = cameraButton.frame.height / 2
        cameraButton.layer.masksToBounds = true
        
        shareWithButton.tintColor = UIColor.white
    }
    
    private func configureCollectionView() {
        
        photosCollectionView.register(UINib(nibName: "MainCVC", bundle: nil), forCellWithReuseIdentifier: MainCVC.identifier)
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
    }
    
    private func openCamera() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alert = UIAlertController(title: "Error", message: "No camera", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        } else {
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true)
        }
    }
    
    private func openPhotoLibrary() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true)
        
    }
    
    @objc public func hide() {
        editButton.isHidden = false
        cancelButton.isHidden = false
        print("false")
    }
    
    @objc public func hideButton() {
        editButton.isHidden = true
        cancelButton.isHidden = true
        print("true")
    }
    
    // MARK: - IBAction
    
    @IBAction func shareButtonAction(_ sender: Any) {
        
        let image = UIImage(named: "")
        
        let shareVc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareVc, animated: true)
    }
    
    @IBAction func cameraButtonAction(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: "Choose action", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.openCamera()
        }
       
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.openPhotoLibrary()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(camera)
        alert.addAction(photoLibrary)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
}

// MARK: - Extension UICollectionView Configuration

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCVC.identifier, for: indexPath) as! MainCVC
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 82.0, height: 82.0)
    }
}

// MARK: - UIImagePickerController & UINavigationControllerDelegate Delegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        self.dismiss(animated: true)
    }
}
