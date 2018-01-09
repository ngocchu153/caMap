//
//  Controller.swift
//  caMap
//
//  Created by ngoChu on 12/12/17.
//  Copyright © 2017 Ngoc. All rights reserved.
//

import CoreLocation
import Alamofire

class Controller: UIViewController {
    
    static let searchApiHost = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    static let googlePhotosHost = "https://maps.googleapis.com/maps/api/place/photo"
    static let googlePlaceDetailsHost = "https://maps.googleapis.com/maps/api/place/details/json"
    
    static func getNearbyPlaces(by category:String, coordinates:CLLocationCoordinate2D, radius:Int, token: String?, completion: @escaping (NearbyPlacesResponse?) -> Void) {
        
        var params : [String : Any]
        
        if let t = token {
            params = [
                "key" : AppDelegate.googleAPIKey,
                "pagetoken" : t,
            ]
        } else {
            params = [
                "key" : AppDelegate.googleAPIKey,
                "radius" : radius,
                "location" : "\(coordinates.latitude),\(coordinates.longitude)",
                "type" : category.lowercased()
            ]
        }
        
        
        Alamofire.request(searchApiHost, parameters: params, encoding: URLEncoding(destination: .queryString)).responseJSON { response in
            
            let response = NearbyPlacesResponse.init(dict: response.result.value as? [String: Any])
            completion(response)
        }
    }
    
    static func getPlaceDetails(place:Place, completion: @escaping (Place) -> Void) {
        
        guard place.details == nil else {
            completion(place)
            return
        }
        
        var params : [String : Any]
        params = [
            "key" : AppDelegate.googleAPIKey,
            "placeid" : place.placeId,
        ]
        
        Alamofire.request(googlePlaceDetailsHost, parameters: params, encoding: URLEncoding(destination: .queryString)).responseJSON { response in
            let value = response.result.value as? [String : Any]
            place.details = (value)?["result"] as? [String : Any]
            completion(place)
        }
    }
    
    static func googlePhotoURL(photoReference:String, maxWidth:Int) -> URL? {
        return URL.init(string: "\(googlePhotosHost)?maxwidth=\(maxWidth)&key=\(AppDelegate.googleAPIKey)&photoreference=\(photoReference)")
    }
}


struct NearbyPlacesResponse {
    var nextPageToken: String?
    var status: String  = "NOK"
    var places: [Place]?
    
    init?(dict:[String : Any]?) {
        nextPageToken = dict?["next_page_token"] as? String
        
        if let status = dict?["status"] as? String {
            self.status = status
        }
        
        if let results = dict?["results"] as? [[String : Any]]{
            var places = [Place]()
            for place in results {
                places.append(Place.init(placeInfo: place))
            }
            self.places = places
        }
    }
}

