//
//  SplashViewController.swift
//  BoutTime
//
//  Created by nikko444 on 2019-02-13.
//  Copyright © 2019 nikko444. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
            self.performSegue(withIdentifier: "splashToGame", sender: self)
        })
    }


}

