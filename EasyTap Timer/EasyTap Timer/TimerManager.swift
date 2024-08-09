//
//  TimerManager.swift
//  EasyTap Timer
//
//  Created by Kim EenSung on 8/4/24.
//

import Foundation
import UIKit

// MARK: - TimerManagerDelegate Protocol
protocol TimerManagerDelegate: AnyObject {
    /// 타이머 시간이 업데이트될 때 호출되는 메서드
    func timerDidUpdate(time: TimeInterval)
    
    /// 타이머의 실행 상태가 변경될 때 호출되는 메서드
    func timerDidChangeState(isRunning: Bool)
}

// MARK: - TimerManager Class
final class TimerManager {
    
    // MARK: - Properties
    
    /// 사용자가 설정한 타이머 시간 (초 단위)
    private var userSetTime: TimeInterval = TimerConstants.InitialTimerValue
    
    /// 타이머가 시작될 때 초기화되는 시간
    private lazy var initialTime: TimeInterval = userSetTime
    
    /// 남은 타이머 시간 (초 단위), 변경 시 delegate에게 업데이트 알림
    private lazy var remainingTime: TimeInterval = userSetTime {
        didSet {
            delegate?.timerDidUpdate(time: remainingTime)
        }
    }
    
    /// 타이머가 실행 중인지 여부를 나타내는 변수, 변경 시 delegate에게 상태 변경 알림
    private(set) var isTimerRunning: Bool = false {
        didSet {
            delegate?.timerDidChangeState(isRunning: isTimerRunning)
        }
    }
    
    /// 타이머 객체
    private var timer: Timer?
    
    /// 타이머가 시작된 시간
    private var startTime: Date?
    
    /// TimerManager의 delegate, 타이머 상태 변경을 알림
    weak var delegate: TimerManagerDelegate?

    // MARK: - Methods
    
    /// 타이머 시작 메서드, 타이머가 실행되면서 반복적으로 시간을 업데이트
    func startTimer() {
        startTime = Date()
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    /// 타이머 중지 메서드, 타이머를 중지하고 현재 남은 시간을 초기화
    func stopTimer() {
        initialTime = remainingTime
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    /// 타이머 리셋 메서드, 타이머를 중지하고 시간을 초기 설정으로 되돌림
    func resetTimer() {
        stopTimer()
        remainingTime = userSetTime
    }
    
    /// 사용자가 설정한 시간으로 타이머 시간을 업데이트하는 메서드
    /// - Parameter time: 설정할 시간 (초 단위)
    func updateTime(to time: TimeInterval) {
        userSetTime = time
        if !isTimerRunning {
            initialTime = userSetTime
            remainingTime = initialTime
        }
    }

    /// 타이머가 실행 중일 때 매 0.1초마다 남은 시간을 업데이트하는 메서드
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

// MARK: - Notification.Name Extension
extension Notification.Name {
    /// 타이머가 종료되었음을 알리는 Notification
    static let timerDidEnd = Notification.Name("timerDidEnd")
}
