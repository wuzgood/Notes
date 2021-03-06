//
//  DetailViewController.swift
//  Notes
//
//  Created by Wuz Good on 29.06.2021.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    var note: Note?
    var noteDelete: (() -> Void)?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextView()
    }
    
    func setupTextView() {
        title = note?.title
        navigationItem.largeTitleDisplayMode = .never
        
        let rename = UIBarButtonItem(title: "Rename", style: .plain, target: self, action: #selector(renameTapped))
        navigationItem.setRightBarButton(rename, animated: true)
        
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped))
        let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
        setToolbarItems([share, spacer, delete], animated: true)
        
        textView.text = note?.body
        
        autoSaving()
    }
    
    func autoSaving() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveNote), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveNote), name: UIApplication.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func saveNote() {
        do {
            note?.body = textView.text
            
            try context.save()
        }
        catch {
            fatalError("Error saving note.")
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    @objc func renameTapped() {
        let ac = UIAlertController(title: "Rename note title", message: nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.text = self.note?.title
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let text = ac.textFields?[0].text else { return }
            self.note?.title = text
            self.title = text
            
            self.saveNote()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func shareTapped() {
        guard let noteBody = note?.body else { return }
        let ac = UIActivityViewController(activityItems: [noteBody], applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @objc func deleteTapped() {
        let ac = UIAlertController(title: "Delete this note?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "No", style: .cancel))
        ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
            self?.noteDelete?()
        }))
        present(ac, animated: true)
    }
}
