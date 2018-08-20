//
//  NotesButtonCell.swift
//  Modacity
//
//  Created by Benjamin Chris on 23/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol ButtonCellDelegate {
    func onToggleArchivedStatus()
}

class ButtonCell: UITableViewCell {
    
    @IBOutlet weak var labelStatus: UILabel!
    var delegate: ButtonCellDelegate!
    
    @IBAction func onArchive(_ sender: Any) {
        delegate.onToggleArchivedStatus()
    }
    
}
