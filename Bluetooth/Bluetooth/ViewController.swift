//
//  ViewController.swift
//  Bluetooth
//
//  Created by limefriends on 2021/05/28.
//

import UIKit
import CoreBluetooth ///// Bluetooth low energy 및 BR/EDR (“Classic”) 장치와 통신합니다.

class ViewController: UIViewController {
    @IBOutlet weak var stateLabel: UILabel!
    
    /// CBCentralManager 및 CBPeripheral 클래스를 사용합니다.
    /// 디바이스(전화기)는 중앙 관리자가 될 것이며 주변 BLE 장치와 인터페이스하는 방법을 사용할 것이기 때문입니다.
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// viewDidLoad 호출 -> centralManager 초기화 -> centralManagerDidUpdateState 호출
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension ViewController: CBCentralManagerDelegate {
    /// 기기에서 블루투스의 하드웨어 상태를 확인하는 데 사용됩니다 (예 : 전원이 켜져 있고 사용할 수 있는지 또는 비활성화 되었는지 여부).
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state = central.state
        if state == .poweredOn {
            self.stateLabel.text = "State: BLE powered on"
            print("--->[centralManagerDidUpdateState]: BLE powered on")
            /// CBManager상태가 켜져 있으면 중앙에 다음과 같은 주변 장치를 검색하도록 요청
            /// withServices 및 options 매개 변수를 사용하면 서비스 UUID를 기반으로 사용자 정의 된 스캔이 가능하지만 지금은 nil을 사용하여 광범위한 스캔을 합니다.
            central.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            self.stateLabel.text = "State: Something wrong with BLE"
            print("--->[centralManagerDidUpdateState]: Something wrong with BLE")
        }
    }
    
    /// 대리인에게 중앙 관리자가 장치를 검색하는 동안 주변 장치를 발견했음을 알립니다.
    /// central - 업데이트를 제공하는 중앙 관리자입니다.
    /// peripheral - 발견 된 주변 장치.
    /// advertisementData - 광고 데이터를 포함하는 사전.
    /// RSSI - 주변 장치의 현재 수신 신호 강도 표시기 (RSSI) (데시벨)입니다.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        /// 이름, UUID, 제조업체 ID 또는 기본적으로 광고 데이터의 일부로 주변 장치를 식별 할 수 있습니다. 가장 간단한 방법은 이름으로 검색하는 것이지만 확실히 안전한 방법은 아닙니다.
        /// 이상적으로는 이름, UUID 및 제조업체 ID를 확인해야합니다. 지금은 중앙 관리자가 찾은 각 장치의 이름만 확인
        if let pName = peripheral.name {
            print("--->[centralManager:didDiscover]: ", pName)
        }
    }
}

extension ViewController: CBPeripheralDelegate {
    
}
