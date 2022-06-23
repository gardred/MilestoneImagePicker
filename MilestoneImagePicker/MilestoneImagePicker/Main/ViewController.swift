//
//  ViewController.swift
//  MilestoneImagePicker
//
//  Created by Сережа Присяжнюк on 22.06.2022.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    // MARK: - UI Elements
    
    @IBOutlet weak var shareWithButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    // MARK: - Variables
    private var images = [PHAsset]()
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureCollectionView()
        uploadImages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkBoxIsSelected), name: NSNotification.Name("unhide"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkBoxIsDeselected), name: NSNotification.Name("hide"), object: nil)
    }
    
    // MARK: - Functions
    private func configureUI() {
        
        cameraButton.layer.cornerRadius = cameraButton.frame.height / 2
        cameraButton.layer.masksToBounds = true
        
        editButton.isHidden = true
        cancelButton.isHidden = true
        shareWithButton.isHidden = true
        
        shareWithButton.tintColor = UIColor.white
    }
    
    private func configureCollectionView() {
        
        photosCollectionView.register(UINib(nibName: "MainCVC", bundle: nil), forCellWithReuseIdentifier: MainCVC.identifier)
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
    }
    
    private func uploadImages() {
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            if status == .authorized {
                let images = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                images.enumerateObjects { object, _, _ in
                    self?.images.append(object)
                    DispatchQueue.main.async {
                        self?.photosCollectionView.reloadData()
                    }
                }
            }
        }
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
    
    @objc public func checkBoxIsSelected() {
        
        editButton.isHidden = false
        cancelButton.isHidden = false
        shareWithButton.isHidden = false
        cameraButton.isHidden = true
    }
    
    @objc public func checkBoxIsDeselected() {
        
        editButton.isHidden = true
        cancelButton.isHidden = true
        shareWithButton.isHidden = true
        cameraButton.isHidden = false
    }
    
    // MARK: - IBAction
    
    @IBAction func shareButtonAction(_ sender: Any) {
        
        let shareVc = UIActivityViewController(activityItems: [], applicationActivities: nil)
        present(shareVc, animated: true)
    }
    
    @IBAction func cameraButtonAction(_ sender: Any) {
        openCamera()
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name("checkBox"), object: nil)
        editButton.isHidden = true
        cancelButton.isHidden = true
        shareWithButton.isHidden = true
        cameraButton.isHidden = false
    }
    
    
    @IBAction func editButtonAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController (withIdentifier: "FiltersViewController") as! FiltersViewController
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - Extension UICollectionView Configuration

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCVC.identifier, for: indexPath) as! MainCVC
        
        let asset = self.images[indexPath.row]
        let manager = PHImageManager.default()
        
        manager.requestImage(for: asset, targetSize: CGSize(width: cell.frame.width, height: cell.frame.height - 20), contentMode: .aspectFill, options: nil) { image, _ in
            
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionView Delegate

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController (withIdentifier: "FiltersViewController") as! FiltersViewController
        
        let asset = self.images[indexPath.row]
        let manager = PHImageManager.default()
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 82, height: 82), contentMode: .aspectFill, options: nil) { image, _ in
            controller.image = image
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

    // MARK: UICollectionView FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 82.0, height: 82.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
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
