//
//  ViewModel.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/2/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
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
