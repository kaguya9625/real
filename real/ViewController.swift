//
//  ViewController.swift
//  real
//
//  Created by IS10 on 2019/11/25.
//  Copyright © 2019 IS10. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,
                      CLLocationManagerDelegate,
                      UIGestureRecognizerDelegate{

    @IBOutlet var map: MKMapView!
    var locManager:CLLocationManager!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet var longPressGesRec:UILongPressGestureRecognizer!
    var currentlat:Float = 0
    var currentlon:Float = 0
    var pointAno:MKPointAnnotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways:
                locManager.startUpdatingLocation()
                break
            default:
                break
            }
        }
        
        initMap()
    }
    
    @IBAction func ARbutton(_ sender: Any) {
        
        //遷移処理
        let storyboard: UIStoryboard = self.storyboard!
        let ARpage = storyboard.instantiateViewController(withIdentifier: "ARPage") as! ARViewController
        locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        ARpage.pinlon = Float(pointAno.coordinate.longitude)
        ARpage.pinlat = Float(pointAno.coordinate.latitude)
        ARpage.currentlat = Float(map.userLocation.coordinate.latitude)
        ARpage.currentlon = Float(map.userLocation.coordinate.longitude)
        self.present(ARpage,animated: true,completion: nil)
    }

    func locationManager(_ manager:CLLocationManager,didUpdateLocations locations:[CLLocation]){
        map.userTrackingMode = .follow
        //現在値とピンの距離を計算
        let distance = CalcDistance(map.userLocation.coordinate,pointAno.coordinate)
        if(0 != distance){
            var str:String = Int(distance/1000).description
            str = str + "km"
            if pointAno.title != str{
                pointAno.title = str
                map.addAnnotation(pointAno)
            }
        }
    }
  
    func initMap(){
        var region:MKCoordinateRegion = map.region
        region.span.latitudeDelta=0.002
        region.span.longitudeDelta=0.002
        map.setRegion(region, animated: true)
        map.showsUserLocation = true
        map.userTrackingMode = MKUserTrackingMode.followWithHeading
        map.userLocation.title = ""
        if pointAno.coordinate.latitude == 0{
            button.isEnabled = false
        }
    }
    
    func updateCurrentpos(_ coordinate:CLLocationCoordinate2D){
        var region:MKCoordinateRegion = map.region
        region.center = coordinate
        map.setRegion(region, animated: true)
    }
    
    @IBAction func mapLongPress(_ sender: UILongPressGestureRecognizer){
        if sender.state == .began{
            }
        else if sender.state == .ended{
        let tappoint = sender.location(in: view)
        let center = map.convert(tappoint, toCoordinateFrom: map)
        
        pointAno.coordinate = center
        }
        map.addAnnotation(pointAno)
        button.isEnabled = true
        }
    }
    //距離計算
    func CalcDistance(_ a:CLLocationCoordinate2D ,_ b:CLLocationCoordinate2D) -> CLLocationDistance {
            let aloc:CLLocation = CLLocation(latitude: a.latitude, longitude: a.longitude)
            let bloc:CLLocation = CLLocation(latitude: b.latitude, longitude: b.longitude)
            let dist = bloc.distance(from: aloc)
            return dist
    }


