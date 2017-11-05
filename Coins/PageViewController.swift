//
//  PageViewController.swift
//  Coins
//
//  Created by Jacob Pashman on 7/21/17.
//  Copyright © 2017 Jacob Pashman. All rights reserved.
//

import UIKit

class PageViewController : UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    let pages = ["QRScanViewController","ViewController", "SendViewController"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
        setViewControllers([vc!], // Has to be a single item array, unless you're doing double sided stuff I believe
            direction: .forward,
            animated: true,
            completion: nil)
            
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let identifier = viewController.restorationIdentifier {
            if let index = pages.index(of: identifier) {
                if index > 0 {
                    return self.storyboard?.instantiateViewController(withIdentifier: pages[index-1])
                }
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let identifier = viewController.restorationIdentifier {
            if let index = pages.index(of: identifier) {
                if index < pages.count - 1 {
                    return self.storyboard?.instantiateViewController(withIdentifier: pages[index+1])
                }
            }
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        if let identifier = viewControllers?.first?.restorationIdentifier {
//            if let index = pages.index(of: identifier) {
//                return index
//            }
//        }
//        return 0
//    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds // Why? I don't know.
            }
            else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
}
