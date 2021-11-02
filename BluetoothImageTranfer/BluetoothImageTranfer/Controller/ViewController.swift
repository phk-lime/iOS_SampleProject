//
//  ViewController.swift
//  BluetoothImageTranfer
//
//  Created by limefriends on 2021/08/20.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var connectStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func setupSample(_ sender: UIButton) {
        imageView.image = UIImage(named: "sample3")?.resizeImage
    }
    
    @IBAction func setupSample2(_ sender: UIButton) {
        imageView.image = UIImage(named: "sample2")?.resizeImage
    }
    
    @IBAction func imageColorChange(_ sender: Any) {
        /// https://www.hackingwithswift.com/example-code/media/how-to-desaturate-an-image-to-make-it-black-and-white
        /// How to desaturate an image to make it black and white
        guard let currentCGImage = imageView.image?.cgImage else { return }
        let currentCIImage = CIImage(cgImage: currentCGImage)
        
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(currentCIImage, forKey: "inputImage")
        
        /// 색조 색상에 대한 회색 값 설정
        filter?.setValue(CIColor(red: 0.8, green: 0.8, blue: 0.8), forKey: "inputColor")
        
        filter?.setValue(1.0, forKey: "inputIntensity")
        guard let outputImage = filter?.outputImage else { return }
        
        let context = CIContext()
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            print(processedImage.size)
            self.imageView.image = UIImage(cgImage: cgImage)
            let test = getBinary(from: cgImage)
            print("imageColorChange:::", test)
        }
    }
    
    @IBAction func transferBlackAndWhite(_ sender: UIButton) {
//        if let blackAndWhite = self.imageView.image?.blackAndWhite {
//            self.imageView.image = UIImage(cgImage: blackAndWhite)
//            let test = getBinary(from: blackAndWhite)
//            print("transferBlackAndWhite:::", test)
//        }
        
//        guard let ciImage = CIImage(image: imageView.image!) else { return }
//        guard let grayImage = CIFilter(name: "CIPhotoEffectNoir",
//                                       parameters: [kCIInputImageKey: ciImage])?.outputImage else { return }
//        guard let cgImage = CIContext(options: nil).createCGImage(grayImage,
//                                                                  from: grayImage.extent) else { return }
//        imageView.image = UIImage(cgImage: cgImage)
        
        /// 1. UIImage -> CIImage로 변환
        let currentCIImage = CIImage(image: imageView.image!)!
        /// 2. grayScale 필터 적용
        guard let grayScaleFilter = CIFilter(name: "CIPhotoEffectNoir") else { return }
        grayScaleFilter.setValue(currentCIImage, forKey: "inputImage")
        guard let grayScaleCIImage = grayScaleFilter.outputImage else { return }
        /// 3. Contrast & Brightness 를 이용한 흑백 이미지 만들기
        let blackAndWhiteParams: [String: Any] = [
            kCIInputImageKey: grayScaleCIImage,
            kCIInputContrastKey: 50.0,
            kCIInputBrightnessKey: 0.0
        ]
        guard let blackAndWhiteFilter = CIFilter(name: "CIColorControls",
                                                 parameters: blackAndWhiteParams) else { return }
        guard let blackAndWhiteCIImage = blackAndWhiteFilter.outputImage else { return }
        /// 4. 흑백 CIImage를 CGImage로 변환
        let context = CIContext()
        guard let cgImage = context.createCGImage(blackAndWhiteCIImage,
                                                  from: blackAndWhiteCIImage.extent) else { return }
        /// 5. UIImage로 return
        imageView.image = UIImage(cgImage: cgImage)
    }
    
    private func getBinary(from cgImage: CGImage) -> String {
        var binaryArray = [String]()
        guard let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return "" }
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        for x in 0..<cgImage.width {
            for y in 0..<cgImage.height {
                let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                if bytes[offset] == 0 {
                    binaryArray.append("0")
                    print("getBinary:::", bytes[offset], bytes[offset+1], bytes[offset+2])
                }
                else {
                    binaryArray.append("1")
                    print("getBinary:::", bytes[offset], bytes[offset+1], bytes[offset+2])
                }
            }
        }
        print("--->[getBinary] \(binaryArray.count)")
        let binary = binaryArray.joined()
        return binary
    }
}
