//
//  MainViewController.swift
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
    private lazy var rulerScrollView: RulerScrollView = RulerScrollView(viewWidth: view.bounds.width)
    private var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
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
        updateScrollViewOffset()

        NotificationCenter.default.addObserver(self, selector: #selector(timerDidEnd), name: .timerDidEnd, object: nil)
    }

    private func setupUI() {
        view.addSubview(timeLabel)
        view.addSubview(rulerScrollView)
        view.addSubview(indicatorView)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        rulerScrollView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            rulerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rulerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rulerScrollView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
            rulerScrollView.heightAnchor.constraint(equalToConstant: 50),
            
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.topAnchor.constraint(equalTo: rulerScrollView.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: rulerScrollView.bottomAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 3)
        ])
    }
    
    @objc private func timerDidEnd() {
        // 알림 콘텐츠 생성
        let content = UNMutableNotificationContent()
        content.title = "Timer Ended"
        content.body = "Tap to dismiss"
        content.sound = UNNotificationSound.default

        // 즉시 발송되는 트리거 생성
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)

        // 알림 요청 생성
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // 알림 추가
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
        
        // 기존 기능 유지
        let currentOffset = rulerScrollView.contentOffset.x
        updateTimeAndLabel(with: currentOffset)
        
        playSound()
    }
    
    private func updateTimeAndLabel(with currentOffset: CGFloat) {
        let value = round(currentOffset / TimerConstants.TickInterval) * TimerConstants.TimeStep
        timerManager.updateTime(to: TimeInterval(value))
        timeLabel.text = formattedTime(TimeInterval(value))
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func playSound() {
        AudioServicesPlaySystemSound(1005)
    }

    private func updateScrollViewOffset() {
        // 스크롤뷰의 초기 오프셋을 설정하여 0초가 중앙에 오도록 조정
        let initialOffsetX = -view.bounds.width / 2
        rulerScrollView.setContentOffset(CGPoint(x: initialOffsetX, y: 0), animated: false)
    }
}

extension MainViewController {
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        rulerScrollView.addGestureRecognizer(panGesture)
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
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: rulerScrollView)
        let velocity = gesture.velocity(in: rulerScrollView)
        let velocityFactor: CGFloat = 0.01
        
        let newOffsetX = rulerScrollView.contentOffset.x - translation.x - (velocity.x * velocityFactor)
        rulerScrollView.contentOffset.x = max(0, min(newOffsetX, rulerScrollView.contentSize.width - rulerScrollView.bounds.width))
        gesture.setTranslation(.zero, in: rulerScrollView)
        
        let currentOffset = rulerScrollView.contentOffset.x
        updateTimeAndLabel(with: currentOffset)
        
        if gesture.state == .ended {
            // 팬 제스처가 종료될 때, 가장 가까운 눈금으로 오프셋을 스냅
            let nearestTickOffset = round(currentOffset / TimerConstants.TickInterval) * TimerConstants.TickInterval
            UIView.animate(withDuration: 0.2) {
                self.rulerScrollView.contentOffset.x = nearestTickOffset
            }
        }
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
