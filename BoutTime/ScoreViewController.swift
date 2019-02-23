//
//  ScoreViewController.swift
//  BoutTime
//
//  Created by nikko444 on 2019-02-21.
//  Copyright © 2019 nikko444. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    var scoreString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = scoreString

    }
    
    @IBAction func playAgain() {
        self.performSegue(withIdentifier: "scoreToGame", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
