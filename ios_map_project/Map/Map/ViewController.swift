//
//  ViewController.swift
//  Map
//
//  Created by DDWU on 10/18/24.
//
import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var myMap: MKMapView!
    @IBOutlet var lblLocationInfo1: UILabel!
    @IBOutlet var lblLocationInfo2: UILabel!
    @IBOutlet var LocationField: UITextField!
    @IBOutlet var btn: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblLocationInfo1.text = ""
        lblLocationInfo2.text = ""
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        myMap.showsUserLocation = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        myMap.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func moveToLocation(_ sender: UIButton) {
        let address = LocationField.text
        if address == nil || address!.isEmpty {
            return
        }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!) { (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }

            if let placemark = placemarks?.first, let location = placemark.location {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude

                self.goLocation(latitudeValue: latitude, longitudeValue: longitude, delta: 0.01)

                self.lblLocationInfo1.text = "위도/경도: \(latitude), \(longitude)"

                self.updateAddressLabel(with: placemark)
            } else {
                print("No matching location found.")
            }
        }

    }

    func goLocation(latitudeValue: CLLocationDegrees, longitudeValue: CLLocationDegrees, delta span: Double) -> CLLocationCoordinate2D {
        let pLocation = CLLocationCoordinate2DMake(latitudeValue, longitudeValue)
        let spanValue = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        let pRegion = MKCoordinateRegion(center: pLocation, span: spanValue)
        myMap.setRegion(pRegion, animated: true)
        return pLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let pLocation = locations.last {
            goLocation(latitudeValue: pLocation.coordinate.latitude, longitudeValue: pLocation.coordinate.longitude, delta: 0.01)
            CLGeocoder().reverseGeocodeLocation(pLocation) { (placemarks, error) in
                if let pm = placemarks?.first {
                    self.updateAddressLabel(with: pm)
                }
            }
            locationManager.stopUpdatingLocation()
        }
    }
    
    private func updateAddressLabel(with placemark: CLPlacemark) {
        var addressString = ""
        if let name = placemark.name {
            addressString += name
        }
        if let locality = placemark.locality {
            addressString += ", \(locality)"
        }
        if let administrativeArea = placemark.administrativeArea {
            addressString += ", \(administrativeArea)"
        }
        if let country = placemark.country {
            addressString += ", \(country)"
        }
        lblLocationInfo2.text = addressString
    }
    
    func setAnnotation(latitudeValue: CLLocationDegrees, longitudeValue: CLLocationDegrees, delta span: Double, title strTitle: String, subtitle strSubtitle: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = goLocation(latitudeValue: latitudeValue, longitudeValue: longitudeValue, delta: span)
        annotation.title = strTitle
        annotation.subtitle = strSubtitle
        myMap.addAnnotation(annotation)
    }
    
    @IBAction func sgChangeLocation(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            lblLocationInfo1.text = "현재위치"
            lblLocationInfo2.text = ""
            locationManager.startUpdatingLocation()
        case 1:
            let latitude = 37.751853
            let longitude = 128.87605740000004
            setAnnotation(latitudeValue: latitude, longitudeValue: longitude, delta: 1, title: "한국폴리텍대학 강릉캠퍼스", subtitle: "강원도 강릉시 남산초교길 121")
            goLocation(latitudeValue: latitude, longitudeValue: longitude, delta: 0.01) // 지도 이동 추가
            lblLocationInfo1.text = "보고 계신 위치"
            lblLocationInfo2.text = "한국폴리텍대학 강릉캠퍼스"
        case 2:
            let latitude = 37.556876
            let longitude = 126.914066
            setAnnotation(latitudeValue: latitude, longitudeValue: longitude, delta: 0.1, title: "이지스퍼블리싱", subtitle: "서울시 마포구 잔다리로 109 이지스 빌딩")
            goLocation(latitudeValue: latitude, longitudeValue: longitude, delta: 0.01) // 지도 이동 추가
            lblLocationInfo1.text = "보고 계신 위치"
            lblLocationInfo2.text = "이지스퍼블리싱 출판사"
        default:
            break
        }
    }

    
    @objc func handleMapTap(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: myMap)
        let coordinate = myMap.convert(location, toCoordinateFrom: myMap)

        lblLocationInfo1.text = "위도: \(coordinate.latitude), 경도: \(coordinate.longitude)"

        let locationToGeocode = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(locationToGeocode) { (placemarks, error) in
            if let error = error {
                print("Error in reverse geocoding: \(error)")
                return
            }
            
            if let placemark = placemarks?.first {
                self.updateAddressLabel(with: placemark)
            }
        }
    }
}
