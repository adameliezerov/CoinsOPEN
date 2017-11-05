//
//  QRScanViewController.swift
//  Coins
//
//  Created by Jacob Pashman on 7/30/17.
//  Copyright © 2017 Jacob Pashman. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftQRCode
import Firebase
import SCLAlertView

var QRGetUID = String()

class QRScanViewController: UIViewController {

    let scanner = SwiftQRCode()
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
        scanner.prepareScan(view) { (stringValue) -> () in
            print("this is the value: " + stringValue)
            self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                let chars: [Character] = [".", "#", "$","\n","[","]"]
                let newstringvalue = stringValue.stringByRemovingAll(characters: chars)
                print(newstringvalue)
                if snapshot.hasChild(newstringvalue){
                    
                    QRGetUID = stringValue
                    self.performSegue(withIdentifier: "seguetoqrsend", sender: nil)
                    
                }else{
                    SCLAlertView().showError("Error", subTitle: "No such user")
                    self.scanner.startScan()
                }
                
                
            })
        }
       scanner.scanFrame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scanner.startScan()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension String {
    func stringByRemovingAll(characters: [Character]) -> String {
        return String(self.characters.filter({ !characters.contains($0) }))
}

}
