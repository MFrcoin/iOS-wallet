//
//  DiffPhraseViewController.swift
//  MFCoin
//
//  Created by Admin on 07.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class DiffPhraseViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var phraseTextView: UITextView!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    let manager = KitManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = Constants.CORNER_RADIUS
        phraseTextView.delegate = self
        errorLabel.text = ""
        phraseTextView.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        underLineView.backgroundColor = .clear
    }
    
    @IBAction func goForward(_ sender: UIButton) {
        guard let metaPhrase = DAKeychain.shared["mnemonic"] else { return }
        print (metaPhrase)
        guard let phrase = phraseTextView.text else {
            errorLabel.text = "Please, enter recovery phrase"
            return }
        if phrase == "" {
            errorLabel.text = "Please, enter recovery phrase"
        }
        if manager.diffWords(words: phrase) {
            print ("metaPhrase \(metaPhrase)")
            print ("phrase \(phrase)")
            errorLabel.text = "Phrases is different"
        } else {
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "setPass") as! SetPasswordViewController
            show(vc, sender: sender)
        }
        
    }
  
    @IBAction func skipForward(_ sender: UIButton) {
        let message = """
        Please make sure that your recovery phrase matches the following:

        \(manager.getWords())

        It is recommended not to skip verification, so that any misspellings could be detected.
"""
        
        let alert = UIAlertController.init(title: "Skipping verification", message: message, preferredStyle: .alert)
        let alertActionOk = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let alertActionSkip = UIAlertAction.init(title: "Skip", style: .default, handler: { (alert) in
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "setPass") as! SetPasswordViewController
            self.show(vc, sender: sender)
        })
        alert.addAction(alertActionOk)
        alert.addAction(alertActionSkip)
        self.present(alert, animated: true, completion: nil)
    }
    


    func textViewDidBeginEditing(_ textView: UITextView) {
        underLineView.backgroundColor = Constants.BLUECOLOR
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        underLineView.backgroundColor = .clear
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
