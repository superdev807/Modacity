//
//  ViewModel.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/2/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

enum PropertyValueEventType {
    case simpleChange
    case inserted
    case deleted
}

typealias ViewModelSubscribeCallback = ((PropertyValueEventType, Any?, Any?)->())

class ViewModel: NSObject {
    
    var callBacks = [String:ViewModelSubscribeCallback]()

    func subscribe(to property: String, callback:@escaping ViewModelSubscribeCallback) {
        self.callBacks[property] = callback
    }
}
