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
    private var timeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 5
        slider.maximumValue = 600
        slider.value = 60
        slider.isContinuous = true
        return slider
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
        setupSlider()
        setupGestureRecognizers()

        NotificationCenter.default.addObserver(self, selector: #selector(timerDidEnd), name: .timerDidEnd, object: nil)
    }

    private func setupUI() {
        view.addSubview(timeLabel)
        view.addSubview(timeSlider)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeSlider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timeSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timeSlider.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20)
        ])
    }
    private func setupSlider() {
        timeSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }

    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }

    @objc private func handleTap() {
        if timerManager.isTimerRunning {
            timerManager.stopTimer()
        } else {
            timerManager.startTimer()
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .down:
            timerManager.resetTimer()
        default:
            break
        }
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let step: Float = 5
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        timerManager.updateTime(to: TimeInterval(roundedValue))
        timeLabel.text = formattedTime(TimeInterval(roundedValue))
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
