//
//  TimerManager.swift
//  EasyTap Timer
//
//  Created by Kim EenSung on 8/4/24.
//

import Foundation
import UIKit

protocol TimerManagerDelegate: AnyObject {
    func timerDidUpdate(time: TimeInterval)
    func timerDidChangeState(isRunning: Bool)
}

final class TimerManager {
    private var userSetTime: TimeInterval = TimerConstants.InitialTimerValue
    private lazy var initialTime: TimeInterval = userSetTime
    private lazy var remainingTime: TimeInterval = userSetTime {
        didSet {
            delegate?.timerDidUpdate(time: remainingTime)
        }
    }
    private(set) var isTimerRunning: Bool = false {
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
        initialTime = remainingTime
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    func resetTimer() {
        stopTimer()
        remainingTime = userSetTime
    }
    
    func updateTime(to time: TimeInterval) {
        userSetTime = time
        if !isTimerRunning {
            remainingTime = userSetTime
        }
    }

    private func updateTimer() {
        guard let startTime = startTime else { return }
        let elapsedTime = Date().timeIntervalSince(startTime)
        remainingTime = initialTime - elapsedTime
        if remainingTime <= 0 {
            stopTimer()
            initialTime = userSetTime
            NotificationCenter.default.post(name: .timerDidEnd, object: nil)
        }
    }
}

extension Notification.Name {
    static let timerDidEnd = Notification.Name("timerDidEnd")
}
