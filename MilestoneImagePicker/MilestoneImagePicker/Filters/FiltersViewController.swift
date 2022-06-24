//
//  ViewController.swift
//  MilestoneCalculator
//
//  Created by Сережа Присяжнюк on 20.06.2022.
//

import UIKit
import Photos

class FiltersViewController: UIViewController {
    
    enum FilterType {
        case blur
        case reduction
        case toneCurve
        case motion
    }
    
    // MARK: - UI Elements
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var showOriginalButton: UIButton!
    
    @IBOutlet weak var constrastValueLabel: UILabel!
    @IBOutlet weak var contrastSlider: UISlider!
    
    @IBOutlet weak var reductionValueLabel: UILabel!
    @IBOutlet weak var reductionSlider: UISlider!
    
    @IBOutlet weak var toneCurveValueLabel: UILabel!
    @IBOutlet weak var toneCurveSlider: UISlider!
    
    @IBOutlet weak var motionValueLabel: UILabel!
    @IBOutlet weak var motionSlider: UISlider!
    
    // MARK: - Variables
    
    public var image: UIImage?
    
    private var beginImage:CIImage?
    private var context = CIContext(options:nil)
    private var filterType: FilterType = .blur
    
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
        
        sliderSelectors()
        
        imageView.image = image
        showPicture()
        imageFilter(filterType: filterType)
    }
    
    // MARK: - Functions
    
    private func sliderSelectors() {
        
        contrastSlider.addTarget(self, action: #selector(blurEffectSlider), for: .valueChanged)
        reductionSlider.addTarget(self, action: #selector(reductionEffectSlider), for: .valueChanged)
        motionSlider.addTarget(self, action: #selector(motionEffectSlider), for: .valueChanged)
        toneCurveSlider.addTarget(self, action: #selector(toneCurveEffectSlider), for: .valueChanged)
    }
    
    private func showPicture() {
        guard let image = imageView.image else { return }
        beginImage = CIImage(image: image)
    }
    
    // MARK: - Image filters
    
    private func imageFilter(filterType: FilterType){
        guard let beginImage = beginImage else { return }
        
        switch filterType {
            
        case .blur:
            
            let filter = CIFilter.addBoxBlur(inputImage: beginImage, inputRadius: NSNumber(value: contrastSlider.value))
            
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else { return }
                
                let output = filter!.outputImage
                let cgimg = self.context.createCGImage(output!, from: output!.extent)
                let processImage = UIImage(cgImage: cgimg!)
                
                DispatchQueue.main.async {
                    self.imageView.image = processImage
                }
            }
            
        case .reduction:
            
            let filter = CIFilter.addNoiseReduction(inputImage: beginImage, inputNoiseLevel: NSNumber(value: reductionSlider.value), inputSharpness: NSNumber(value:reductionSlider.value))
            
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else { return }
                let output = filter!.outputImage
                let cgimg = self.context.createCGImage(output!, from: output!.extent)
                let processImage = UIImage(cgImage: cgimg!)
                
                DispatchQueue.main.async {
                    self.imageView.image = processImage
                }
            }
            
        case .toneCurve:
            
            let imageCenter = CIVector(x: imageView.center.x, y: imageView.center.y)
            let filter = CIFilter.addZoomBlur(inputImage: beginImage, inputAmount: NSNumber(value:toneCurveSlider.value), inputCenter: imageCenter)
            DispatchQueue.global(qos: .userInteractive).async {
                let output = filter!.outputImage
                let cgimg = self.context.createCGImage(output!, from: output!.extent)
                let processImage = UIImage(cgImage: cgimg!)
                
                DispatchQueue.main.async {
                    self.imageView.image = processImage
                }
            }
            
            
            
        case .motion:
            
            let filter = CIFilter.addMotionBlur(inputImage: beginImage, inputRadius: NSNumber(value:self.motionSlider.value), inputAngle: NSNumber(value: self.motionSlider.value))
            
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else { return }
                
                let output = filter!.outputImage
                let cgimg = self.context.createCGImage(output!, from: output!.extent)
                let processImage = UIImage(cgImage: cgimg!)
                
                DispatchQueue.main.async {
                    self.imageView.image = processImage
                }
            }
        }
    }
    
    // MARK: - UISlider change value
    
    @objc func blurEffectSlider(_: UISlider){
        constrastValueLabel.text = "\(Int(contrastSlider.value))"
        imageFilter(filterType: .blur)
    }
    
    @objc func reductionEffectSlider(_: UISlider) {
        reductionValueLabel.text = "\(Int(reductionSlider.value))"
        imageFilter(filterType: .reduction)
    }
    
    @objc func motionEffectSlider(_: UISlider) {
        motionValueLabel.text = "\(Int(motionSlider.value))"
        imageFilter(filterType: .motion)
    }
    
    @objc func toneCurveEffectSlider(_: UISlider) {
        toneCurveValueLabel.text = "\(Int(toneCurveSlider.value))"
        imageFilter(filterType: .toneCurve)
    }
    
    @objc func savePhoto(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancel)
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Success", message: "Photo was successfully saved", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancel)
            present(alert, animated: true)
        }
        
    }
    
    // MARK: - IBAction
    @IBAction func removePreviousChangeAction(_ sender: Any) {
       
        if contrastSlider.value > 0 {
            contrastSlider.value = 0
            constrastValueLabel.text = "\(Int(contrastSlider.value))"
            imageView.image = image
        } else if reductionSlider.value > 0 {
            reductionSlider.value = 0
            toneCurveValueLabel.text = "\(Int(reductionSlider.value))"
            imageView.image = image
        } else if toneCurveSlider.value > 0 {
            toneCurveSlider.value = 0
            toneCurveValueLabel.text = "\(Int(toneCurveSlider.value))"
            imageView.image = image
        } else if motionSlider.value > 0 {
            motionSlider.value = 0
            motionValueLabel.text = "\(Int(motionSlider.value))"
            imageView.image = image
        }
    }
    
    @IBAction func showOriginalAction(_ sender: Any) {
        imageView.image = image
    }
    
    @IBAction func shareAction(_ sender: Any) {
        guard let image = imageView.image else { return }
        let shareVc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(shareVc, animated: true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(savePhoto(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
