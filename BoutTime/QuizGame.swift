//
//  QuizGame.swift
//  BoutTime
//
//  Created by nikko444 on 2019-02-14.
//  Copyright © 2019 nikko444. All rights reserved.
//

import UIKit
import Foundation

extension UIFont {
    struct QuizGameFont {
        static var factDefault: UIFont { return UIFont(name:"HelveticaNeue", size: 17.0)! }
    }
}

extension UIColor {
    struct QuizGameFontColor {
        static var factDefault: UIColor { return UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)}
    }
}

enum OrderChangeButton: Int {
    case firstDown = 1
    case secondUp
    case secondDown
    case thirdUp
    case thirdDown
    case fourthUp
    
    func icon(isHighlighted: Bool = false) -> UIImage {
        var iconName: String = ""
        switch self {
        case .firstDown:
            do {
                iconName = "downFull"
                if isHighlighted {iconName += "Selected"}
            }
        case .secondUp, .thirdUp:
            do {
                iconName = "upHalf"
                if isHighlighted {iconName += "Selected"}
            }
        case .secondDown, .thirdDown:
            do {
                iconName = "downHalf"
                if isHighlighted {iconName += "Selected"}
            }
        case .fourthUp:
            do {
                iconName = "upFull"
                if isHighlighted {iconName += "Selected"}
            }
        }
        guard let image = UIImage(named: iconName) else {
            return UIImage(named: "upHalf")!
        }
        return image
    }
}

enum QuizSourceError: Error {
    case invalidResource
    case conversionFailure(description: String)
}

enum FactError: Error { //Used specifically for Fact Struct
    case wrongDate(detail: String)
}

protocol QuizGameFact {
    var description: String { get }
    var date: Date { get }
    
    init(event desctription: String, at date: Date)
}

protocol QuizGameButtonsHandler {
    var orderButtons: [UIButton] { get }
    var controlButton: UIButton { get }
    var firstRowFactButton: UIButton { get }
    var secondRowFactButton: UIButton { get }
    var thirdRowFactButton: UIButton { get }
    var fourthRowFactButton: UIButton { get }
    
    init(orderButtons: [UIButton],
         controlButton: UIButton,
         firstRowFact: UIButton,
         secondRowFact: UIButton,
         thirdRowFact: UIButton,
         fourthRowFact: UIButton)
    
    func swapFacts(_ sender: UIButton)
    func setButtonProperties ()
    func setTimerScreenFor(firstFact: String,
                           secondFact: String,
                           thirdFact: String,
                           fourthFact: String)
    func setResultScreen(for facts: [QuizGameFact])
}

protocol QuizGame {
    var buttonsHandler: QuizGameButtonsHandler { get }
    var facts: [QuizGameFact] { get }
    var timer: CountdownTimer { get }
    var shakeToCompleteLabel: UILabel { get }
    
    init (facts: [QuizGameFact],
          timerLabel: UILabel,
          shakeLabel: UILabel,
          buttonsHandler: QuizGameButtonsHandler)
    
    func swapFacts(_ sender: UIButton)
    func setQuizRound ()
    func checkScreen()
    func shakeAction()
}

struct AerospaceFact: QuizGameFact {
    var description: String
    var date: Date
    private let calendar = Calendar(identifier: .gregorian)
    
    init(event description: String, at date: Date) {
        self.description = description
        self.date = date
    }
}

class PlistConverter {
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String: AnyObject] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw QuizSourceError.invalidResource
        }
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String : AnyObject] else { //A TYPE CASTING HAPPENS HERE
            throw QuizSourceError.conversionFailure(description: "Can't convert plist file to a correct dictionary!")
        }
        return dictionary
    }
}

class FactsUnarchiver {
    static func fetch(fromDictionary dictionary: [String:AnyObject]) throws -> [AerospaceFact] {
        var inventory: [AerospaceFact] = []
        for (key, value) in dictionary {
            guard let factDictionary = value as? [String: Any] else {
                throw QuizSourceError.conversionFailure(description: "Item's dictionary has wrong format!")
            }
            guard let date = factDictionary["date"] as? Date else {
                throw QuizSourceError.conversionFailure(description: "Item's dictionary doesn't contain a proper date")
            }
            inventory.append(AerospaceFact(event: key, at: date))
        }
        return inventory
    }
}

class AerospaceQuizButtonsHandler: QuizGameButtonsHandler {
    var orderButtons: [UIButton]
    var controlButton: UIButton
    var firstRowFactButton: UIButton
    var secondRowFactButton: UIButton
    var thirdRowFactButton: UIButton
    var fourthRowFactButton: UIButton
    
    required init(orderButtons: [UIButton],
                  controlButton: UIButton,
                  firstRowFact: UIButton,
                  secondRowFact: UIButton,
                  thirdRowFact: UIButton,
                  fourthRowFact: UIButton){
        self.orderButtons = orderButtons
        self.controlButton = controlButton
        self.firstRowFactButton = firstRowFact
        self.secondRowFactButton = secondRowFact
        self.thirdRowFactButton = thirdRowFact
        self.fourthRowFactButton = fourthRowFact
    }
    
    func setButtonProperties() {
        for orderButton in orderButtons {
            let highlightedImage = OrderChangeButton(rawValue: orderButton.tag)?.icon(isHighlighted: true)
            let defaultImage = OrderChangeButton(rawValue: orderButton.tag)?.icon()
            orderButton.setImage(highlightedImage, for: .highlighted)
            orderButton.setImage(defaultImage, for: .normal)
        }
        firstRowFactButton.titleLabel?.font = UIFont.QuizGameFont.factDefault
        firstRowFactButton.setTitleColor(UIColor.QuizGameFontColor.factDefault, for: .disabled)
        secondRowFactButton.titleLabel?.font = UIFont.QuizGameFont.factDefault
        secondRowFactButton.setTitleColor(UIColor.QuizGameFontColor.factDefault, for: .disabled)
        thirdRowFactButton.titleLabel?.font = UIFont.QuizGameFont.factDefault
        thirdRowFactButton.setTitleColor(UIColor.QuizGameFontColor.factDefault, for: .disabled)
        fourthRowFactButton.titleLabel?.font = UIFont.QuizGameFont.factDefault
        fourthRowFactButton.setTitleColor(UIColor.QuizGameFontColor.factDefault, for: .disabled)
    }
    
    func swapFacts(_ sender: UIButton) {
        switch sender.tag {
        case OrderChangeButton.firstDown.rawValue, OrderChangeButton.secondUp.rawValue :
            do {
                let factKeyBuffer = firstRowFactButton.title(for: .normal)
                firstRowFactButton.setTitle(secondRowFactButton.title(for: .normal), for: .normal)
                secondRowFactButton.setTitle(factKeyBuffer, for: .normal)
            }
        case OrderChangeButton.secondDown.rawValue, OrderChangeButton.thirdUp.rawValue :
            do {
                let factKeyBuffer = secondRowFactButton.title(for: .normal)
                secondRowFactButton.setTitle(thirdRowFactButton.title(for: .normal), for: .normal)
                thirdRowFactButton.setTitle(factKeyBuffer, for: .normal)
            }
        case OrderChangeButton.thirdDown.rawValue, OrderChangeButton.fourthUp.rawValue :
            do {
                let factKeyBuffer = thirdRowFactButton.title(for: .normal)
                thirdRowFactButton.setTitle(fourthRowFactButton.title(for: .normal), for: .normal)
                fourthRowFactButton.setTitle(factKeyBuffer, for: .normal)
            }
        default : break
        }
    }
    
    func setTimerScreenFor(firstFact: String,
                           secondFact: String,
                           thirdFact: String,
                           fourthFact: String) {
        for orderButton in orderButtons {
            orderButton.isEnabled = true
        }
        controlButton.isHidden = true
        firstRowFactButton.isEnabled = false
        firstRowFactButton.setTitle(firstFact, for: .normal)
        secondRowFactButton.isEnabled = false
        secondRowFactButton.setTitle(secondFact, for: .normal)
        thirdRowFactButton.isEnabled = false
        thirdRowFactButton.setTitle(thirdFact, for: .normal)
        fourthRowFactButton.isEnabled = false
        fourthRowFactButton.setTitle(fourthFact, for: .normal)
    }
    
    func setResultScreen(for facts: [QuizGameFact]) {
        for orderButton in orderButtons {
            orderButton.isEnabled = false
        }
        firstRowFactButton.isEnabled = true
        secondRowFactButton.isEnabled = true
        thirdRowFactButton.isEnabled = true
        fourthRowFactButton.isEnabled = true
        showControlButton(forAnswer: screenIsInOrder(for: facts))
    }
    
    private func showControlButton(forAnswer answer: Bool) {
        switch answer {
        case true: controlButton.setImage(UIImage(named: "nextRoundSuccess"), for: .normal)
        case false: controlButton.setImage(UIImage(named: "nextRoundFail"), for: .normal)
        }
        controlButton.isHidden = false
    }
    
    private func screenIsInOrder(for facts: [QuizGameFact]) -> Bool {
        var factDates = facts.filter{$0.description == firstRowFactButton.title(for: .normal)}
        factDates += facts.filter{$0.description == secondRowFactButton.title(for: .normal)}
        factDates += facts.filter{$0.description == thirdRowFactButton.title(for: .normal)}
        factDates += facts.filter{$0.description == fourthRowFactButton.title(for: .normal)}
        if factDates.count == 4 {
            if (factDates[0].date <= factDates[1].date) &&
                (factDates[1].date <= factDates[2].date) &&
                (factDates[2].date <= factDates[3].date) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
}

class AerospaceQuizGame: QuizGame {
    var buttonsHandler: QuizGameButtonsHandler
    var facts: [QuizGameFact]
    var usedFacts: [QuizGameFact] = []
    var timer: CountdownTimer
    var shakeToCompleteLabel: UILabel
     
    required init(facts: [QuizGameFact],
                  timerLabel: UILabel,
                  shakeLabel: UILabel,
                  buttonsHandler: QuizGameButtonsHandler) {
        self.facts = facts
        self.buttonsHandler = buttonsHandler
        self.shakeToCompleteLabel = shakeLabel
        timer = CountdownTimer(timerLabel: timerLabel)
    }
    
    func setQuizRound () {
        timer.set(quizGame: self)
        shakeToCompleteLabel.isHidden = false
        buttonsHandler.setTimerScreenFor(firstFact: getRandomFact().description,
                                         secondFact: getRandomFact().description,
                                         thirdFact: getRandomFact().description,
                                         fourthFact: getRandomFact().description)
        timer.startTimer()
    }
    
    func swapFacts(_ sender: UIButton) {
        buttonsHandler.swapFacts(sender) // Passing sender through
    }
    
    func checkScreen() {
        shakeToCompleteLabel.isHidden = true
        buttonsHandler.setResultScreen(for: facts)
    }
    
    func shakeAction() {
        timer.endTimer()
    }
    
    private func getRandomFact() -> QuizGameFact {
        var infiniteLoopDebounce: Int = facts.count * 2
        var repeatLoopFlag: Bool = false
        var returnFact: QuizGameFact?
        if usedFacts.count == facts.count {
            usedFacts = [] // Buffer flush when full
        }
        repeat {
            if let tempFact = facts.randomElement() {
                returnFact = tempFact
                for usedFact in usedFacts {
                    if usedFact.description == tempFact.description {
                        repeatLoopFlag = true
                    }
                }
            }
        infiniteLoopDebounce -= 1
        } while repeatLoopFlag == true && infiniteLoopDebounce >= 0
        if let returnFact = returnFact {
            usedFacts.append(returnFact)
            return returnFact
        }
        return AerospaceFact(event: "This is an error from getRandomFact method", at: Date(timeIntervalSince1970: 0))
    }
    
}
