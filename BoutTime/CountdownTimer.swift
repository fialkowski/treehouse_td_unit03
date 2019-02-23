//
//  CountdownTimer.swift
//  BoutTime
//
//  Created by nikko444 on 2019-02-17.
//  Copyright © 2019 nikko444. All rights reserved.
//

import UIKit

class CountdownTimer {
    
    var countdownTimer: Timer!
    var totalTime = 60
    var timerLabel: UILabel
    var quizGame: QuizGame? //passing the QuizGame compliant instance for checkScreen method triggering.
    
    init (timerLabel: UILabel) {
        self.timerLabel = timerLabel
    }
    
    func set (quizGame: QuizGame) { //Using a method to pass the instance since the class doesn't exist while being intialized
        self.quizGame = quizGame
    }
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        timerLabel.isHidden = false
        timerLabel.text = "\(timeFormatted(totalTime))"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        timerLabel.isHidden = true
        countdownTimer.invalidate()
        timerLabel.text = "01:00"
        totalTime = 60
        quizGame?.checkScreen()
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}
