//
//  UIImage+Ext.swift
//  UIImage+Ext
//
//  Created by limefriends on 2021/08/20.
//

import UIKit

extension UIImage {
    var resizeImage: UIImage? {
        let newWidth = 250
        let newHeight = 128
        /// BeginImageContext
        UIGraphicsBeginImageContext(CGSize(width: newWidth,
                                           height: newHeight))
        self.draw(in: CGRect(x: 0,
                             y: 0,
                             width: newWidth,
                             height: newHeight))
        let newSizeImage = UIGraphicsGetImageFromCurrentImageContext()
        /// EndImageContext
        UIGraphicsEndImageContext()
        return newSizeImage
    }
    
    var blackAndWhite: CGImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        guard let grayImage = CIFilter(name: "CIPhotoEffectNoir",
                                       parameters: [kCIInputImageKey: ciImage])?.outputImage else { return nil }
        let blackAndWhiteParams: [String: Any] = [
            kCIInputImageKey: grayImage,
            kCIInputContrastKey: 20.0,
            kCIInputBrightnessKey: 0.0
        ]
        guard let blackAndWhiteImage = CIFilter(name: "CIColorControls",
                                                parameters: blackAndWhiteParams)?.outputImage else { return nil }
        guard let cgImage = CIContext(options: nil).createCGImage(blackAndWhiteImage,
                                                                  from: blackAndWhiteImage.extent) else { return nil }
        return cgImage
    }
}
