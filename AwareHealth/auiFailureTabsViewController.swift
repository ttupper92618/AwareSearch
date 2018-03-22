//
//  auiFailureTabsViewController.swift
//  AwareHealth
//
//  Created by Tom Tupper on 2/8/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit

class auiFailureTabsViewController: UITabBarController {

    @IBOutlet weak var auiTabBar: UITabBar!
    
    override func viewDidLoad() {
        print(auiLoadErrorState)
        super.viewDidLoad()
        self.selectedIndex = auiLoadErrorState
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view appeared")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func changeViewIndex(viewToShow: String) {
        print(viewToShow)
        
        // guard let items = self.tabBar.items else { return }
        
        print(auiTabBar)
        
    }

}
