//
//  ViewController.swift
//  Notes
//
//  Created by Wuz Good on 29.06.2021.
//

import UIKit

class ViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var notes = [Note]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchNotes()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        
        cell.textLabel?.text = notes[indexPath.row].title

        if notes[indexPath.row].body == "" {
            cell.detailTextLabel?.text = "Empty note"
        } else {
            cell.detailTextLabel?.text = notes[indexPath.row].body
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            vc.noteTitle = notes[indexPath.row].title
            vc.noteBody = notes[indexPath.row].body
            
            vc.note = notes[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setupUI() {
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let createNoteButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNote))
                
        toolbarItems = [spacer, createNoteButton]
    }
    
    func fetchNotes() {
        do {
            self.notes = try context.fetch(Note.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            fatalError("Error fetching data.")
        }
    }
    
    @objc func createNote() {
        let ac = UIAlertController(title: "Create new note:", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let textField = ac.textFields?[0] else { return }
            
            let newNote = Note(context: self.context)
            
            if textField.text == "" {
                newNote.title = "New note"
            } else {
                newNote.title = textField.text
            }

            newNote.body = ""

            do {
                try self.context.save()
            }
            catch {
                fatalError("Saving error.")
            }
            
            self.fetchNotes()
        }))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            
            let note = self.notes[indexPath.row]
            self.context.delete(note)
            
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            self.fetchNotes()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}

