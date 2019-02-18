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
    var quizGame: QuizGame?
    
    init (timerLabel: UILabel) {
        self.timerLabel = timerLabel
    }
    
    func set (quizGame: QuizGame) {
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
    
    
    // TODO: Fix the comments below!
    // You will need to use the *Timer* class(it’s included in an import of UIKit), to create your countdownTimer variable.  Timer has a function called *scheduledTimer* that you will use to initialize your countdownTimer.  One parameter of *scheduledTimer* takes a selector, where you will select the method(a separate function that you create) to update your time.  To end an instance of *Timer*, you can use the *invalidate()* method from the class.  Also, since you are more than likely displaying your counter on a UILabel, you will have to format the time to a String that has the look you want.  You will need another variable to hold the value you are starting your countdown from as well.
    
    // I didn’t want to just straight up give you all the code, but if you still can’t figure out how to set one up from the hints I have given, let me know and I will paste in my example of a countdown timer, as I have a basic working countdown timer figured out, and I will check on this thread throughout the day to see if you get it working. Let me know!
    
}
