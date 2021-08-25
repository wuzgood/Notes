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
        fetchNotes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        let note = notes[indexPath.row]
        
        cell.textLabel?.text = note.title

        if note.body == "" {
            cell.detailTextLabel?.text = "Empty note"
        } else {
            cell.detailTextLabel?.text = note.body
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
  
            vc.note = notes[indexPath.row]
            vc.noteDelete = { [weak self] in
                guard let note = self?.notes[indexPath.row] else { return }
                self?.context.delete(note)
                self?.notes.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)

                self?.contextSave()
            }
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
        ac.addTextField { textfield in
            textfield.placeholder = "Title"
        }
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

            self.contextSave()
            
            self.notes.append(newNote)
            let indexPath = IndexPath(row: self.notes.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            
            let note = self.notes[indexPath.row]
            self.context.delete(note)
            
            self.contextSave()
            
            self.notes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func contextSave() {
        do {
            try self.context.save()
        }
        catch {
            print("Saving error.")
        }
    }
}

