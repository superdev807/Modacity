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
    func onMenu(_ playlist: Playlist, buttonMenu: UIButton, cell:PlaylistCell)
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
        if self.textfieldPlaylistName.text != "" {
            self.labelPlaylistName.text = self.textfieldPlaylistName.text
            self.playlist.name = self.textfieldPlaylistName.text
            self.playlist.updateMe()
        }
        self.textfieldPlaylistName.isHidden = true
        self.labelPlaylistName.isHidden = false
    }
}

class PlaylistListViewController: UIViewController {

    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var viewNoPlaylist: UIView!
    
    var viewModel = PlaylistViewModel()
    var editingCell: PlaylistCell? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in || AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            self.constraintForHeaderImageViewHeight.constant = 70
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
            let controller = (segue.destination as! UINavigationController).viewControllers[0] as! PlaylistContentsViewController
            let model = PlaylistAndPracticeDeliverModel()
            model.deliverPlaylist = self.viewModel.detailSelection
            controller.parentViewModel = model
        }
    }
    
    @IBAction func onMenu(_ sender: Any) {
        if self.editingCell != nil {
            self.editingCell!.textfieldPlaylistName.resignFirstResponder()
            self.editingCell = nil
        }
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

extension PlaylistListViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        ModacityAnalytics.LogEvent(.NewPlaylist, extraParamName: "Playlist", extraParamValue: self.viewModel.detailSelection!.name)
        
        self.performSegue(withIdentifier: "sid_details", sender: nil)
    }
}

extension PlaylistListViewController: PlaylistCellDelegate {
    
    func onFavorite(_ playlist: Playlist) {
        self.viewModel.setFavorite(playlist)
        self.tableViewMain.reloadData()
    }
    
    func onMenu(_ playlist: Playlist, buttonMenu: UIButton, cell: PlaylistCell) {
        DropdownMenuView.instance.show(in: self.view,
                                       on: buttonMenu,
                                       rows: [["icon":"icon_notes", "text":"Details"],
                                              ["icon":"icon_pen_white", "text": "Rename"],
                                              ["icon":"icon_row_delete", "text":"Delete"]]) { (row) in
                                                if row == 2 {
                                                    self.viewModel.deletePlaylist(for: playlist)
                                                } else if row == 1 {

                                                    if self.editingCell != nil {
                                                        self.editingCell!.textfieldPlaylistName.resignFirstResponder()
                                                        self.editingCell = nil
                                                    }
                                                    cell.textfieldPlaylistName.isHidden = false
                                                    cell.labelPlaylistName.isHidden = true
                                                    cell.textfieldPlaylistName.becomeFirstResponder()
                                                    cell.textfieldPlaylistName.text = cell.playlist.name
                                                    self.editingCell = cell
                                                    cell.textfieldPlaylistName.becomeFirstResponder()
                                                } else {
                                                    self.openDetails(playlist)
                                                }
        }
    }
    
    func openDetails(_ playlist:Playlist) {
        let controller = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "DetailsScene") as! UINavigationController
        let detailsViewController = controller.viewControllers[0] as! DetailsViewController
        detailsViewController.playlistItemId = playlist.id
        self.tabBarController!.present(controller, animated: true, completion: nil)
    }
}
