//
//  Photo.swift
//  caMap
//
//  Created by ngoChu on 12/25/17.
//  Copyright © 2017 Ngoc. All rights reserved.
//

import Foundation

private let widthKey = "width"
private let heightKey = "height"
private let photoReferenceKey = "photo_reference"

class Photo: NSObject {
    
    var width: Int?
    var height: Int?
    var photoRef: String?
    
    init(photoInfo: [String:Any]) {
        height = photoInfo[heightKey] as? Int
        width = photoInfo[widthKey] as? Int
        photoRef = photoInfo[photoReferenceKey] as? String
    }
    
    func getPhotoURL(maxWidth:Int) -> URL? {
        if let ref = self.photoRef {
            return Controller.googlePhotoURL(photoReference: ref, maxWidth: maxWidth)
        }
        return nil
    }
}
