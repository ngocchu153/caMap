//
//  ViewController.swift
//  caMap
//
//  Created by ngoChu on 12/12/17.
//  Copyright © 2017 Ngoc. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMaps
import GooglePlaces

class MainVC: UIViewController, CLLocationManagerDelegate, GetCategoryDelegate {
    
    internal func updatePlacesOnMap(category: String) {
        print("load \(category)" )
        loadPlaces(by: category)
        clearPlacesInfoViews()
        lbCategory.text = category
    }
    
    @IBAction private  func btnCategoryPressed(_ sender: Any) {
        performSegue(withIdentifier: "choose-category", sender: nil)
    }
    
    @objc private func btnDetailPressed(sender: UIButton) {
        placeToViewDetail = places[sender.tag]
        performSegue(withIdentifier: "view-place-detail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "choose-category" {
            if let destination = segue.destination as? CategoriesVC {
                destination.delegate = self
            }
        }
        if segue.identifier == "view-place-detail" {
            if let destinationVC = segue.destination as? PlaceDetailVC {
                destinationVC.place = placeToViewDetail
            }
        }
    }
    
    @IBOutlet private weak var mapView: GMSMapView!
    @IBOutlet private weak var previewView: UIImageView!
    @IBOutlet private weak var lbCategory: UILabel!
    
    private var locationManager: CLLocationManager!
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var input: AVCaptureDeviceInput?
    private var currentLocation: CLLocationCoordinate2D!
    private var response : NearbyPlacesResponse?
    
    private var places = [Place]()
    private var placeToViewDetail: Place?
    
    private func initComponents() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        locationManager.distanceFilter = CLLocationDistance(100.0)
        //locationManager.headingFilter = 10
        
        let userLocation = locationManager.location
        let camera = GMSCameraPosition.camera(withLatitude: (userLocation?.coordinate.latitude)!, longitude: (userLocation?.coordinate.longitude)!, zoom: 13)
        currentLocation = CLLocationCoordinate2DMake(userLocation!.coordinate.latitude, userLocation!.coordinate.longitude)
        
        addSightView(mapView)
        
        mapView.layer.cornerRadius = 75
        mapView.camera = camera
        //mapView.isMyLocationEnabled = true
        mapView.isUserInteractionEnabled = false
        do {
            // Set the map style
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    func addSightView(_ mv: GMSMapView) {
        let sightView = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: mv.frame.width/2, y: mv.frame.height/2))
        linePath.addLine(to: CGPoint(x: mv.frame.width, y: 0))
        sightView.path = linePath.cgPath
        sightView.strokeColor = UIColor.blue.cgColor
        sightView.lineWidth = 0.1
        sightView.lineJoin = kCALineJoinRound
        sightView.fillColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 0.2)
        
        mv.layer.addSublayer(sightView)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        currentLocation = CLLocationCoordinate2DMake(userLocation!.coordinate.latitude, userLocation!.coordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: (userLocation?.coordinate.latitude)!, longitude: (userLocation?.coordinate.longitude)!, zoom: 13)
        mapView.camera = camera
    }
    
    private func captureCameraPreview() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
        } catch {
            print("Cannot load camera")
        }
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as AVCaptureDeviceInput!)
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.bounds
        
        previewView.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.startRunning()
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        videoPreviewLayer?.frame = self.view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.videoPreviewLayer?.connection  {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        updatePlacesOnMap(category: "Atm")
        
        captureCameraPreview()
        self.view.bringSubview(toFront: mapView)
      
    }
    
    var customView = [PlaceInfoVC]()
    
    private func clearPlacesInfoViews() {
        for v in view.subviews{
            if v is PlaceInfoVC{
                v.removeFromSuperview()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        mapView.animate(toBearing: newHeading.trueHeading)
        
        if places.first != nil {
            clearPlacesInfoViews()
            drawPlacesInfoOnScreen(newHeading)
        }
    }
    
    private func drawPlacesInfoOnScreen(_ newHeading: CLHeading) {
        //just show left,mid and right
        var yy = view.bounds.maxY - 140
        for (index, place) in places.enumerated() {
            if (CGFloat(yy) < 170) {
                break
            }
            let distance = GMSGeometryDistance(currentLocation, (place.location)!)
            if distance < 100.0 {
                continue
            }
            let bearing = getViewAngleBetween2Points(origin: currentLocation, target: (place.location)!)
            
            let viewAngle = newHeading.trueHeading - bearing
            let cview = PlaceInfoVC()
            
            if viewAngle >= 30 && viewAngle < 45 {
               cview.frame = CGRect(x: 0, y: CGFloat(yy), width: 200, height: 50)
            }
            else if viewAngle >= -30 && viewAngle < 30 {
                cview.frame = CGRect(x: CGFloat(view.bounds.midX - 100), y: CGFloat(yy), width: 200, height: 50)
            }
            else if viewAngle < -30 && viewAngle >= -45 {
                cview.frame = CGRect(x: CGFloat(view.bounds.maxX - 200), y: CGFloat(yy), width: 200, height: 50)
            }
            else {
                print(place.name!, viewAngle)
                continue
            }
            
            
            cview.name.text = place.name
            cview.distance.text = String(format: "Distance: %.2f meters", distance)
            cview.distance.text = String(format: "%.2f", viewAngle) + " / "
            cview.btnDetail.addTarget(self, action: #selector(btnDetailPressed(sender:)), for: .touchUpInside)
            cview.btnDetail.tag = index
            
            self.view.addSubview(cview)
            yy -= 70
        }
    }
    
    private func getViewAngleBetween2Points(origin: CLLocationCoordinate2D, target: CLLocationCoordinate2D) -> Double {
        //return  GMSGeometryHeading(origin, target)
        return(GMSGeometryHeading(target, origin) +  180).truncatingRemainder(dividingBy: 360)
    }
    
    private func loadPlaces(by category: String) {
        print("loading \(category)")
        Controller.getNearbyPlaces(by: category, coordinates: currentLocation!, radius: 1000, token: self.response?.nextPageToken, completion: didReceiveResponse)
    }
    
    private func didReceiveResponse(response: NearbyPlacesResponse?) {
        self.response = response
        if response?.status == "OK" {
            if let p = response?.places {
                self.places = p
                
                //clear all old and pin news markers
                mapView.clear()
                for place:Place in places {
                    if GMSGeometryDistance(currentLocation, (place.location)!) >= 100.0 {
                        pinNewMarkerAt(place: place)
                    }
                }
            }
        } else {
            let alert = UIAlertController.init(title: "Error", message: "Unable to fetch nearby places", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction.init(title: "Retry", style: .default, handler: { (action) in
                self.loadPlaces(by: "")
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func pinNewMarkerAt(place: Place){
        let marker = GMSMarker()
        marker.icon = #imageLiteral(resourceName: "icons8-marker-12")
        marker.position = CLLocationCoordinate2DMake((place.location?.latitude)!, (place.location?.longitude)!)
        marker.map = mapView
    }
    
}


