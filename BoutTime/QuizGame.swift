//
//  QuizGame.swift
//  BoutTime
//
//  Created by nikko444 on 2019-02-14.
//  Copyright © 2019 nikko444. All rights reserved.
//

import UIKit
import Foundation

enum OrderChangeButton: Int {
    case firstDown = 1
    case secondUp
    case secondDown
    case thirdUp
    case thirdDown
    case fourthUp
    
    func icon(isSelected: Bool = false) -> UIImage {
        var iconName: String = ""
        switch self {
        case .firstDown:
            do {
                iconName = "downFull"
                if isSelected {iconName += "Selected"}
            }
        case .secondUp, .thirdUp:
            do {
                iconName = "upHalf"
                if isSelected {iconName += "Selected"}
            }
        case .secondDown, .thirdDown:
            do {
                iconName = "downHalf"
                if isSelected {iconName += "Selected"}
            }
        case .fourthUp:
            do {
                iconName = "upFull"
                if isSelected {iconName += "Selected"}
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
    
    init(orderButtons: [UIButton], controlButton: UIButton)
    
    func setIcons ()
    func setTimerScreen()
    func setResultScreen(forAnswer answer: Bool)
}

protocol QuizGame {
    var buttonsHandler: QuizGameButtonsHandler { get }
    var firstRowFactLabel: UILabel { get }
    var secondRowFactLabel: UILabel { get }
    var thirdRowFactLabel: UILabel { get }
    var fourthRowFactLabel: UILabel { get }
    var facts: [QuizGameFact] { get }
    var timer: CountdownTimer { get }
    
    init (facts: [QuizGameFact],
          firstRowFactLabel: UILabel,
          secondRowFactLabel: UILabel,
          thirdRowFactLabel: UILabel,
          fourthRowFactLabel: UILabel,
          timerLabel: UILabel,
          buttonsHandler: QuizGameButtonsHandler)
    
    func moveFact(_ sender: UIButton)
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
    
    required init(orderButtons: [UIButton], controlButton: UIButton) {
        self.orderButtons = orderButtons
        self.controlButton = controlButton
    }
    
    func setIcons() {
        for orderButton in orderButtons {
            let image = OrderChangeButton(rawValue: orderButton.tag)?.icon(isSelected: true)
            orderButton.setImage(image, for: .selected)
        }
    }
    
    func setTimerScreen() {
        for orderButton in orderButtons {
            orderButton.isEnabled = true
        }
        controlButton.isHidden = true
    }
    
    func setResultScreen(forAnswer answer: Bool) {
        for orderButton in orderButtons {
            orderButton.isEnabled = false
        }
        showControlButton(forAnswer: answer)
    }
    
    private func showControlButton(forAnswer answer: Bool) {
        switch answer {
        case true: controlButton.setImage(UIImage(named: "nextRoundSuccess"), for: .normal)
        case false: controlButton.setImage(UIImage(named: "nextRoundFail"), for: .normal)
        }
        controlButton.isHidden = false
    }
}

class AerospaceQuizGame: QuizGame {
    var buttonsHandler: QuizGameButtonsHandler
    var firstRowFactLabel: UILabel
    var secondRowFactLabel: UILabel
    var thirdRowFactLabel: UILabel
    var fourthRowFactLabel: UILabel
    var facts: [QuizGameFact]
    var usedFacts: [QuizGameFact] = []
    var timer: CountdownTimer
     
    required init(facts: [QuizGameFact],
                  firstRowFactLabel: UILabel,
                  secondRowFactLabel: UILabel,
                  thirdRowFactLabel: UILabel,
                  fourthRowFactLabel: UILabel,
                  timerLabel: UILabel,
                  buttonsHandler: QuizGameButtonsHandler) {
        self.facts = facts
        self.firstRowFactLabel = firstRowFactLabel
        self.secondRowFactLabel = secondRowFactLabel
        self.thirdRowFactLabel = thirdRowFactLabel
        self.fourthRowFactLabel = fourthRowFactLabel
        self.buttonsHandler = buttonsHandler
        timer = CountdownTimer(timerLabel: timerLabel)
    }
    
    func setQuizRound () {
        timer.set(quizGame: self)
        firstRowFactLabel.text = getRandomFact().description
        secondRowFactLabel.text = getRandomFact().description
        thirdRowFactLabel.text = getRandomFact().description
        fourthRowFactLabel.text = getRandomFact().description
        buttonsHandler.setTimerScreen()
        timer.startTimer()
    }
    
    func moveFact(_ sender: UIButton) {
        switch sender.tag {
        case OrderChangeButton.firstDown.rawValue, OrderChangeButton.secondUp.rawValue :
            do {
                let factKeyBuffer = firstRowFactLabel.text
                firstRowFactLabel.text = secondRowFactLabel.text
                secondRowFactLabel.text = factKeyBuffer
            }
        case OrderChangeButton.secondDown.rawValue, OrderChangeButton.thirdUp.rawValue :
            do {
                let factKeyBuffer = secondRowFactLabel.text
                secondRowFactLabel.text = thirdRowFactLabel.text
                thirdRowFactLabel.text = factKeyBuffer
            }
        case OrderChangeButton.thirdDown.rawValue, OrderChangeButton.fourthUp.rawValue :
            do {
                let factKeyBuffer = thirdRowFactLabel.text
                thirdRowFactLabel.text = fourthRowFactLabel.text
                fourthRowFactLabel.text = factKeyBuffer
            }
        default : break
        }
    }
    
    func checkScreen() {
        buttonsHandler.setResultScreen(forAnswer: isInCorrectOrder())
    }
    
    func shakeAction() {
        timer.endTimer()
    }
    
    private func isInCorrectOrder() -> Bool {
        var factDates = facts.filter{$0.description == firstRowFactLabel.text}
        factDates += facts.filter{$0.description == secondRowFactLabel.text}
        factDates += facts.filter{$0.description == thirdRowFactLabel.text}
        factDates += facts.filter{$0.description == fourthRowFactLabel.text}
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
