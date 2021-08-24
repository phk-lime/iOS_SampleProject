//
//  ViewController.swift
//  BluetoothImageTranfer
//
//  Created by limefriends on 2021/08/20.
//

import UIKit
import CoreBluetooth
import Mantis

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var connectStatusLabel: UILabel!
    
    var imagePicker = UIImagePickerController()
    
    var bluetoothService = CoreBluetoothService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// image picker
        imagePicker.delegate = self
        /// bluetoothService 설정
        bluetoothService.connectCompletion = { success in
            self.connectStatusLabel.backgroundColor = .orange
            self.connectStatusLabel.text = "DoorLock_aBLE - Connect"
        }
    }
    
    // MARK: - ACtion
    @IBAction func imageSelect(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func imageSizeConvert(_ sender: Any) {
        guard let currentImage = imageView.image else { return }
        let resizeImage = currentImage.resizeToFitLCDScreen()
        imageView.image = resizeImage
    }
    
    @IBAction func imageColorChange(_ sender: Any) {
        guard let currentImage = imageView.image else { return }
        let grayScaleImage = currentImage.grayScaled
        imageView.image = grayScaleImage
    }
    
    @IBAction func hexStringConvert(_ sender: Any) {
        guard let currentImage = imageView.image else { return }
        let jpegData = currentImage.jpegData(compressionQuality: 0.1)!
        let hexaString = jpegData.map { String(format: "%02x", $0) }.joined()
        let hexaData = hexaString.hexaData
        textView.text = "--->[hexaData: \(hexaData)] \(hexaString)"
    }
    
    // MARK: - 이미지 전송
    @IBAction func imageTransfer(_ sender: Any) {
//        /// 현재 이미지 가져오기
//        guard let currentImage = imageView.image else { return }
//        /// 250 * 122 로 사이즈 변경
//        let resizeImage = currentImage.resizeToFitLCDScreen()
//        /// 흑백 이미지로 변경
//        let grayScaleImage = resizeImage.grayScaled!
//        /// jpegData로 변환
//        let jpegData = grayScaleImage.jpegData(compressionQuality: 0.1)!
//        /// hexaString
//        let hexaString = jpegData.map { String(format: "%02x", $0) }.joined()
//        /// hexaData
//        let hexaData = hexaString.hexaData
        
        /// 999개만 뽑아서 보내보기
//        let endIndex: String.Index = hexaString.index(hexaString.startIndex, offsetBy: 998)
//        let testStr = String(hexaString[...endIndex])
//        command += testStr
        
        
        var testImage = "02FA02A203"
        var testBarcode = "02FA02A209"
        
        let testData = testBarcode.hexaData
        print("--->[transfer data] \(testData)")
        
        guard let connectedPeripherals = bluetoothService.connectedPeripherals else { return }
        connectedPeripherals.writeValue(testData,
                                        for: TransferService.transferCharacteristic!,
                                        type: .withoutResponse)
        
        print("--->[transfer] success")
    }
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }

        let config = Mantis.Config()
        let cropViewController = Mantis.cropViewController(image: selectedImage,
                                                           config: config)
        cropViewController.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 2.0 / 1.0)
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.delegate = self
        
        picker.pushViewController(cropViewController, animated: true)
    }
}

extension ViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        
        imageView.image = cropped
        
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.navigationController?.popViewController(animated: true)
    }
}
