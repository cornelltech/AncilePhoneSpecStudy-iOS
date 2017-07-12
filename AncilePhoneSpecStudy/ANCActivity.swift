//
//  ANCActivity.swift
//  AncilePhoneSpecStudy
//
//  Created by James Kizer on 7/10/17.
//  Copyright © 2017 smalldatalab. All rights reserved.
//

import UIKit
import Gloss

class ANCActivity: Decodable {

    
    let identifier: String
    let type: String
    let element: JSON
    required public init?(json: JSON) {
        
        guard let type: String = "type" <~~ json,
            let identifier: String = "identifier" <~~ json,
            let element: JSON = "element" <~~ json else {
                return nil
        }
        self.identifier = identifier
        self.type = type
        self.element = element
    }
    
}
