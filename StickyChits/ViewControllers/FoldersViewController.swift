//
//  FoldersViewController.swift
//  StickyChits
//
//  Created by Bala on 27/11/20.
//  Copyright © 2020 Bala. All rights reserved.
//

import UIKit

import CoreData

class FoldersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var foldersTableView: UITableView!
    
    var allFolders: [Folder] = []
    var alert: UIAlertController?
    
    let managedContext = CoreDataHelper().persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFolders()
    }
    
    fileprivate func loadFolders() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Folder")
        request.predicate = NSPredicate(format: "active == true")
        let sortDescriptor = NSSortDescriptor(key: "updatedTime", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.returnsObjectsAsFaults = false
        do {
            if let result = try managedContext.fetch(request) as? [Folder] {
                allFolders = result
                foldersTableView.reloadData()
            }
        } catch {
            print("Failed")
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
//            print(" saveFolder Value in database \(name)")
            
            // Create Entity
            guard let folderEntity = NSEntityDescription.entity(forEntityName: "Folder", in: self.managedContext) else {
                return
            }
            
            let folderObj = Folder(entity: folderEntity, insertInto: self.managedContext)
            
            let currentTime = Int64(Date().timeIntervalSince1970)
            
            folderObj.key = Utils.shared.randomString(type: "fold")
            folderObj.active = true
            folderObj.name = name
            
            folderObj.createdTime = currentTime
            folderObj.updatedTime = currentTime
            folderObj.notesIds = ""
            
            self.saveAndReload()
        }
    }
    
    func deleteFolder(withKey folderKey: String) {
        DispatchQueue.main.async {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Folder")
            request.predicate = NSPredicate(format: "key == %@", folderKey)
            request.returnsObjectsAsFaults = false
            do {
                if let folderObj = try self.managedContext.fetch(request).first as? Folder {
                    folderObj.active = false
                    self.saveAndReload()
                }
            } catch {
                print("Failed")
            }
        }
    }
    
    func saveAndReload() {
        do {
            try self.managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        self.loadFolders()
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
