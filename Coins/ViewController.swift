//
//  ViewController.swift
//  Coin
//
//  Created by Adam Eliezerov on 7/2/17.
//  Copyright © 2017 Adam Eliezerov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import QRCode
import CoreTelephony
import SACountingLabel
import SCLAlertView

var inviteCode = String()

class ViewController: UIViewController {
    var ref: DatabaseReference!
    
    @IBOutlet weak var CoinCount: SACountingLabel!
    
    
    
    var ContactsArray = [[String:AnyObject]]()
    func hideNoConnectionError() {
        noconnectionerror.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            // do nothing in this case
            // changed these things to be here instead of being outside Reachability.isConnectedToNetwork()
            ref = Database.database().reference()
            if let userID = Auth.auth().currentUser?.uid {
                ref.child("users").child(userID).child("InviteCode").observeSingleEvent(of: .value, with: { (snapshot) in
                    inviteCode = snapshot.value as! String
                })
            }
            
            let tapRecognizer = UITapGestureRecognizer()
            tapRecognizer.addTarget(self, action: #selector(ViewController.didTapView))
            self.view.addGestureRecognizer(tapRecognizer)
            let userID = Auth.auth().currentUser!.uid
            _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(GetCoins), userInfo: nil, repeats: true)
            _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(pushDeviceToken), userInfo: nil, repeats: false)
            GetCoinsFirstTime()
        } else{
            print("Internet Connection not Available!")
            SCLAlertView().showError("No internet connection", subTitle: "Try again later...")
            // things are not going to load...
        }
        
        
        
        
        
        
        //end of viewdidload()
    }
    // push device token to Firebase Database
    func pushDeviceToken() {
        print(userDeviceToken)
        if let userID = Auth.auth().currentUser?.uid{
            ref.child("users/\(userID)").updateChildValues(["deviceToken": userDeviceToken])
        }
    }
    @IBOutlet weak var noconnectionerror: UILabel!

    var numofcoins = Float()
    // Get number of Coins from the database for the first time...
    @objc func GetCoinsFirstTime() {
        if let userID = Auth.auth().currentUser?.uid {
            ref.child("users").child(userID).child("Coins").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value
            //let newnum = NSString(format: "%@", value as! CVarArg) as Float
            let newnum = value as! Float
            self.numofcoins = newnum
            self.CoinCount.countFrom(fromValue: 0, to: newnum, withDuration: 1.0, andAnimationType: .EaseOut, andCountingType: .Int)
        }) { (error) in
            print(error.localizedDescription)
        }
        }
    }
    
    var newnum1 = Float()
    // use this function every time to get the Coins after the first time (GetCoinsFirstTime())
    @objc func GetCoins() {
        if let userID = Auth.auth().currentUser?.uid{
            ref.child("users").child(userID).child("Coins").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value
            //let newnum = NSString(format: "%@", value as! CVarArg) as Float
            let newnum = value as? Float
            self.newnum1 = newnum!
            self.CoinCount.countFrom(fromValue: self.numofcoins, to: newnum!, withDuration: 1.0, andAnimationType: .EaseOut, andCountingType: .Int)
            self.numofcoins = newnum!
        }) { (error) in
            print(error.localizedDescription)
        }
//            if inviteCode == nil{
//            }else{
//            ref.child("users").child(userID).child(inviteCode).observeSingleEvent(of: .value, with: { (snapshotinvite) in
//                let value = snapshotinvite.value
//                if value as! String == "used" {
//                    print("adding 10 coins and settings inviteCode as unused")
//                    self.self.ref.child("users").child(userID).updateChildValues(["Coins" : self.newnum1 + 10])
//                }
//            })
//            }
        } else{
            
        }
        
    }
    
    @objc func didTapView(){
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var imageView: UIImageView!  // user QR code image
    
    override func viewDidAppear(_ animated: Bool) {
        //intro animation
        
        let isFirstLaunch = UserDefaults.isFirstLaunch()
        if isFirstLaunch {
            let screenOutline = UIImageView(image:UIImage(named: "screenOutlne"))
            screenOutline.frame = view.frame
            view.addSubview(screenOutline)
            UIView.animate(withDuration: 5.0, animations: {() -> Void in
                screenOutline.transform = CGAffineTransform(scaleX: 3.8, y: 3.8)
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 5.0, animations: {() -> Void in
                    screenOutline.isHidden = true
                    //UserDefaults.standard.set(true, forKey: "notFirstLaunch")
                    print("first launch")
                })
            })
        } else {
            print("not first launch")
        }
        
        
        
        let url1 = Auth.auth().currentUser!.uid
        //print(url1) // remove this no need to print uid more than once

        var qrCode = QRCode(url1)
        qrCode?.color = CIColor(red:0.34, green:0.69, blue:0.54, alpha:1.0)
        qrCode?.backgroundColor = CIColor(red:0.11, green: 0.12, blue:0.14, alpha:1.0)
        //qrCode?.backgroundColor = CIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
        imageView.image = qrCode?.image
        let userID = Auth.auth().currentUser?.uid
        // update this to work - transactions
//        ref.child("users").child(userID!).child("Transactions").observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let values = snapshot.value as? NSDictionary
//            for (key, value) in values! {
//                self.items.append(value as! String)
//            }
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//        _ = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(reloadtransactions), userInfo: nil, repeats: false)
    }
    
//    func reloadtransactions() {
//        collectionview.reloadData()
////        for v in items {
////            print(v)
////        }
//    }
//
//    @IBOutlet weak var collectionview: UICollectionView!
//
//
//    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
//    var items = ["John Smith","+4"]
//
//
//    // MARK: - UICollectionViewDataSource protocol
//
//    // tell the collection view how many cells to make
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.items.count
//    }
//
//    // make a cell for each cell index path
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        // get a reference to our storyboard cell
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! LedgerCollectionViewCell
//
//        // Use the outlet in our custom class to get a reference to the UILabel in the cell
//        cell.myLabel.text = self.items[indexPath.item]
//        //  cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
//
//        if cell.myLabel.text![0] == "+" {
//            cell.myLabel.textColor = UIColor(red:0.02, green:0.69, blue:0.00, alpha:1.0)
//            cell.myLabel.textAlignment = .right
//        } else if cell.myLabel.text![0] == "-" {
//            cell.myLabel.textColor = UIColor(red:0.69, green:0.05, blue:0.00, alpha:1.0)
//            cell.myLabel.textAlignment = .right
//        } else {
//            cell.myLabel.textColor = UIColor.white
//            cell.myLabel.textAlignment = .left
//        }
//
//        return cell
//    }
//
//    // MARK: - UICollectionViewDelegate protocol
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        // handle tap events
//        print("You selected cell #\(indexPath.item)!")
//    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[Range(start ..< end)]
    }
}

extension UserDefaults {
    // check for is first launch - only true on first invocation after app install, false on all further invocations
    // Note: Store this value in AppDelegate if you have multiple places where you are checking for this flag
    static func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}
