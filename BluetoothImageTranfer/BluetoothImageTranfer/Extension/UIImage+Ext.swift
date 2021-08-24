//
//  UIImage+Ext.swift
//  UIImage+Ext
//
//  Created by limefriends on 2021/08/20.
//

import UIKit

extension UIImage {
    // MARK: - Resize
    func resizeToFitLCDScreen() -> UIImage {
        let size = CGSize(width: 250,
                          height: 122)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero,
                                 size: size))
        }
        print("---> originImage: \(self), resizeImage: \(renderImage)")
        return renderImage
    }
    
    // MARK: - Filter Change
    /// Create a grayscale image with alpha channel. Is 5 times faster than grayscaleImage().
        /// - Returns: The grayscale image of self if available.
        var grayScaled: UIImage? {
            // Create image rectangle with current image width/height * scale
            let pixelSize = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
            let imageRect = CGRect(origin: CGPoint.zero, size: pixelSize)
            // Grayscale color space
             let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()

                // Create bitmap content with current image size and grayscale colorspace
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
            if let context: CGContext = CGContext(data: nil, width: Int(pixelSize.width), height: Int(pixelSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) {
                    // Draw image into current context, with specified rectangle
                    // using previously defined context (with grayscale colorspace)
                    guard let cg = self.cgImage else{
                        return nil
                    }
                    context.draw(cg, in: imageRect)
                    // Create bitmap image info from pixel data in current context
                    if let imageRef: CGImage = context.makeImage() {
                        let bitmapInfoAlphaOnly = CGBitmapInfo(rawValue: CGImageAlphaInfo.alphaOnly.rawValue)

                        guard let context = CGContext(data: nil, width: Int(pixelSize.width), height: Int(pixelSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfoAlphaOnly.rawValue) else{
                            return nil
                        }
                        context.draw(cg, in: imageRect)
                        if let mask: CGImage = context.makeImage() {
                            // Create a new UIImage object
                            if let newCGImage = imageRef.masking(mask){
                                // Return the new grayscale image
                                return UIImage(cgImage: newCGImage, scale: self.scale, orientation: self.imageOrientation)
                            }
                        }

                    }
                }
            // A required variable was unexpected nil
            return nil
        }
}
