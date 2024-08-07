//
//  ViewController.swift
//  EasyTap Timer
//
//  Created by Kim EenSung on 8/4/24.
//

import UIKit
import AVFoundation

final class MainViewController: UIViewController {
    private var timerManager: TimerManager
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.text = "Tap to Start"
        return label
    }()
    
    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        timerManager.delegate = self

        setupUI()
        setupGestureRecognizers()

        NotificationCenter.default.addObserver(self, selector: #selector(timerDidEnd), name: .timerDidEnd, object: nil)
    }

    private func setupUI() {
        view.addSubview(timeLabel)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        // 이 부분 panGesture 맞는지 확인 필요
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
    }

    @objc private func handleTap() {
        if timerManager.isTimerRunning {
            timerManager.stopTimer()
        } else {
            timerManager.startTimer()
        }
    }

    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        // 마찬가지로 panGesture 관련해서 확인 필요
        if gesture.state == .ended {
            timerManager.resetTimer()
        }
    }

    @objc private func timerDidEnd() {
        let alert = UIAlertController(title: "Timer Ended", message: "Tap to dismiss", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        playSound()
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time - TimeInterval(minutes * 60) - TimeInterval(seconds)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }

    private func playSound() {
        AudioServicesPlaySystemSound(1005)
    }
}

extension MainViewController: TimerManagerDelegate {
    func timerDidUpdate(time: TimeInterval) {
        timeLabel.text = formattedTime(time)
    }

    func timerDidChangeState(isRunning: Bool) {
        view.backgroundColor = isRunning ? .red : .systemBackground
    }
}
