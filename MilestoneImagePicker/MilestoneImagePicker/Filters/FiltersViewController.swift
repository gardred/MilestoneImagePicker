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
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var showOriginalButton: UIButton!
    @IBOutlet private weak var redoChangesButton: UIButton!
    
    @IBOutlet private weak var sildersView: UIView!
    @IBOutlet private weak var navigationView: UIView!
    @IBOutlet private weak var constrastValueLabel: UILabel!
    @IBOutlet private weak var contrastSlider: UISlider!
    
    @IBOutlet private weak var reductionValueLabel: UILabel!
    @IBOutlet private weak var reductionSlider: UISlider!
    
    @IBOutlet private weak var toneCurveValueLabel: UILabel!
    @IBOutlet private weak var toneCurveSlider: UISlider!
    
    @IBOutlet private weak var motionValueLabel: UILabel!
    @IBOutlet private weak var motionSlider: UISlider!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollBackgroundView: UIView!
    // MARK: - Variables
    
    public var image: UIImage?
    
    private var beginImage:CIImage?
    private var context = CIContext(options:nil)
    private var filterType: FilterType = .blur
    
    private var contrastValue = 0
    private var reductionValue = 0
    private var toneCurveValue = 0
    private var motionValue = 0
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
        sliderSelectors()
      
        imageView.image = image
        showPicture()
        imageFilter(filterType: filterType)
    }
    
    // MARK: - Functions
    
    private func configureUI() {
        navigationView.backgroundColor = .black
        sildersView.backgroundColor = .black
        scrollView.backgroundColor = .black
        view.backgroundColor = .black
    }
    
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
    
    private func applyFilters(_ filter: CIFilter?) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            if let filter = filter {
                let output = filter.outputImage
                if let output = output {
                    let cgImage = self.context.createCGImage(output, from: output.extent)
                    if let cgImage = cgImage {
                        let processImage = UIImage(cgImage: cgImage)
                        DispatchQueue.main.async {
                            self.imageView.image = processImage
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Image filters
    
    private func imageFilter(filterType: FilterType) {
        guard let beginImage = beginImage else { return }
        
        switch filterType {
            
        case .blur:
            
            let filter = CIFilter.addBoxBlur(inputImage: beginImage, inputRadius: NSNumber(value: contrastSlider.value))
            applyFilters(filter)
            
        case .reduction:
            
            let filter = CIFilter.addNoiseReduction(inputImage: beginImage, inputNoiseLevel: NSNumber(value: reductionSlider.value), inputSharpness: NSNumber(value:reductionSlider.value))
            applyFilters(filter)
            
        case .toneCurve:
            
            let imageCenter = CIVector(x: imageView.center.x, y: imageView.center.y)
            let filter = CIFilter.addZoomBlur(inputImage: beginImage, inputAmount: NSNumber(value:toneCurveSlider.value), inputCenter: imageCenter)
            applyFilters(filter)
            
        case .motion:
            
            let filter = CIFilter.addMotionBlur(inputImage: beginImage, inputRadius: NSNumber(value:self.motionSlider.value), inputAngle: NSNumber(value: self.motionSlider.value))
            applyFilters(filter)
            
        }
    }
    
    // MARK: - UISlider change value
    
    @objc private func blurEffectSlider(_: UISlider){
        constrastValueLabel.text = "\(Int(contrastSlider.value))"
        contrastValue = Int(contrastSlider.value)
        print(contrastValue)
        imageFilter(filterType: .blur)
    }
    
    @objc private func reductionEffectSlider(_: UISlider) {
        reductionValueLabel.text = "\(Int(reductionSlider.value))"
        reductionValue = 0
        reductionValue = Int(reductionSlider.value)
        imageFilter(filterType: .reduction)
    }
    
    @objc private func motionEffectSlider(_: UISlider) {
        motionValueLabel.text = "\(Int(motionSlider.value))"
        motionValue = 0
        motionValue = Int(motionSlider.value)
        imageFilter(filterType: .motion)
    }
    
    @objc private func toneCurveEffectSlider(_: UISlider) {
        toneCurveValueLabel.text = "\(Int(toneCurveSlider.value))"
        toneCurveValue = 0
        toneCurveValue = Int(toneCurveSlider.value)
        imageFilter(filterType: .toneCurve)
    }
    
    @objc private func savePhoto(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
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
    
    @IBAction private func redoPreviousChangeAction(_ sender: Any) {
        if contrastValue > 0 {
            contrastSlider.value = Float(contrastValue)
            constrastValueLabel.text = "\(contrastValue)"
        } else if toneCurveValue > 0 {
            toneCurveSlider.value = Float(toneCurveValue)
            toneCurveValueLabel.text = "\(toneCurveValue)"
        } else if motionValue > 0 {
            motionSlider.value = Float(motionValue)
            motionValueLabel.text = "\(motionValue)"
        } else if reductionValue > 0 {
            reductionSlider.value = Float(reductionValue)
            reductionValueLabel.text = "\(reductionValue)"
        }
    }
    
    @IBAction private func removePreviousChangeAction(_ sender: Any) {
        
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
    
    @IBAction private func showOriginalAction(_ sender: Any) {
        imageView.image = image
    }
    
    @IBAction private func shareAction(_ sender: Any) {
        guard let image = imageView.image else { return }
        let shareVc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(shareVc, animated: true)
    }
    
    @IBAction private func saveAction(_ sender: Any) {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(savePhoto(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction private func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
