//
//  TextEditorViewController.swift
//  textcollabo
//
//  Created by Neo Ighodaro on 15/07/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

class TextEditorViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var collabLabel: UILabel!

    var placeHolderText = "Start typing..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        collabLabel.text = "No Collaborators"
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAwayFunction(_:))))
        
        textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.textView.text == "") {
            self.textView.text = placeHolderText
            self.textView.textColor = UIColor.lightGray
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.collabLabel.frame.origin.y == 1.0 {
                self.collabLabel.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 1.0 {
                self.collabLabel.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.textView.textColor = UIColor.black
        
        if self.textView.text == placeHolderText {
            self.textView.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            self.textView.text = placeHolderText
            self.textView.textColor = UIColor.lightGray
        }
    }
    
    func tappedAwayFunction(_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
    }
}
