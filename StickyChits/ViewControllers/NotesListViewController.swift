//
//  NotesListViewController.swift
//  StickyChits
//
//  Created by Bala on 28/11/20.
//  Copyright © 2020 Bala. All rights reserved.
//

import UIKit

import MagicalRecord

class NotesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NotesViewDelegate {
    
    var folderId:   String = ""
    var folderName: String = ""
    var notesInFolder: [Notes] = []
    var selectedNoteKey: String = ""
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var notesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //        print("Folder id is \(folderId)")
        self.navigationItem.title = folderName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAllNotes()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createNote(_ sender: Any) {
        selectedNoteKey = ""
        loadNotesView(notesKey: nil)
    }
    
    fileprivate func loadAllNotes() {
        if let notes = Notes.mr_findAllSorted(by: "updatedTime", ascending: false, with: NSPredicate(format: "active == true AND folderID == %@", folderId)) as? [Notes] {
            //            print("Notes count \(notesInFolder.count)")
            notesInFolder = notes
            notesTableView.reloadData()
        }
    }
    
    func saveNotes(title: String, message: String) {
        //        print("Notes to be saved \(title) and notes \(message)")
        DispatchQueue.main.async {
            let currentTime = Int64(Date().timeIntervalSince1970)
            let noteObj = Notes.mr_findFirstOrCreate(byAttribute: "key", withValue: self.selectedNoteKey)
            
            if self.selectedNoteKey.isEmpty {
                noteObj.createdTime = currentTime
            }
            
            noteObj.updatedTime = currentTime
            
            noteObj.active = true
            noteObj.folderID = self.folderId
            noteObj.key = Utils.shared.randomString(type: "note")
            noteObj.title = title
            noteObj.details = message
            
            NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
            self.loadAllNotes()
        }
    }
    
    func deleteNotes(withKey notesKey: String) {
        DispatchQueue.main.async {
            if let notesObj = Notes.mr_findFirst(byAttribute: "key", withValue: notesKey, in: .mr_default()) {
                notesObj.active = false
                NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
                self.loadAllNotes()
            }
        }
    }
    
    func loadNotesView(notesKey: String?) {
        if let notesView = self.storyboard?.instantiateViewController(withIdentifier: "NotesViewID") as? NotesViewController {
            if let key = notesKey, let notes = Notes.mr_findFirst(byAttribute: "key", withValue: key) {
                notesView.chitTitle = notes.title ?? ""
                notesView.chitMessage = notes.details ?? ""
            }
            notesView.delegate = self
            self.navigationController?.pushViewController(notesView, animated: true)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesInFolder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let notesCell = tableView.dequeueReusableCell(withIdentifier: "NotesCellID") as? NotesCell else {
            return UITableViewCell()
        }
        
        let notesObj = notesInFolder[indexPath.row]
        notesCell.notesTitle?.text = notesObj.title
        return notesCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notes = notesInFolder[indexPath.row]
        loadNotesView(notesKey: notes.key)
        selectedNoteKey = notes.key ?? ""
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let notesObj = notesInFolder[indexPath.row]
        let delete = UITableViewRowAction(style: .normal, title: "Delete", handler: { (_, _) in
            
            tableView.setEditing(false, animated: true)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Delete your StickyChit", style: .destructive, handler: {(_) in
                self.deleteNotes(withKey: notesObj.key ?? "")
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) in
            }))
            
            self.present(alertController, animated: true, completion: nil)
        })
        delete.backgroundColor = UIColor.red
        return [delete]
    }
}

class NotesCell: UITableViewCell {
    @IBOutlet weak var notesTitle: UILabel!
}
