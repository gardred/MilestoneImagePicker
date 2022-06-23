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
        
        
        contrastSlider.addTarget(self, action: #selector(blurEffectSlider), for: .valueChanged)
        reductionSlider.addTarget(self, action: #selector(reductionEffectSlider), for: .valueChanged)
        motionSlider.addTarget(self, action: #selector(motionEffectSlider), for: .valueChanged)
        
        imageView.image = image
        beginImage = CIImage(image: imageView.image!)
        imageFilter(filterType: filterType)
    }
    
    // MARK: - Functions
    
    private func sliderSelectors() {
        
    }
    
    
    // MARK: - Image filters
    
    private func imageFilter(filterType: FilterType){
        
        switch filterType {
            
        case .blur:
            let filter = CIFilter.addBoxBlur(inputImage: beginImage!, inputRadius: NSNumber(value: contrastSlider.value))
            let output = filter!.outputImage
            let cgimg = context.createCGImage(output!, from: output!.extent)
            let processImage = UIImage(cgImage: cgimg!)
            imageView.image = processImage
            
        case .reduction:
            let filter = CIFilter.addNoiseReduction(inputImage: beginImage!, inputNoiseLevel: NSNumber(value: reductionSlider.value), inputSharpness: NSNumber(value:reductionSlider.value))
            let output = filter!.outputImage
            let cgimg = context.createCGImage(output!, from: output!.extent)
            let processImage = UIImage(cgImage: cgimg!)
            imageView.image = processImage
            
        case .toneCurve:
            let filter = CIFilter.addLinearToSRGBToneCurve(inputImage: beginImage!)
            let output = filter!.outputImage
            let cgimg = context.createCGImage(output!, from: output!.extent)
            let processImage = UIImage(cgImage: cgimg!)
            imageView.image = processImage
            
        case .motion:
            
            let filter = CIFilter.addMotionBlur(inputImage: self.beginImage!, inputRadius: NSNumber(value:self.motionSlider.value), inputAngle: NSNumber(value: self.motionSlider.value))
            let output = filter!.outputImage
            let cgimg = self.context.createCGImage(output!, from: output!.extent)
            let processImage = UIImage(cgImage: cgimg!)
            self.imageView.image = processImage
        }
    }
    
    // MARK: - UISlider change value
    
    @objc func blurEffectSlider(_: UISlider){
        
        constrastValueLabel.text = "\(contrastSlider.value)"
        imageFilter(filterType: .blur)
        
    }
    
    @objc func reductionEffectSlider(_: UISlider) {
        imageFilter(filterType: .reduction)
    }
    
    @objc func motionEffectSlider(_: UISlider) {
        imageFilter(filterType: .motion)
    }
    
    // MARK: - IBAction
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
