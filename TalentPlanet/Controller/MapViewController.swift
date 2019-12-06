//
//  MapViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 05/11/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class MapViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    // 프로필 화면에서 받아오는 변수
    var selLat: String!
    var selLng: String!
    var addressName: String!

    // 컨트롤러 변수
    var searchController: UISearchController!
    var annotation: MKAnnotation!
    var localSearchRequest:MKLocalSearch.Request!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearch.Response!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    let locationManager = CLLocationManager()
    
    let defaults = UserDefaults.standard
    
    // 화면 바인딩 변수
    @IBOutlet var btnSearch: UIBarButtonItem!
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        mapView.showsUserLocation = true
        
        if !selLat.isEmpty {
            let latitude = Double(selLat)!
            let longitude = Double(selLng)!
            setLocation(latitude: latitude as CLLocationDegrees, longitude: longitude as CLLocationDegrees, delta: 0.001)
        }
        
        self.title = addressName
        
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(touchMap(sender:)))
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(touchGesture)
    }
    
    @IBAction func showSearchBar(_ sender: Any) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // 검색 버튼 클릭 시
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){

        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }

        localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }

            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    // 위치 지정
    func setLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, delta: Double) {
        let coordinateLocation = CLLocationCoordinate2DMake(latitude, longitude)
        let spanValue = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let locationRegion = MKCoordinateRegion.init(center: coordinateLocation, span: spanValue)
        
        self.pointAnnotation = MKPointAnnotation()
        self.pointAnnotation.title = "기존 위치"
        self.pointAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        
        self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
        self.mapView.centerCoordinate = self.pointAnnotation.coordinate
        self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        mapView.setRegion(locationRegion, animated: true)
    }
    
    // 지도 위치 매니저
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        setLocation(latitude: (lastLocation?.coordinate.latitude)!, longitude: (lastLocation?.coordinate.longitude)!, delta: 0.01)
        
    }
    
    // 지도 클릭 이벤트 함수
    @objc func touchMap(sender: UIGestureRecognizer) {
        let locationInView = sender.location(in: mapView)
        let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        addAnnotation(location: locationOnMap)
    }
    
    // 어노테이션 추가 함수
    func addAnnotation(location: CLLocationCoordinate2D) {
        let annotations = mapView.annotations.filter {
            $0 !== self.mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr")
        
        var locationName: String = ""
        geocoder.reverseGeocodeLocation(userLocation, preferredLocale:locale, completionHandler: {
            (placemarks, error) in
            var placeMark: CLPlacemark!
            placeMark = placemarks![0]
            
            if let city = placeMark.administrativeArea {
                locationName += city
            }
            
            if let locality = placeMark.locality {
                locationName += " " + locality
            }
            
            if let location = placeMark.name {
                locationName += " " + location
            }

            
            annotation.title = locationName
            annotation.subtitle = locationName
            self.mapView.addAnnotation(annotation)
            
            let alert = UIAlertController(title: "위치 지정", message: "현재 위치로 지정하시겠습니까?\n\(locationName)", preferredStyle: .alert)
            let compAction = UIAlertAction(title: "확인", style: .default, handler: {(action) -> Void in
                // 위치 저장 로직
                AF.request("http://175.213.4.39/Accepted/Profile/updateMyLocation.do", method: .post, parameters:["userID":self.defaults.string(forKey: "userID")!, "GP_LAT": location.latitude, "GP_LNG": location.longitude])
                    .validate()
                    .responseJSON {
                        response in
                        var message:String
                        switch response.result {
                        case .success(let value):
                            let json = value as! [String:Any]
                            if json["result"] as! String == "success" {
                                print("저장 성공")
                            } else {
                                print("저장 실패")
                            }
                            
                        case .failure(let error):
                            print("Error in network \(error)")
                            message = "서버 통신에 실패하였습니다. 관리자에게 문의해주시기 바랍니다."
                            let alert = UIAlertController(title: "아이디 중복확인", message: message, preferredStyle: UIAlertController.Style.alert)
                            let alertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                }
            })
            
            let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
            
            alert.addAction(compAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        })
    }

}
