//
//  PlaylistDetailsViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/28/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class  PlaylistPracticeItem: UITableViewCell {
    
    @IBOutlet weak var labelPracticeName: UILabel!
    
}

class PlaylistDetailsViewController: UIViewController {

    @IBOutlet weak var labelPlaylistName: UILabel!
    @IBOutlet weak var textfieldPlaylistName: UITextField!
    @IBOutlet weak var buttonEditName: UIButton!
    @IBOutlet weak var tableViewMain: UITableView!
    
    var isNameEditing = false
    
    var viewModel = PlaylistDetailsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableViewMain.tableFooterView = UIView()
        self.bindViewModel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_select_practice_item" {
            let controller = segue.destination as! PracticeItemListViewController
            controller.parentViewModel = self.viewModel
        }
    }

    @IBAction func onBack(_ sender: Any) {
        if self.navigationController?.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onEditName(_ sender: Any) {
        self.changeNameEditMode()
    }
    
    @IBAction func onDidEndOnExitOnNameInputField(_ sender: Any) {
        self.changeNameEditMode()
    }
    
    @IBAction func onEditingChangedOnNameInputField(_ sender: Any) {
        self.viewModel.playlistName = self.textfieldPlaylistName.text ?? ""
    }
    
    func changeNameEditMode() {
        isNameEditing = !isNameEditing
        if isNameEditing {
            self.labelPlaylistName.isHidden = true
            self.textfieldPlaylistName.isHidden = false
            self.textfieldPlaylistName.becomeFirstResponder()
            self.buttonEditName.setImage(UIImage(named:"icon_done"), for: .normal)
        } else {
            self.labelPlaylistName.isHidden = false
            self.textfieldPlaylistName.isHidden = true
            self.textfieldPlaylistName.resignFirstResponder()
            self.buttonEditName.setImage(UIImage(named:"icon_pen_white"), for: .normal)
        }
    }
    
    func bindViewModel() {
        self.viewModel.subscribe(to: "playlistName") { (_, _, newValue) in
            self.labelPlaylistName.text = newValue as? String ?? ""
        }
        
        self.viewModel.subscribe(to: "practiceItems") { (_, _, _) in
            self.tableViewMain.reloadData()
        }
    }
}

extension PlaylistDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.practiceItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistPracticeItem") as! PlaylistPracticeItem
        cell.labelPracticeName.text = self.viewModel.practiceItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
