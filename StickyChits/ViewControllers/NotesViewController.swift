//
//  NotesViewController.swift
//  StickyChits
//
//  Created by Bala on 28/11/20.
//  Copyright © 2020 Bala. All rights reserved.
//

import UIKit

protocol NotesViewDelegate {
    func saveNotes(title: String, message: String)
}

class NotesViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    
    var chitTitle: String = ""
    var chitMessage: String = ""
    
    @IBOutlet weak var notesTitle: UITextField!
    @IBOutlet weak var notes: UITextView!
    
    var delegate: NotesViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        notesTitle.text = chitTitle
        notes.text = chitMessage
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func closeNotesView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveNotes(_ sender: Any) {
        guard let title = notesTitle.text, !title.isEmpty else {
            print("Title is empty")
            return
        }
        delegate?.saveNotes(title: title, message: notes.text)
        self.navigationController?.popViewController(animated: true)
    }
}
