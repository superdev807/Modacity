//
//  PlaylistViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 1/10/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol PlaylistListViewControllerDelegate {
    func playlistViewController(_ controller: PlaylistListViewController, selectedPlaylist: Playlist)
}

class PlaylistListViewController: ModacityParentViewController {

    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var viewNoPlaylist: UIView!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var constraintTableViewBottomSpace: NSLayoutConstraint!
    
    var editingCell: PlaylistCell? = nil
    var singleSelectionMode = false
    var delegate: PlaylistListViewControllerDelegate? = nil
    
    var detailSelection: Playlist!
    var playlists = [Playlist]()
    
    private var test = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in || AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            self.constraintForHeaderImageViewHeight.constant = 70
        } else if AppUtils.sizeModelOfiPhone() == .iphonexR_xSMax {
            self.constraintForHeaderImageViewHeight.constant = 100
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        self.tableViewMain.tableFooterView = UIView()
        self.viewNoPlaylist.isHidden = false
        
        if self.singleSelectionMode {
            self.imageViewIcon.image = UIImage(named: "icon_arrow_left")
            self.constraintTableViewBottomSpace.constant = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Practice Lists"
        self.loadPlaylists()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_details" {
            let controller = (segue.destination as! UINavigationController).viewControllers[0] as! PlaylistContentsViewController
            let model = PlaylistAndPracticeDeliverModel()
            model.deliverPlaylist = self.detailSelection
            controller.parentViewModel = model
        }
    }
    
    @IBAction func onMenu(_ sender: Any) {
        if self.editingCell != nil {
            self.editingCell!.textfieldPlaylistName.resignFirstResponder()
            self.editingCell = nil
        }
        
        if self.singleSelectionMode {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.sideMenuController?.showLeftViewAnimated()
        }
    }
    
}

extension PlaylistListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlists.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell") as! PlaylistCell
        let playlist = self.playlists[indexPath.row]
        cell.configure(with: playlist, isFavorite: playlist.isFavorite)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.singleSelectionMode {
            if let delegate = self.delegate {
                delegate.playlistViewController(self, selectedPlaylist: self.playlists[indexPath.row]/*self.viewModel.playlist(at: indexPath.row)*/)
            }
            self.navigationController?.popViewController(animated: true)
        } else {
            self.detailSelection = self.playlists[indexPath.row]
            ModacityAnalytics.LogEvent(.NewPlaylist, extraParamName: "Playlist", extraParamValue: self.detailSelection!.name)
            self.performSegue(withIdentifier: "sid_details", sender: nil)
        }
    }
}

extension PlaylistListViewController: PlaylistCellDelegate {
    
    func onFavorite(_ playlist: Playlist) {
        playlist.setFavorite(!(playlist.isFavorite))
        if playlist.isFavorite {
            AppOveralDataManager.manager.viewModel?.addFavoriteSession(session: playlist)
        } else {
            AppOveralDataManager.manager.viewModel?.removeFavoriteSession(sessionId: playlist.id)
        }
        self.tableViewMain.reloadData()
    }
    
    func onMenu(_ playlist: Playlist, buttonMenu: UIButton, cell: PlaylistCell) {
        DropdownMenuView.instance.show(in: self.view,
                                       on: buttonMenu,
                                       rows: [["icon":"icon_notes", "text":"Details"],
                                              ["icon":"icon_pen_white", "text": "Rename"],
                                              ["icon":"icon_duplicate", "text":"Duplicate"],
                                              ["icon":"icon_row_delete", "text":"Delete"]]) { (row) in
                                                
                                                if row == 3 {
                                                    self.deletePlaylist(for: playlist)
                                                } else if row == 1 {
                                                    self.rename(on:cell)
                                                } else if row == 0 {
                                                    self.openDetails(playlist)
                                                } else if row == 2 {
                                                    self.duplicatePlaylist(playlist)
                                                }
        }
    }
    
    func onNameEdited(on cell: PlaylistCell, for playlist: Playlist, to changedName: String) {
        if changedName != "" {
            cell.labelPlaylistName.text = cell.textfieldPlaylistName.text
            
            if playlist.name.lowercased() == changedName.lowercased() {
                return
            } else {
                if (PlaylistLocalManager.manager.checkPlaylistNameAvailable(changedName, playlist.id)) {
                    playlist.name = changedName
                    playlist.updateMe()
                } else {
                    cell.labelPlaylistName.text = playlist.name
                    AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Playlist with this name already exists!")
                }
            }
        }
    }
    
    func rename(on cell: PlaylistCell) {
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
    }
    
    func openDetails(_ playlist:Playlist) {
        let controller = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "DetailsScene") as! UINavigationController
        let detailsViewController = controller.viewControllers[0] as! DetailsViewController
        detailsViewController.playlistItemId = playlist.id
        self.tabBarController!.present(controller, animated: true, completion: nil)
    }
    
    func duplicatePlaylist(_ playlist: Playlist) {
        let newPlaylist = Playlist()
        newPlaylist.id = UUID().uuidString
        
        newPlaylist.name = PlaylistLocalManager.manager.availablePlaylistName(from: playlist.name)
        
        newPlaylist.createdAt = "\(Date().timeIntervalSince1970)"
        newPlaylist.playlistPracticeEntries = [PlaylistPracticeEntry]()
        
        for entry in playlist.playlistPracticeEntries {
            let newEntry = PlaylistPracticeEntry()
            newEntry.entryId = UUID().uuidString
            newEntry.practiceItemId = entry.practiceItemId
            newEntry.countDownDuration = entry.countDownDuration
            
            newPlaylist.playlistPracticeEntries.append(newEntry)
        }
        
        newPlaylist.updateMe()
        
        if self.editingCell != nil {
            self.editingCell!.textfieldPlaylistName.resignFirstResponder()
            self.editingCell = nil
        }
        
        var insertingRow = 0
        for row in 0..<self.playlists.count {
            let oldPlaylist = self.playlists[row]
            if playlist.id == oldPlaylist.id {
                self.playlists.insert(newPlaylist, at: row + 1)
                insertingRow = row + 1
                break
            }
        }
        
        self.tableViewMain.reloadData()
        
        let indexPath = IndexPath(row: insertingRow, section: 0)
        self.tableViewMain.scrollToRow(at: indexPath, at: .top, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            if let cell = self.tableViewMain.cellForRow(at: indexPath) as? PlaylistCell {
                self.rename(on: cell)
            } else {
                print("Cell is nil")
            }
        }
    }
    
    func deletePlaylist(for playlist:Playlist) {
        
        let alert = UIAlertController(title: nil, message: "Are you sure to remove this practice list and all reminders for it?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            for row in 0..<self.playlists.count {
                if self.playlists[row].id == playlist.id {
                    self.playlists.remove(at: row)
                    break
                }
            }
            
            self.tableViewMain.reloadData()
            
            DispatchQueue.global(qos: .background).async {
                PlaylistLocalManager.manager.deletePlaylist(playlist)
                PlaylistLocalManager.manager.storePlaylists(self.playlists)
                RemindersManager.manager.removeReminder(forPracticeSessionId: playlist.id)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadPlaylists() {
        let orgPlaylists = PlaylistLocalManager.manager.loadPlaylists() ?? [Playlist]()
        var tempPlaylists = [Playlist]()
        for playlist in orgPlaylists {
            if !playlist.archived {
                tempPlaylists.append(playlist)
            }
        }
        self.playlists = tempPlaylists
        
        if self.playlists.count == 0 {
            self.viewNoPlaylist.isHidden = false
        } else {
            self.viewNoPlaylist.isHidden = true
        }
        self.tableViewMain.reloadData()
    }
}
