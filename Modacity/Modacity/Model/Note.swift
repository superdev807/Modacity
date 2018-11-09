//
//  Note.swift
//  Modacity
//
//  Created by Benjmain Chris on 1/5/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class Note: Mappable {
    var id: String!
    var createdAt: String!
    var note: String! = ""
    var subTitle: String! = ""
    var archived: Bool! = false
    
    var isDeliberatePracticeNote = false
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id                          <- map["id"]
        createdAt                   <- map["created_at"]
        note                        <- map["note"]
        archived                    <- map["archived"]
        subTitle                    <- map["subtitle"]
        isDeliberatePracticeNote    <- map["improved"]
    }
    
    func deliberatePracticeNoteProcess() -> NSAttributedString {
        let noteText = note ?? ""
        let components = noteText.components(separatedBy: ":::::")
        if components.count > 1 {
            let attributedString = NSMutableAttributedString(string: components[0],
                                                             attributes: [NSAttributedStringKey.font: AppConfig.UI.Fonts.latoBoldItalic(with: 14),
                                                                          NSAttributedStringKey.foregroundColor: AppConfig.UI.AppColors.noteTextColorInPractice])
            attributedString.append(NSAttributedString(string: " - \"\(components[1])\"",
                attributes: [NSAttributedStringKey.font: AppConfig.UI.Fonts.latoItalic(with: 14),
                             NSAttributedStringKey.foregroundColor: AppConfig.UI.AppColors.noteTextColorInPractice]))
            return attributedString
        } else {
            return NSAttributedString(string: note,
                                      attributes: [NSAttributedStringKey.font: AppConfig.UI.Fonts.latoItalic(with: 14),
                                                   NSAttributedStringKey.foregroundColor: AppConfig.UI.AppColors.noteTextColorInPractice])
        }
    }
}
