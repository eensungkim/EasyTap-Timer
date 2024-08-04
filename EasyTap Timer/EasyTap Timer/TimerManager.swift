//
//  TimerManager.swift
//  EasyTap Timer
//
//  Created by Kim EenSung on 8/4/24.
//

import Foundation
import UIKit

class TimerManager {
    var remainingTime: TimeInterval = 60.0 {
        didSet {
            delegate?.timerDidUpdate(time: remainingTime)
        }
    }
    var isTimerRunning: Bool = false {
        didSet {
            delegate?.timerDidChangeState(isRunning: isTimerRunning)
        }
    }
    private var timer: Timer?
    private var startTime: Date?
    weak var delegate: TimerManagerDelegate?

    func startTimer() {
        startTime = Date()
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    func resetTimer() {
        stopTimer()
        remainingTime = 60.0
    }

    private func updateTimer() {
        guard let startTime = startTime else { return }
        let elapsedTime = Date().timeIntervalSince(startTime)
        remainingTime = 60.0 - elapsedTime
        if remainingTime <= 0 {
            stopTimer()
            remainingTime = 0
            NotificationCenter.default.post(name: .timerDidEnd, object: nil)
        }
    }
}

protocol TimerManagerDelegate: AnyObject {
    func timerDidUpdate(time: TimeInterval)
    func timerDidChangeState(isRunning: Bool)
}

extension Notification.Name {
    static let timerDidEnd = Notification.Name("timerDidEnd")
}
