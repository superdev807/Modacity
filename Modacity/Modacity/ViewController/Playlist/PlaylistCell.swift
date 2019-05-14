//
//  PlaylistCell.swift
//  Modacity
//
//  Created by Dream Realizer on 19/11/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol PlaylistCellDelegate {
    func onFavorite(_ playlist: Playlist)
    func onMenu(_ playlist: Playlist, buttonMenu: UIButton, cell:PlaylistCell)
    
    func onNameEdited(on cell:PlaylistCell, for playlist:Playlist, to changedName: String)
}

class PlaylistCell: UITableViewCell {
    
    @IBOutlet weak var buttonMenu: UIButton!
    @IBOutlet weak var labelPlaylistName: UILabel!
    @IBOutlet weak var buttonFavorite: UIButton!
    @IBOutlet weak var textfieldPlaylistName: UITextField!
    
    var playlist: Playlist!
    var delegate: PlaylistCellDelegate?
    
    func configure(with playlist: Playlist, isFavorite: Bool) {
        self.playlist = playlist
        self.labelPlaylistName.text = playlist.name
        self.textfieldPlaylistName.isHidden = true
        self.labelPlaylistName.isHidden = false
        if isFavorite {
            self.buttonFavorite.setImage(UIImage(named:"icon_heart_red"), for: .normal)
            self.buttonFavorite.alpha = 1.0
        } else {
            self.buttonFavorite.setImage(UIImage(named:"icon_heart"), for: .normal)
            self.buttonFavorite.alpha = 0.5
        }
    }
    
    @IBAction func onHeart(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onFavorite(self.playlist)
        }
    }
    
    @IBAction func onMenu(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onMenu(self.playlist, buttonMenu: self.buttonMenu, cell: self)
        }
    }
    
    @IBAction func onEditingDidEnd(_ sender: Any) {
        
        self.textfieldPlaylistName.resignFirstResponder()
        
        if let delegate = self.delegate {
            delegate.onNameEdited(on:self, for: self.playlist, to: self.textfieldPlaylistName.text!)
        }
        
        
        self.textfieldPlaylistName.isHidden = true
        self.labelPlaylistName.isHidden = false
    }
}
