//
//  ViewController.swift
//  Map
//
//  Created by limefriends on 2021/05/11.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var currentButton: UIButton!
    @IBOutlet weak var headingButton: UIButton!
    
    var searchBar: UISearchBar!
    var locationManager: CLLocationManager!
    var currentLocation: MTMapPoint?
    // kakao 지도
    var mapView: MTMapView!
    var mapPoint: MTMapPoint!
    var poIItem: MTMapPOIItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "지도 검색"
        navigationItem.titleView = searchBar
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView = MTMapView(frame: self.mapViewContainer.frame)
        mapView.delegate = self
        mapView.baseMapType = .standard
        self.mapViewContainer.addSubview(mapView)
        
        // 위치 권한 확인
        locationManagerRequestValidate()
    }
    
    @IBAction func currentButtonAction(_ sender: Any) {
        currentButton.isSelected = !currentButton.isSelected

        let on = currentButton.isSelected
        mapView.currentLocationTrackingMode = on ? .onWithoutHeading : .off
    }
    
    @IBAction func directionAction(_ sender: Any) {
        headingButton.isSelected = !headingButton.isSelected
        
        let on = headingButton.isSelected
        mapView.currentLocationTrackingMode = on ? .onWithHeading : .off
    }
    
    func setupMarker(_ mapPoint: MTMapPoint) {
        // 마커 추가
        poIItem = MTMapPOIItem()
        poIItem.markerType = MTMapPOIItemMarkerType.redPin
        poIItem.mapPoint = mapPoint
        poIItem.itemName = "여기 사람있어요~!"
        mapView.add(poIItem)
    }
    
    func locationManagerRequestValidate() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            mapView.currentLocationTrackingMode = .onWithoutHeading
            print("authorizedAlways")
            break
        case .authorizedWhenInUse:
            mapView.currentLocationTrackingMode = .onWithoutHeading
            print("authorizedWhenInUse")
            break
        case .denied:
            locationManager!.requestWhenInUseAuthorization()
            print("denied")
            break
        case .notDetermined:
            locationManager!.requestWhenInUseAuthorization()
            print("notDetermined")
            break
        case .restricted:
            locationManager!.requestWhenInUseAuthorization()
            print("restricted")
            break
        default:
            break
        }
    }
}

// MARK: - Kakao Map Delegate
extension ViewController: MTMapViewDelegate {
    func mapView(_ mapView: MTMapView!, failedUpdatingCurrentLocationWithError error: Error!) {
        let status = CLLocationManager.authorizationStatus()
        if status == .denied {
            let ac = UIAlertController(title: "위치 권한 없음", message: "설정에서 위치 권한을 주세영", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            print("--->[mapView:failedUpdatingCurrentLocationWithError]:", error.localizedDescription)
        }
    }
    
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        if self.currentLocation == nil {
            self.currentLocation = location
            mapView.currentLocationTrackingMode = .off
        }
        else {
            self.currentLocation = location
        }
        print("---[updateCurrentLocation] currentLocation:", currentLocation?.mapPointGeo())
    }
}

// MARK: - CLLocation Delegate
extension ViewController: CLLocationManagerDelegate {
    // 위치 권한 확인
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            mapView.currentLocationTrackingMode = .onWithoutHeading
            print("--->[locationManager:didChangeAuthorization]: authorizedAlways")
        case .authorizedWhenInUse:
            mapView.currentLocationTrackingMode = .onWithoutHeading
            print("--->[locationManager:didChangeAuthorization]: authorizedWhenInUse")
        case .denied:
            mapView.currentLocationTrackingMode = .off
            print("--->[locationManager:didChangeAuthorization]: denied")
        case .notDetermined:
            mapView.currentLocationTrackingMode = .off
            print("--->[locationManager:didChangeAuthorization]: notDetermined")
        case .restricted:
            mapView.currentLocationTrackingMode = .off
            print("--->[locationManager:didChangeAuthorization]: restricted")
        default:
            break
        }
    }

    // Error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("--->[locationManager:didFailWithError]:", error.localizedDescription)
    }
}

// MARK: - 카카오 지도 검색
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text?.trimmingCharacters(in: .whitespaces), !searchTerm.isEmpty else {
            searchBar.resignFirstResponder()
            return
        }
        
        //주소 검색 api 샘플 https://developers.kakao.com/docs/latest/ko/local/dev-guide#address-coord
        let url = URL(string: "https://dapi.kakao.com/v2/local/search/keyword.json")!
        let headers: HTTPHeaders = ["Authorization": "KakaoAK d34b939ac69035d1da893ac6956cac5b"]
        let parameters: [String: Any] = [
            "query": searchTerm,
            "page": 1,
            "size": 1
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers)
            .validate()
            .responseJSON { res in
                switch res.result {
                case .success(let value):
                    
                    let data = JSON(value)
                    let result = data["documents"].arrayValue[0]
                    let longitude = result["x"].doubleValue
                    let latitude = result["y"].doubleValue
                    
                    let mapPointGeo = MTMapPointGeo(latitude: latitude, longitude: longitude)
                    let mapPoint = MTMapPoint(geoCoord: mapPointGeo)
                    
                    self.mapView.setMapCenter(mapPoint, zoomLevel: 1, animated: false)
                    self.setupMarker(mapPoint!)
                    self.mapView.currentLocationTrackingMode = .off
                    
                case .failure(let error):
                    print("--->[Map Search Error]:", error)
                }
            }
        searchBar.resignFirstResponder()
    }
}
