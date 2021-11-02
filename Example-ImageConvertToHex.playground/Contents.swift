import UIKit

extension UIImage {
    var imageResizing: UIImage? {
        let resizeWidth = 250
        let resizeHeight = 128
        /// Begin Image Context
        UIGraphicsBeginImageContext(CGSize(width: resizeWidth,
                                           height: resizeHeight))
        self.draw(in: CGRect(x: 0,
                             y: 0,
                             width: resizeWidth,
                             height: resizeHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        /// End Image Context
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    var convertToBlackAndWhite: UIImage? {
        /// 1. UIImage -> CIImage로 변환
        guard let currentCIImage = CIImage(image: self) else { return nil }
        /// 2. grayScale 필터 적용
        guard let grayScaleFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        grayScaleFilter.setValue(currentCIImage, forKey: "inputImage")
        guard let grayScaleCIImage = grayScaleFilter.outputImage else { return nil }
        /// 3. Contrast & Brightness 를 이용한 흑백 이미지 만들기
        let blackAndWhiteParams: [String: Any] = [
            kCIInputImageKey: grayScaleCIImage,
            kCIInputContrastKey: 50.0,
            kCIInputBrightnessKey: 0.0
        ]
        guard let blackAndWhiteFilter = CIFilter(name: "CIColorControls",
                                                 parameters: blackAndWhiteParams) else { return nil }
        guard let blackAndWhiteCIImage = blackAndWhiteFilter.outputImage else { return nil }
        /// 4. 흑백 CIImage를 CGImage로 변환
        let context = CIContext()
        guard let cgImage = context.createCGImage(blackAndWhiteCIImage,
                                                  from: blackAndWhiteCIImage.extent) else { return nil }
        /// 5. UIImage로 return
        return UIImage(cgImage: cgImage)
    }
}

extension String {
    var hexaData: Data { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            let binary = self[startIndex..<endIndex]
            return UInt8(binary, radix: 16)
        }
    }

    func substring(from: Int, to: Int) -> String {
        guard from < self.count,
              to <= self.count,
              to >= 0,
              (to - from) >= 0 else {
                  return "out of range"
              }
        
        let startIndex = index(self.startIndex, offsetBy: from)
        let endIndex = index(self.startIndex, offsetBy: to + 1)
        return String(self[startIndex ..< endIndex])
        
    }
    
    func paddingToLeft(toLength: Int, withPad: String, startingAt: Int) -> String {
        guard count < toLength else { return self }
        return String(
            self.padding(toLength: toLength,
                         withPad: withPad,
                         startingAt: startingAt).reversed()
        )
    }
}


func extractBinary(from image: UIImage?) -> String {
    /// binary를 array형식으로 추출한다. (픽셀 단위로 binary를 뽑아내서 저장하기 위해)
    var binaryArray = [String]()
    guard let cgImage = image?.cgImage else { return "" }
    guard let data = cgImage.dataProvider?.data else { return "" }
    guard let bytes = CFDataGetBytePtr(data) else { return "" }
    let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
    /// 세로(위에서 아래)로 탐색하며 바이너리를 구한다.
    /// 가로로 탐색하려면 2개의 for문을 반대로 사용하면 된다.
    for x in 0..<cgImage.width {
        for y in 0..<cgImage.height {
            let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
            if bytes[offset] == 0 {
                binaryArray.append("0") /// 검정색은 0으로 간주
            }
            else {
                binaryArray.append("1") /// 이외의 색은 1로 간주
            }
        }
    }
    /// binary를 array형식으로 추출한뒤 string으로 내보낸다.
    return binaryArray.joined()
}

func convertToHexString(with binary: String) -> String {
    var binary = binary
    var hexArray = [String]()
    /// binary 8개씩 가져오기
    /// 이미지 사이즈가 250*128 이기 때문에 전체 binary 개수는 32,000개
    /// 전체 binary를 8개씩 잘라 hex로 변환한다. 때문에 for문을 위한 범위는 0..<4000
    for _ in 0..<4000 {
        /// hex로 변환할 binary 추출
        let extractBinary = binary.substring(from: 0, to: 7)
        /// 추출한 binary 삭제
        let startIdx = binary.index(binary.startIndex, offsetBy: 8)
        let modifiedBinary = "\(binary[startIdx...])"
        binary = modifiedBinary
        /// hex 변환
        /// 2진수 -> 16진수
        let binaryToHex = String(Int(extractBinary, radix: 2)!, radix: 16)
        /// padding 추가:  0F 가 F로 표현되는 경우를 방지하기 위함
        let hex = binaryToHex.paddingToLeft(toLength: 2,
                                            withPad: "0",
                                            startingAt: 0)
        hexArray.append(hex)
    }
    return hexArray.joined()
}

// 0. hex로 변환할 이미지
var image = UIImage(named: "sample")
// 1. 이미지를 원하는 사이즈로 변경한다.
// sample size = 250*128
let resizedImage = image?.imageResizing
// 2. 이미지 컬러를 흑백으로 변경한다.
let blackAndWhiteImage = resizedImage?.convertToBlackAndWhite
// 3. 변환한 이미지에서 binary를 추출한다.
let binary = extractBinary(from: blackAndWhiteImage)
// 4. binary string을 hex로 변환한다.
let hexString = convertToHexString(with: binary)
// 5. 변환된 hex를 데이터로 변경한다.
let hexData = hexString.hexaData
// 6. 데이터를 전송한다.
