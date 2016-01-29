//
//  UserSetup.swift
//  UniQ
//
//  Created by Julius Estrada on 29/01/2016.
//  Copyright © 2016 JABE Labs. All rights reserved.
//

import UIKit

class UserSetup: UIViewController {
    override func viewDidLoad() {
        var saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain,
            target: self, action: "onSaveTapped")
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    func onSaveTapped(){
        print("save tapped")
    }
}
