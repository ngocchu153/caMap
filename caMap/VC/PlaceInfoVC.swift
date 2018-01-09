//
//  PlaceInfoView.swift
//  caMap
//
//  Created by ngoChu on 12/20/17.
//  Copyright © 2017 Ngoc. All rights reserved.
//

import UIKit

class PlaceInfoVC: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var btnDetail: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PlaceInfoView", owner: self, options: nil)
        contentView.layer.cornerRadius = 10
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
