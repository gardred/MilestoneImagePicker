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
    }
    
    // MARK: - UI Elements
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var constrastValueLabel: UILabel!
    
    @IBOutlet weak var reductionValueLabel: UILabel!
    @IBOutlet weak var reductionSlider: UISlider!
    
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
        
        sliderSelectors()
        imageFilter(filterType: filterType)
        
        imageView.image = image
        beginImage = CIImage(image: imageView.image!)
    }
    
    // MARK: - Functions
    
    private func sliderSelectors() {
        
        contrastSlider.addTarget(self, action: #selector(blurEffectSlider), for: .valueChanged)
        reductionSlider.addTarget(self, action: #selector(reductionEffectSlider), for: .valueChanged)
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
    
    // MARK: - IBAction
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
