//
//  auiPrefsPageViewController.swift
//  AwareHealth
//
//  Created by Tom Tupper on 1/26/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

protocol dataTransferDelegate {
    func userDidChangeView(data: Int)
    
}

class auiKeyHelperPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    let auiParentView = auiKeyHelperViewController()
    var index: Int = 0
    var proposedViewController: UIViewController?
    var transferDelegate: dataTransferDelegate? = nil
    
    lazy var auiPrefsControllers: [UIViewController] = {
        let mySB = UIStoryboard(name: "Main", bundle: nil)
        let VC1 = mySB.instantiateViewController(withIdentifier: "auiKeyHelperOne")
        let VC2 = mySB.instantiateViewController(withIdentifier: "auiKeyHelperTwo")
        let VC3 = mySB.instantiateViewController(withIdentifier: "auiKeyHelperThree")
        
        return [VC1, VC2, VC3]
        
    }()
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = auiPrefsControllers.index(of: viewController) else {
            return nil
            
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
            
        }
        
        guard auiPrefsControllers.count > previousIndex else {
            return nil
        }
        
        return auiPrefsControllers[previousIndex]
        
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = auiPrefsControllers.index(of: viewController) else {
            return nil
            
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard auiPrefsControllers.count != nextIndex else {
            return nil
            
        }
        
        guard auiPrefsControllers.count > nextIndex else {
            return nil
            
        }
        
        return auiPrefsControllers[nextIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard pendingViewControllers.count == 1,
            let proposedViewController = pendingViewControllers.first else {
                return
        }
        
        guard var index = auiPrefsControllers.index(of: proposedViewController) else {
                return
        }
        
        let vc : Any? = proposedViewController
        
        if (vc == nil) {
            index = 0
        }
        
        if (transferDelegate != nil) {
            let cPage = index
            transferDelegate?.userDidChangeView(data: cPage)
            
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed, let previousIndex = self.auiPrefsControllers.index(of: previousViewControllers[0]) {
            if (transferDelegate != nil) {
                let cPage = previousIndex
                transferDelegate?.userDidChangeView(data: cPage)
                
            }
            
        }
        
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return auiPrefsControllers.count
        
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first, let firstViewControllerIndex = auiPrefsControllers.index(of: firstViewController) else {
            return 0
        }
        
        return firstViewControllerIndex
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        if let VC1 = auiPrefsControllers.first {
            self.setViewControllers([VC1], direction: .forward, animated: true, completion: nil)
            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else {
                view.backgroundColor = UIColor.clear
                
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}
