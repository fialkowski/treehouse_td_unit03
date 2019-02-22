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
    @IBOutlet weak var firstRowFactButton: UIButton!
    @IBOutlet weak var secondRowFactButton: UIButton!
    @IBOutlet weak var thirdRowFactButton: UIButton!
    @IBOutlet weak var fourthRowFactButton: UIButton!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var shakeToCompleteLabel: UILabel!
    
    @IBOutlet weak var firstRowDownButton: UIButton!
    @IBOutlet weak var secondRowUpButton: UIButton!
    @IBOutlet weak var secondRowDownButton: UIButton!
    @IBOutlet weak var thirdRowUpButton: UIButton!
    @IBOutlet weak var thirdRowDownButton: UIButton!
    @IBOutlet weak var fourthRowUpButton: UIButton!
    @IBOutlet weak var controlButton: UIButton!
    
    var senderFactButton: UIButton?
    var quizGame: QuizGame?
    var buttonsHandler: QuizGameButtonsHandler?
    var numberOfRounds: Int = 3

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
                                                          controlButton: controlButton,
                                                          firstRowFact: firstRowFactButton,
                                                          secondRowFact: secondRowFactButton,
                                                          thirdRowFact: thirdRowFactButton,
                                                          fourthRowFact: fourthRowFactButton)
        guard let buttonsHandler = buttonsHandler else {
            fatalError("Buttons Handler couldn't be initialized")
        }
        do {
            let dictionary = try PlistConverter.dictionary(fromFile: "aerospaceDiscoveryQuizFacts", ofType: "plist")
            let facts = try FactsUnarchiver.fetch(fromDictionary: dictionary)
            self.quizGame = AerospaceQuizGame(gameViewController: self,
                                              facts: facts,
                                              timerLabel: timerLabel,
                                              shakeLabel: shakeToCompleteLabel,
                                              buttonsHandler: buttonsHandler,
                                              numberOfRounds: numberOfRounds)
        } catch let error {
            fatalError("\(error)")
        }
        
        
        self.setOptionButtonsTags() // Setting Button tags, matching Enums for easier handling through the enum
        self.setViewRoundCorners()
        buttonsHandler.setButtonProperties()
        quizGame?.setQuizRound()
    }
    
    @IBAction func orderButtonPressed(_ sender: UIButton) {
        quizGame?.swapFacts(sender)
    }
    
    @IBAction func controlButtonPressed() {
        if quizGame?.numberOfRounds == quizGame?.roundsPlayed {
            self.performSegue(withIdentifier: "gameToScore", sender: self)
        } else {
            quizGame?.setQuizRound()
        }
    }
    
    @IBAction func factButtonPress(_ sender: UIButton) {
        self.senderFactButton = sender
        self.performSegue(withIdentifier: "gameToWeb", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameToScore" {
            
            guard let correctAnswers = quizGame?.correctAnswers,
                let numberOfRounds = quizGame?.numberOfRounds
                else {
                    fatalError("Critical Error! Most likely the gameplay variable failed to initialize in the body of a GameplayViewController.")
            }
            let scoreViewController = segue.destination as! ScoreViewController
            scoreViewController.scoreString = String(format: "%01d/%01d", correctAnswers, numberOfRounds + 1)
        } else if segue.identifier == "gameToWeb" {
            
            guard let title = self.senderFactButton?.currentTitle else {
                fatalError("Critical Error! NO FACT BUTTON CAPTION BEEN SET!")
            }
            if let webViewController = segue.destination as? WebViewController {
                webViewController.factCaption = title
            }
        }
        
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
