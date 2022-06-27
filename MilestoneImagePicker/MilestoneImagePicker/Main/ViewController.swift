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
    private var pictureIndex: PHAsset?
    private let manager = PHImageManager.default()
    private var shareVc: UIActivityViewController?
    private var asset: PHAsset?
    // MARK: - Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
        notifications()
    }
    
    // MARK: - Functions
    
    private func notifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkBoxIsSelected), name: NSNotification.Name("unhide"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkBoxIsDeselected), name: NSNotification.Name("hide"), object: nil)
    }
    
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
            guard let self = self else { return }
            if status == .authorized {
                let images = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                images.enumerateObjects { object, _, _ in
                    self.images.append(object)
                    DispatchQueue.main.async {
                        self.photosCollectionView.reloadData()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Access was not granted", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                    alert.addAction(cancel)
                    self.present(alert, animated: true)
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
    
    private func lastPhotoDate(_ label: UILabel) {
        let assets = PHAsset.fetchAssets(with: .image, options: nil)
        
        for i in 0..<assets.count {
            asset = assets[i] as? PHAsset
            let creationDate = asset?.creationDate
            
            if let creationDate = creationDate {
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "dd MMM,yyyy"
                label.text = "\(dateFormatterPrint.string(from: creationDate))"
            }
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
        
        guard let asset = pictureIndex else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.manager.requestImage(for: asset, targetSize: CGSize(width: 82, height: 82), contentMode: .aspectFill, options: nil) { image, _ in
                self.shareVc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            }
            
            DispatchQueue.main.async {
                self.present(self.shareVc!, animated: true)
            }
        }
        
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
        
        guard let asset = pictureIndex else { return }
        
        manager.requestImage(for: asset, targetSize: CGSize(width: view.frame.width, height: view.frame.height), contentMode: .aspectFill, options: nil) { image, _ in
            controller.image = image
        }
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
        
        let asset = images[indexPath.row]
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFill, options: nil) { image, _ in
            cell.imageView.image = image
        }
        
        cell.checkBoxStateChecked = {
            self.pictureIndex = asset
        }
        
        return cell
    }
}

// MARK: - UICollectionView Delegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCRV", for: indexPath) as! HeaderCRV
        view.numberOfPhotos.text = "\(self.images.count)"
        lastPhotoDate(view.dateLabel)
        
        return view
    }
}

// MARK: UICollectionView FlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 82, height: 82)
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
     
              dismiss(animated: true, completion:nil)
    }
}
