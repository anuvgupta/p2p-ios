//
//  TutorListQueryBar.swift
//  p2p
//
//  Created by Amar Ramachandran on 10/17/16.
//  Copyright © 2016 sfhacks. All rights reserved.
//

import UIKit

class TutorListQueryBar: UIView {
    
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        create()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        create()
    }
    
    func create() {
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 10.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    }

}
