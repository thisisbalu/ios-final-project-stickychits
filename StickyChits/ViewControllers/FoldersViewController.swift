//
//  FoldersViewController.swift
//  StickyChits
//
//  Created by Bala on 27/11/20.
//  Copyright © 2020 Bala. All rights reserved.
//

import UIKit

import MagicalRecord

class FoldersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var foldersTableView: UITableView!
    
    var allFolders: [Folder] = []
    var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFolders()
    }
    
    fileprivate func loadFolders() {
        
        if let folders = Folder.mr_findAllSorted(by: "updatedTime", ascending: false, with: NSPredicate(format: "active == true")) as? [Folder] {
//            print("Folders count \(folders.count)")
            allFolders = folders
            foldersTableView.reloadData()
        }
    }
    
    @IBAction func addFolderBtn(_ sender: Any) {
        alert = UIAlertController(title: "Create Folder", message: "Enter folder name", preferredStyle: UIAlertController.Style.alert)
        let saveAction = UIAlertAction(title: "Create", style: .default) { (alertAction) in
            let textField = (self.alert!.textFields?[0])! as UITextField
            self.saveFolder(with: textField.text ?? "")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (alertAction) in
            
        }
        alert?.addTextField { (textField) in
            textField.placeholder = "Enter folder name"
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        }
        
        saveAction.isEnabled = false
        alert?.addAction(saveAction)
        alert?.addAction(cancelAction)
        self.present(alert!, animated: true, completion: nil)
    }
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[0].isEnabled = sender.text!.count > 0
    }
    
    func saveFolder(with name: String) {
        DispatchQueue.main.async {
            //        print(" saveFolder Value in database \(name)")
            let currentTime = Int64(Date().timeIntervalSince1970)
            let folderObj = Folder.mr_createEntity(in: .mr_default())
            
            folderObj?.key = Utils.shared.randomString(type: "fold")
            folderObj?.active = true
            folderObj?.name = name
            
            folderObj?.createdTime = currentTime
            folderObj?.updatedTime = currentTime
            folderObj?.notesIds = ""
            
            NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
            self.loadFolders()
        }
    }
    
    func deleteFolder(withKey folderKey: String) {
        DispatchQueue.main.async {
            if let folderObj = Folder.mr_findFirst(byAttribute: "key", withValue: folderKey, in: .mr_default()) {
                folderObj.active = false
                NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
                self.loadFolders()
            }
        }
    }
    
    // MARK: TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFolders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let folderCell = tableView.dequeueReusableCell(withIdentifier: "FolderCellID") as? FolderCell else {
            return UITableViewCell()
        }
        
        let folderObj = allFolders[indexPath.row]
        folderCell.folderName?.text = folderObj.name
        return folderCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let folderObj = allFolders[indexPath.row]
        if let folderKey = folderObj.key, let notesListView = self.storyboard?.instantiateViewController(withIdentifier: "NotesListViewID") as? NotesListViewController {
            notesListView.folderId = folderKey
            notesListView.folderName = folderObj.name ?? ""
            self.navigationController?.pushViewController(notesListView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let folderObj = allFolders[indexPath.row]
        let delete = UITableViewRowAction(style: .normal, title: "Delete", handler: { (_, _) in
            
            tableView.setEditing(false, animated: true)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Delete Folder", style: .destructive, handler: {(_) in
                self.deleteFolder(withKey: folderObj.key ?? "")
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) in
            }))
            
            self.present(alertController, animated: true, completion: nil)
        })
        delete.backgroundColor = UIColor.red
        return [delete]
    }
}

class FolderCell: UITableViewCell {
    @IBOutlet weak var folderName: UILabel!
}
