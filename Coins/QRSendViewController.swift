//
//  QRSendViewController.swift
//  Coins
//
//  Created by Adam on 7/27/17.
//  Copyright © 2017 Adam Eliezerov. All rights reserved.
//

// This is the ready to send QR Send View Controller

import UIKit
import FirebaseAuth
import FirebaseDatabase

class QRSendViewController: UIViewController, SlideButtonDelegate {
    func buttonStatus(status: String, sender: MMSlidingButton) {
        let userID = Auth.auth().currentUser?.uid
        if let amounttosend = Int(coinLabel.text!){
            if amounttosend < 100 {
                //moreErrorLabel.isHidden = true
                //let UserToSend = QRGetUID
                GetCoins()
            }
            else {
                self.slidingMMS.reset()
                maxcoinserror.isHidden = false
                 _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.hideOtherErrors), userInfo: nil, repeats: false)
            }
        }
    
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.slidingMMS.delegate = self
        ref = Database.database().reference()
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        
        self.view.addGestureRecognizer(tapRecognizer)

        // Do any additional setup after loading the view.
    }
    func didTapView(){
        self.view.endEditing(true)
    }
    
    
    func hideOtherErrors() {
        maxcoinserror.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var maxcoinserror: UILabel!
    @IBOutlet weak var notEnoughCoinsError: UILabel!
    @IBOutlet weak var slidingMMS: MMSlidingButton!
    @IBOutlet weak var coinLabel: UITextField!
    var ref: DatabaseReference!
    var OtherUserCoins = Int()
    
    func GetCoins() {
        
        if QRGetUID != Auth.auth().currentUser?.uid {
            ref.child("users").child(QRGetUID).child("Coins").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value
                if snapshot.exists(){
                    self.OtherUserCoins = value as! Int
                    
                    print(self.OtherUserCoins)
                    
                    let amounttosend = Int(self.coinLabel.text!)
                    self.OtherUserCoins += amounttosend!
                    // subtract coins from current user ->
                    let userID = Auth.auth().currentUser?.uid
                    self.ref.child("users").child(userID!
                        ).child("Coins").observeSingleEvent(of: .value, with: { (othersnapshot) in
                            let userID = Auth.auth().currentUser?.uid
                            let othervalue = othersnapshot.value
                            var CurrentUserCoins = othervalue as! Int
                            print(CurrentUserCoins)
                            CurrentUserCoins -= amounttosend!
                            // continue doing this -
                            if CurrentUserCoins < 1{
                                print ("cant")
                                self.slidingMMS.reset()
                                self.notEnoughCoinsError.isHidden = false
                                _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.hideErrors), userInfo: nil, repeats: false)
                            } else {
                                self.ref.child("users").child(userID!).updateChildValues(["Coins":CurrentUserCoins])
                                // add coins to user ->
                                self.ref.child("users").child(QRGetUID).updateChildValues(["Coins":self.OtherUserCoins])
                                self.performSegue(withIdentifier: "seguetomain", sender: nil)
                            }
                            
                        })
                    
                } else {
                    print("User doesn't exist")
                    self.slidingMMS.reset()
                }
                
            }) { (error) in
                print(error.localizedDescription)
                self.slidingMMS.reset()
            }
        }
        else {
            print("cant send money to yourself")
        }
    }
    
    func hideErrors() {
        notEnoughCoinsError.isHidden = true
    }
    

}
