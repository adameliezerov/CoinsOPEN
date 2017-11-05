//
//  VerifyViewController.swift
//  Coins
//
//  Created by Adam on 7/20/17.
//  Copyright © 2017 Jacob Pashman. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import FirebaseRemoteConfig
import SCLAlertView

class VerifyViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notvalidinvitelabel.isHidden = true
        activityindicator.isHidden = true
        ref = Database.database().reference()
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(ViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        // Do any additional setup after loading the view.
        inviteCodeInputed = "nil"
        smscodeinvalidlabel.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didTapView(){
        self.view.endEditing(true)
//        PhoneAuthProvider.provider().verifyPhoneNumber("", completion: { (verificationID, error) in
//            if error != nil{
//                print(error?.localizedDescription)
//            } else {
//                 UserDefaults.standard.set(verificationID, forKey: "AuthVID")
//            }
//        })
       
    }
    
    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var smscodeinvalidlabel: UILabel!
    
    var signupcoins = Int()
    
    @IBAction func Login(_ sender: Any) {
        let defaults = UserDefaults.standard
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "AuthVID")!, verificationCode: code.text!)
        Auth.auth().signIn(with: credential) { (user, error ) in
            self.self.activityindicator.isHidden = false
            self.activityindicator.startAnimating()
            if error != nil {
                print(error?.localizedDescription)
                self.smscodeinvalidlabel.isHidden = false
                // show error
                //stop animating activity indicator
                self.activityindicator.isHidden = true
            }else {
                let phoneNumber = user?.phoneNumber
                let userInfo = user?.providerData[0]
                print("Provider ID: \(String(describing: userInfo?.providerID))")
//                let userID = Auth.auth().currentUser!.uid
                    self.ref.child("users").observeSingleEvent(of: .value, with: {(snap) in
                        if snap.hasChild((user?.uid)!){
                            // User exists
                            self.performSegue(withIdentifier: "segue2", sender: Any?.self)
                        }else{
                            
                            // New User
                            self.ref.child("Promo").observeSingleEvent(of: .value, with: { (snapshot) in
                                // Get user value
                                let value = snapshot.value as? NSDictionary
                                if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
                                    if countryCode == "US"{
                                        self.signupcoins = value?["SignUpUS"] as? Int ?? 3
                                        print(self.signupcoins)
                                    } else {
                                        self.signupcoins = value?["SignUpIL"] as? Int ?? 10
                                        print(self.signupcoins)
                                    }
                                    
                                }
                                let inviteCode = randomStringWithLength(len: 6)
                                if self.inviteCodeInputed == "nil"{
                                    self.ref.child("codes").updateChildValues([inviteCode:(user?.uid)!])
                                    self.ref.child("users").child((user?.uid)!).setValue(["Coins": self.signupcoins, "PhoneNumber":phoneNumber,"InviteCode":inviteCode])
                                    self.performSegue(withIdentifier: "segue2", sender: Any?.self)
                                } else {
                                    self.ref.child("codes").observeSingleEvent(of: .value, with: { (snapinvitecode) in
                                        if snapinvitecode.hasChild(self.inviteCodeInputed) {
                                            self.notvalidinvitelabel.isHidden = true
                                            
                                            self.ref.child("users").child(snapinvitecode.childSnapshot(forPath: self.inviteCodeInputed).value as! String).child("Coins").observeSingleEvent(of: .value, with: { (snapshot1) in
                                                let newnum = snapshot1.value as! Int
                                                self.ref.child("users").child(snapinvitecode.childSnapshot(forPath: self.inviteCodeInputed).value as! String).updateChildValues(["Coins":newnum + 10])
                                            })
                                            self.ref.child("codes").updateChildValues([inviteCode:(user?.uid)!])
                                            let newCoins = self.signupcoins + 10
                                            self.ref.child("users").child((user?.uid)!).setValue(["Coins": newCoins, "PhoneNumber":phoneNumber,"InviteCode":inviteCode])
                                            self.performSegue(withIdentifier: "segue2", sender: Any?.self)
                                        }else{
                                            print("invite code doesn't exist")
                                            self.notvalidinvitelabel.isHidden = false
                                            self.activityindicator.isHidden = true
                                        }
                                    })
                                    // add coins if invite code exists
                                    
                                    
//                                    self.ref.child("users").child((user?.uid)!).setValue(["Coins": self.signupcoins, "PhoneNumber":phoneNumber,"InviteCode":inviteCode])
//                                    self.performSegue(withIdentifier: "segue2", sender: Any?.self)
                                }
                                
                                
                                // ...
                            }) { (error) in
                                print(error.localizedDescription)
                            }
                            
                        }
                    })

            }
        }
    }
    
    
    var inviteCodeInputed = String()
    
    @IBAction func invitecodebtn(_ sender: Any) {
        //1. Create the alert controller.
        
        let appearance = SCLAlertView.SCLAppearance(
            kCircleIconHeight: CGFloat(40), kWindowWidth: CGFloat(300), showCircularIcon: true
        )
        let alertViewIcon = UIImage(named: "inviteIcon")
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField("Enter an Invite Code")
        alert.addButton("Continue") {
            let textinvite = txt.text
            if (textinvite?.characters.count)! < 7 {
                print("continuing")
                self.inviteCodeInputed = textinvite!
            }
            else {
                print("No more than 6 characters, invalid")
            }
        }
        alert.showSuccess("Enter an invite code", subTitle: "to get 10 free coins!", closeButtonTitle:"Cancel", circleIconImage: alertViewIcon)
        
        //alertViewResponder.close() // Close view
        
//        let alert = UIAlertController(title: "Enter your friend's invite code", message: "to give you and them 10 free coins each!", preferredStyle: .alert)
//
//
//
//
//        //2. Add the text field. You can configure it however you need.
//        alert.addTextField { (textField) in
//            textField.borderStyle = UITextBorderStyle.none
//
//        }
//        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
//        }))
//        // 3. Grab the value from the text field, and print it when the user clicks OK.
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
//            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
//            print("Text field: \(textField?.text)")
//            let textinvite = textField?.text
//            if (textinvite?.characters.count)! < 7 {
//                print("continuing")
//                self.inviteCodeInputed = textinvite!
//            }
//            else {
//                print("No more than 6 characters, invalid")
//            }
//        }))
//
        
        // 4. Present the alert.
        //self.present(alert, animated: true, completion: nil)
    }
    @IBOutlet weak var notvalidinvitelabel: UILabel!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

func randomStringWithLength(len: Int) -> NSString {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for _ in 1...len{
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    
    return randomString
}
