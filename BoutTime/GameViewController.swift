//
//  GameViewController.swift
//  BoutTime
//
//  Created by nikko444 on 2019-02-14.
//  Copyright © 2019 nikko444. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var firstRowLabel: UILabel!
    @IBOutlet weak var secondRowLabel: UILabel!
    @IBOutlet weak var thirdRowLabel: UILabel!
    @IBOutlet weak var fourthRowLabel: UILabel!
    
    @IBOutlet weak var firstRowDownButton: UIButton!
    @IBOutlet weak var secondRowUpButton: UIButton!
    @IBOutlet weak var secondRowDownButton: UIButton!
    @IBOutlet weak var thirdRowUpButton: UIButton!
    @IBOutlet weak var thirdRowDownButton: UIButton!
    @IBOutlet weak var fourthRowUpButton: UIButton!
    
    let quizGame: QuizGame
    var orderButtonsHandler: QuizGameOrderButtonsHandler?
    
    required init?(coder aDecoder: NSCoder) {
        do {
           let dictionary = try PlistConverter.dictionary(fromFile: "aerospaceDiscoveryQuizFacts", ofType: "plist")
           let facts = try FactsUnarchiver.fetch(fromDictionary: dictionary)
            self.quizGame = AerospaceQuizGame(facts: facts)
        } catch let error {
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quizGame.setLabels(firstRowFactLabel: firstRowLabel,
                           secondRowFactLabel: secondRowLabel,
                           thirdRowFactLabel: thirdRowLabel,
                           fourthRowFactLabel: fourthRowLabel)
        self.orderButtonsHandler = AerospaceQuizOrderButtonsHandler(buttons: [firstRowDownButton,
                                                                              secondRowUpButton,
                                                                              secondRowDownButton,
                                                                              thirdRowUpButton,
                                                                              thirdRowDownButton,
                                                                              fourthRowUpButton])
        self.setOptionButtonsTags() // Setting Button tags, matching Enums for easier handling through the enum
        quizGame.setQuizRound()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func orderButtonPressed(_ sender: UIButton) {
        quizGame.updateScreen()
    }
    
    // MARK: - Helper methods
    
    private func setOptionButtonsTags () {
        firstRowDownButton.tag = OrderChangeButton.firstDown.rawValue
        secondRowUpButton.tag = OrderChangeButton.secondUp.rawValue
        secondRowDownButton.tag = OrderChangeButton.secondDown.rawValue
        thirdRowUpButton.tag = OrderChangeButton.thirdUp.rawValue
        thirdRowDownButton.tag = OrderChangeButton.thirdDown.rawValue
        fourthRowUpButton.tag = OrderChangeButton.fourthUp.rawValue
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
