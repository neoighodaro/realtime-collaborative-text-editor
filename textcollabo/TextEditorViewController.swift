//
//  TextEditorViewController.swift
//  textcollabo
//
//  Created by Neo Ighodaro on 15/07/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit
import PusherSwift
import Alamofire

class TextEditorViewController: UIViewController, UITextViewDelegate {
    static let API_ENDPOINT = "http://localhost:4000";

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var charactersLabel: UILabel!
    
    var pusher : Pusher!
    
    var chillPill = true
    
    var placeHolderText = "Start typing..."
    
    var randomUuid : String = ""
    
    
    // ----------------------------------------------------------------------
    // MARK: View Overrides
    // ----------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notification trigger
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Gesture recognizer
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAwayFunction(_:))))

        // Set the controller as the textView delegate
        textView.delegate = self
        
        // Set the device ID
        randomUuid = UIDevice.current.identifierForVendor!.uuidString

        // Listen for changes from Pusher
        listenForChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.textView.text == "" {
            self.textView.text = placeHolderText
            self.textView.textColor = UIColor.lightGray
        }
    }
    
    
    // ----------------------------------------------------------------------
    // MARK: Keyboard Events
    // ----------------------------------------------------------------------

    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.charactersLabel.frame.origin.y == 1.0 {
                self.charactersLabel.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 1.0 {
                self.charactersLabel.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    
    // ----------------------------------------------------------------------
    // MARK: UITextView Delegate
    // ----------------------------------------------------------------------
    
    
    func textViewDidChange(_ textView: UITextView) {
        charactersLabel.text = String(format: "%i Characters", textView.text.characters.count)
        
        if textView.text.characters.count >= 2 {
            sendToPusher(text: textView.text)
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
    
    
    // ----------------------------------------------------------------------
    // MARK: Pusher
    // ----------------------------------------------------------------------
    
    func sendToPusher(text: String) {
        let params: Parameters = ["text": text, "from": randomUuid]
        
        Alamofire.request(TextEditorViewController.API_ENDPOINT + "/update_text", method: .post, parameters: params).validate().responseJSON { response in
            switch response.result {
                
            case .success:
                print("Succeeded")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func listenForChanges() {
        pusher = Pusher(key: "PUSHER_KEY", options: PusherClientOptions(
            host: .cluster("PUSHER_CLUSTER")
        ))
        
        let channel = pusher.subscribe("collabo")
        let _ = channel.bind(eventName: "text_update", callback: { (data: Any?) -> Void in
            
            if let data = data as? [String: AnyObject] {
                let fromDeviceId = data["deviceId"] as! String
                
                if fromDeviceId != self.randomUuid {
                    let text = data["text"] as! String
                    self.textView.text = text
                    self.charactersLabel.text = String(format: "%i Characters", text.characters.count)
                }
            }
        })
        
        pusher.connect()
    }
}
