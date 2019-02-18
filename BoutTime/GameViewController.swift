//
//  GameViewController.swift
//  BoutTime
//
//  Created by nikko444 on 2019-02-14.
//  Copyright © 2019 nikko444. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet var factRowViews: [UIView]!
    @IBOutlet weak var firstRowLabel: UILabel!
    @IBOutlet weak var secondRowLabel: UILabel!
    @IBOutlet weak var thirdRowLabel: UILabel!
    @IBOutlet weak var fourthRowLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var firstRowDownButton: UIButton!
    @IBOutlet weak var secondRowUpButton: UIButton!
    @IBOutlet weak var secondRowDownButton: UIButton!
    @IBOutlet weak var thirdRowUpButton: UIButton!
    @IBOutlet weak var thirdRowDownButton: UIButton!
    @IBOutlet weak var fourthRowUpButton: UIButton!
    @IBOutlet weak var controlButton: UIButton!
    
    var quizGame: QuizGame?
    var buttonsHandler: QuizGameButtonsHandler?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func becomeFirstResponder() -> Bool { //MARK: Overriden to implement shake gesture listener
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) { //MARK: Overriden to implement shake gesture listener
        if motion == .motionShake {
            quizGame?.shakeAction()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonsHandler = AerospaceQuizButtonsHandler(orderButtons: [firstRowDownButton,
                                                                        secondRowUpButton,
                                                                        secondRowDownButton,
                                                                        thirdRowUpButton,
                                                                        thirdRowDownButton,
                                                                        fourthRowUpButton],
                                                          controlButton: controlButton)
        guard let buttonsHandler = buttonsHandler else {
            fatalError("Buttons Handler couldn't be initialized")
        }
        do {
            let dictionary = try PlistConverter.dictionary(fromFile: "aerospaceDiscoveryQuizFacts", ofType: "plist")
            let facts = try FactsUnarchiver.fetch(fromDictionary: dictionary)
            self.quizGame = AerospaceQuizGame(facts: facts,
                                              firstRowFactLabel: firstRowLabel,
                                              secondRowFactLabel: secondRowLabel,
                                              thirdRowFactLabel: thirdRowLabel,
                                              fourthRowFactLabel: fourthRowLabel,
                                              timerLabel: timerLabel,
                                              buttonsHandler: buttonsHandler)
        } catch let error {
            fatalError("\(error)")
        }
        
        
        self.setOptionButtonsTags() // Setting Button tags, matching Enums for easier handling through the enum
        self.setViewRoundCorners()
        quizGame?.setQuizRound()
    }
    
    @IBAction func orderButtonPressed(_ sender: UIButton) {
        quizGame?.moveFact(sender)
    }
    
    @IBAction func controlButtonPressed() {
        quizGame?.setQuizRound()
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
    
    private func setViewRoundCorners () {
        for factRowView in factRowViews {
            factRowView.layer.cornerRadius = 5
            factRowView.layer.masksToBounds = true
        }
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
