//
//  LoadingPanelView.swift
//  Modacity
//
//  Created by Benjamin Chris on 30/8/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class LoadingPanelView: UIView {
    
    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var tableViewList: UITableView!
    
    var statusLabels = ["Playlist loaded..."]
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("LoadingPanelView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.tableViewList.register(UINib(nibName: "LoadingStatusCell", bundle: nil), forCellReuseIdentifier: "LoadingStatusCell")
        self.tableViewList.tableFooterView = UIView()
        self.tableViewList.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        self.show()
        
    }
    
    func show() {
        self.statusLabels = SyncStatusKeeper.keeper.statusLabels
        self.tableViewList.reloadData()
    }
}

extension LoadingPanelView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statusLabels.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingStatusCell") as! LoadingStatusCell
        cell.labelStatus.text = self.statusLabels[indexPath.row]
        cell.transform = tableView.transform
        return cell
    }
}
