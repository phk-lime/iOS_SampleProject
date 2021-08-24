//
//  CoreBluetoothService.swift
//  CoreBluetoothService
//
//  Created by limefriends on 2021/08/20.
//

import Foundation
import CoreBluetooth

struct TransferService {
    static let serviceUUID = CBUUID(string: "0xFFF0")
    static let characteristicUUID = CBUUID(string: "0xFFF1")
    static var transferCharacteristic: CBCharacteristic?
}

class CoreBluetoothService: NSObject {
    
    static let shared = CoreBluetoothService()
    
    var centralManager: CBCentralManager!
    
    var connectedPeripherals: CBPeripheral?
    
    var connectCompletion: ((Bool) -> Void)?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self,
                                          queue: nil)
    }
}

// MARK: - CBCentralManagerDelegate
extension CoreBluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        /// centralManagerDidUpdateState는 필수 프로토콜 메서드입니다.
        /// 일반적으로 다른 상태를 확인하여 현재 장치가 LE를 지원하는지, 전원이 켜져 있는지 등을 확인합니다.
        /// 이 예시에서는 CBCentralManagerState PoweredOn을 기다리는 데 사용하고 있습니다.
        /// Central을 사용할 준비가되었습니다.
        switch central.state {
        case .poweredOn:
            /// 주변 장치로 작업을 시작
            print("--->[centralManager:DidUpdateState] CBManager is powered on")
            centralManager.scanForPeripherals(withServices: nil,
                                              options: nil)
        case .poweredOff:
            print("--->[centralManager:DidUpdateState] CBManager is not powered on")
            return
        default:
            print("--->[centralManager:DidUpdateState] A previously unknown central manager state occurred")
            return
        }
        
    }
    
    /// 이 콜백은 전송 서비스 UUID를 알리는 주변 장치가 발견될 때마다 발생합니다.
    /// RSSI를 확인하여 우리가 관심을 가질 만큼 가까이 있는지 확인합니다.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        /// 신호 강도가 너무 낮아 데이터 전송을 시도 할 수없는 경우 거부합니다.
        /// 앱의 사용 사례에 따라 최소 RSSI 값을 변경합니다.
        //        guard RSSI.intValue >= -66 else { return }
        
        /// 검색된 주변 장치 print
        print("--->[centralManager:didDiscover] discoverd perhiperals: ", peripheral)
        
        if peripheral.name == "DoorLock_aBLE" {
            /// DoorLock_aBLE이 발견되면 주변장치 연결 프로세스 진행
            /// 주변 장치의 로컬 복사본을 저장 -> 주변 장치의 로컬 복사본을 저장하면 CoreBluetooth가 제거하지 않습니다.
            connectedPeripherals = peripheral
            /// 주변 장치에 연결합니다.
            centralManager.connect(connectedPeripherals!, options: nil)
        }
    }
    
    /// 어떤 이유로 든 연결이 실패하면 처리해야합니다.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("--->[centralManager:didFailToConnect] Failed to connect to \(peripheral), Error: \(error)")
    }
    
    /// 주변 장치에 연결 했으므로 이제 'transferCharacteristic'를 찾기 위해 서비스와 특성을 찾아야합니다.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("--->[centralManager:didConnect] Peripheral Connected")
        
        /// 스캔 중지
        centralManager.stopScan()
        print("--->[centralManager:didConnect] Scanning stopped")
        
        /// connectCompletion
        connectCompletion?(true)
        
        /// 검색 콜백을 받았는지 확인하십시오.
        peripheral.delegate = self
        
        /// serviceUUID와 일치하는 서비스만 검색
        /// 서비스 정보를 받게되면 peripheral didDiscoverServices가 호출됩니다.
        peripheral.discoverServices([TransferService.serviceUUID])
    }
    
    /// 연결이 끊어지면 주변 장치의 로컬 복사본을 정리해야합니다.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("--->[centralManager:didDisconnectPeripheral] Perhiperal Disconnected")
        /// 연결된 주변장치 복사본 정리
        connectedPeripherals = nil
    }
}

extension CoreBluetoothService: CBPeripheralDelegate {
    /// 서비스가 무효화되었을 때 알려주는 주변 장치.
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where service.uuid == TransferService.serviceUUID {
            print("--->[peripheral:didModifyServices] 전송 서비스 무효화, 서비스 재검색 중")
            peripheral.discoverServices([TransferService.serviceUUID])
        }
    }
    
    /// Transfer Service가 발견되었습니다.
    /// 특성이 발견되면 didDiscoverCharacteristicsForService메소드가 호출된다.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("--->[peripheral:didDiscoverServices] Error discovering services: ", error)
            return
        }
        
        /// 둘 이상의 경우를 대비하여 새로 채워진 peripheral.services 배열을 반복합니다.
        guard let peripheralServices = peripheral.services else {
            print("--->[peripheral:didDiscoverServices] peripheralServices 없음")
            return
        }
        
        for service in peripheralServices {
            print("--->[peripheral:didDiscoverServices] Transfer Service가 발견되었습니다. ", service)
            peripheral.discoverCharacteristics([TransferService.characteristicUUID], for: service)
        }
    }
    
    /// Transfer characteristic이 발견되었습니다.
    /// 이것이 발견되면, 우리는 그것을 구독하기를 원합니다. 이것은 우리가 포함하고 있는 데이터를 원한다는 것을 주변기기에 알려줍니다.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("--->[peripheral:didDiscoverCharacteristicsFor] Error discovering characteristics: ", error)
            return
        }
        
        /// 다시 말하지만, 만약의 경우에 대비하여 배열을 반복하고 올바른지 확인합니다.
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicUUID {
            /// 올바르다면 구독하십시오
            TransferService.transferCharacteristic = characteristic
            print("--->[didDiscoverCharacteristicsFor] Transfer characteristic이 발견되었습니다: ", characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    /// 구독 / 구독 취소 여부를 알려주는 주변 장치
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("--->[peripheral:didUpdateNotificationStateFor] Error changing notification state: ", error)
            return
        }
        
        /// 전송 특성이 아닌 경우 종료
        guard characteristic.uuid == TransferService.characteristicUUID else { return }
        
        if characteristic.isNotifying {
            /// 알림이 시작되었습니다
            print("--->[peripheral:didUpdateNotificationStateFor] Notification(구독)이 시작되었습니다, ", characteristic)
        } else {
            /// 알림이 중지되었으므로 주변 장치에서 분리
            print("--->[peripheral:didUpdateNotificationStateFor] Notification(구독)이 취소되었습니다, 연결을 해제합니다", characteristic)
        }
    }
}
