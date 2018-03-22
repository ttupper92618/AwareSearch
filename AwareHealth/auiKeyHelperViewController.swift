//
//  auiKeyHelperOneViewController.swift
//  AwareHealth
//
//  Created by Tom Tupper on 2/4/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit

class auiKeyHelperViewController: UIViewController, dataTransferDelegate {
    @IBOutlet var auiPrimaryView: UIView!
    @IBOutlet weak var auiSecondaryView: UIView!
    @IBOutlet weak var auiPageViewControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // round the corners
        auiSecondaryView.layer.cornerRadius = 16
        
        // provide a blur
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            auiPrimaryView.insertSubview(blurEffectView, belowSubview: auiSecondaryView)
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func auiDismissKeyHelper(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
    }
    
    func userDidChangeView(data: Int) {
        auiPageViewControl.currentPage = data
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "auiKeyHelperPageViewer" {
            let sendingVC: auiKeyHelperPageViewController = segue.destination as! auiKeyHelperPageViewController
            sendingVC.transferDelegate = self
        }
        
    }

}
