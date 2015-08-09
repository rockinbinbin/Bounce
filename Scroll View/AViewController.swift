//
//  AViewController.swift
//  bubble_ios
//
//  Created by Brendan Lee on 7/23/14.
//  Copyright (c) 2014 Brendan Lee. All rights reserved.
//

import UIKit

class AViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(image: UIImage(named: "Account.png"))
        backgroundImage.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(backgroundImage)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}