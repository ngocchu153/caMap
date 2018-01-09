//
//  PlaceDetailVC.swift
//  caMap
//
//  Created by ngoChu on 12/25/17.
//  Copyright © 2017 Ngoc. All rights reserved.
//

import UIKit
import SafariServices
import AlamofireImage

class PlaceDetailVC: UIViewController {
    var place: Place!
    var distance: Double!
    @IBOutlet weak var website: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var placeDescription: UILabel!
    
    @IBAction func btnWebsitePressed(_ sender: Any) {
        Controller.getPlaceDetails(place: place) { (place) in
            if let website = place.details?["website"] as? String, let url = URL(string: website) {
                let svc = SFSafariViewController.init(url: url)
                svc.delegate = self
                
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(svc, animated: true)
            }
        }
    }
    override func viewDidLoad() {
        self.title = place.name
        placeDescription.text = place.getDescription()
        
        if let url = place.photos?.first?.getPhotoURL(maxWidth: 600) {
            photo.af_setImage(withURL: url)
        }
    }
}

extension PlaceDetailVC: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // pop safari view controller and display navigation bar again
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.isNavigationBarHidden = false
    }
}
