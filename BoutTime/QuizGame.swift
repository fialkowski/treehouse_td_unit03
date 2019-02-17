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

protocol QuizGameOrderButtonsHandler {
    var buttons: [UIButton] { get }
    
    init( buttons: [UIButton])
    
    func setIcons ()
}

protocol QuizGame {
    //var buttonsHandler: QuizGameOrderButtonsHandler { get }
    var firstRowFactLabel: UILabel? { get }
    var secondRowFactLabel: UILabel? { get }
    var thirdRowFactLabel: UILabel? { get }
    var fourthRowFactLabel: UILabel? { get }
    var facts: [QuizGameFact] { get }
    
    init (facts: [QuizGameFact])
    
    func setLabels(firstRowFactLabel: UILabel,
        secondRowFactLabel: UILabel,
        thirdRowFactLabel: UILabel,
        fourthRowFactLabel: UILabel)
    
    func updateScreen ()
    func setQuizRound ()
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

class AerospaceQuizOrderButtonsHandler: QuizGameOrderButtonsHandler {
    var buttons: [UIButton]
    
    required init(buttons: [UIButton]) {
        self.buttons = buttons
    }
    
    func setIcons() {
        for button in buttons {
            let image = OrderChangeButton(rawValue: button.tag)?.icon(isSelected: true)
            button.setImage(image, for: .selected)
        }
    }
}

class AerospaceQuizGame: QuizGame {
    var firstRowFactLabel: UILabel?
    var secondRowFactLabel: UILabel?
    var thirdRowFactLabel: UILabel?
    var fourthRowFactLabel: UILabel?
    //var buttonsHandler: QuizGameOrderButtonsHandler
    var facts: [QuizGameFact]
    var usedFacts: [QuizGameFact] = []
     
    required init(facts: [QuizGameFact]) {
        self.facts = facts
    }
    
    func setLabels(firstRowFactLabel: UILabel,
                   secondRowFactLabel: UILabel,
                   thirdRowFactLabel: UILabel,
                   fourthRowFactLabel: UILabel) {
        self.firstRowFactLabel = firstRowFactLabel
        self.secondRowFactLabel = secondRowFactLabel
        self.thirdRowFactLabel = thirdRowFactLabel
        self.fourthRowFactLabel = fourthRowFactLabel
    }
    
    func updateScreen() {
        print(facts)
    }
    
    func setQuizRound () {
        if let firstRowFactLabel = firstRowFactLabel {
            firstRowFactLabel.text = getRandomFact().description
        }
        if let secondRowFactLabel = secondRowFactLabel {
            secondRowFactLabel.text = getRandomFact().description
        }
        if let thirdRowFactLabel = thirdRowFactLabel {
            thirdRowFactLabel.text = getRandomFact().description
        }
        if let fourthRowFactLabel = fourthRowFactLabel {
            fourthRowFactLabel.text = getRandomFact().description
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
        return AerospaceFact(event: "This is an error in getRandomFact method", at: Date(timeIntervalSince1970: 0))
    }
    
}
