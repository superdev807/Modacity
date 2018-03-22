//
//  PlaylistViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/10/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol PlaylistCellDelegate {
    func onFavorite(_ playlist: Playlist)
}

class PlaylistCell: UITableViewCell {
    
    @IBOutlet weak var labelPlaylistName: UILabel!
    @IBOutlet weak var buttonFavorite: UIButton!
    var playlist: Playlist!
    var delegate: PlaylistCellDelegate?
    
    func configure(with playlist: Playlist, isFavorite: Bool) {
        self.playlist = playlist
        self.labelPlaylistName.text = playlist.name
        
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
}

class PlaylistViewController: UIViewController {

    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var viewNoPlaylist: UIView!
    
    var viewModel = PlaylistViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        self.tableViewMain.tableFooterView = UIView()
        self.viewNoPlaylist.isHidden = false
        self.bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Playlist"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_details" {
            let controller = (segue.destination as! UINavigationController).viewControllers[0] as! PlaylistDetailsViewController
            let model = PlaylistDeliverModel()
            model.deliverPlaylist = self.viewModel.detailSelection
            controller.parentViewModel = model
        }
    }
    
    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
    func bindViewModel() {
        self.viewModel.subscribe(to: "playlists") { (_, _, _) in
            if self.viewModel.countOfPlaylists() == 0 {
                self.viewNoPlaylist.isHidden = false
            } else {
                self.viewNoPlaylist.isHidden = true
            }
            self.tableViewMain.reloadData()
        }
        
        self.viewModel.loadPlaylists()
    }
    
}

extension PlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.countOfPlaylists()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell") as! PlaylistCell
        let playlist = self.viewModel.playlist(at: indexPath.row)
        cell.configure(with: playlist, isFavorite: self.viewModel.isFavorite(playlist))
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.detailSelection = self.viewModel.playlist(at: indexPath.row)
        
        AmplitudeTracker.LogEvent(.NewPlaylist, extraParamName: "Playlist", extraParamValue: self.viewModel.detailSelection!.name)
        
        self.performSegue(withIdentifier: "sid_details", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "") { (action, indexPath) in
            self.viewModel.deletePlaylist(at: indexPath.row)
        }
        delete.setIcon(iconImage: UIImage(named:"icon_row_delete")!, backColor: Color(hexString: "#6815CE"), cellHeight: 64, iconSizePercentage: 0.25)
        
        return [delete]
        
    }
    
}

extension PlaylistViewController: PlaylistCellDelegate {
    func onFavorite(_ playlist: Playlist) {
        self.viewModel.setFavorite(playlist)
        self.tableViewMain.reloadData()
    }
}
