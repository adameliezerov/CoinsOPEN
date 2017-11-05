//
//  ShareViewController.swift
//  Coins
//
//  Created by Jacob Pashman on 8/3/17.
//  Copyright © 2017 Jacob Pashman. All rights reserved.
//

import UIKit
import Firebase

class ShareViewController: UIViewController {

    var ref: DatabaseReference!
    
    @IBAction func shareButton(_ sender: Any) {
        
        // maybe take out the emoji if not we should add 😍
        let firstActivityItem = "You should check out Coin 🤑.\n  When signing up for the first time use this code: \(inviteCode)"
                let secondActivityItem : NSURL = NSURL(string: "https://coinreserve.xyz")!
        // If you want to put an image
        //
        //let image : UIImage = UIImage(named: "image.jpg")!

        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem], applicationActivities: nil)

        // This lines is for the popover you need to show in iPad
//        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)

        // This line remove the arrow of the popover to show in iPad
        //activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.allZeros
       // activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]

        self.present(activityViewController, animated: true, completion: nil)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        inviteCodeLabel.text = inviteCode
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var inviteCodeLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        
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
