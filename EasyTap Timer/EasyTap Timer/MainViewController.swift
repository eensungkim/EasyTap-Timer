//
//  MainViewController.swift
//  EasyTap Timer
//
//  Created by Kim EenSung on 8/4/24.
//

import UIKit
import AVFoundation

// MARK: - MainViewController Class
final class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 타이머를 관리하는 TimerManager 인스턴스
    private var timerManager: TimerManager
    
    /// 타이머 시간을 표시하는 UILabel
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.text = "Tap to Start"
        return label
    }()
    
    /// 눈금자 스크롤 뷰
    private lazy var rulerScrollView: RulerScrollView = RulerScrollView(viewWidth: view.bounds.width)
    
    /// 눈금자 중앙을 표시하는 인디케이터 뷰
    private var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    // MARK: - Initializers
    
    /// MainViewController 초기화 메서드
    /// - Parameter timerManager: 타이머 관리 객체
    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    /// 뷰가 로드되었을 때 호출되는 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        timerManager.delegate = self

        setupUI()
        setupGestureRecognizers()
        updateScrollViewOffset()

        NotificationCenter.default.addObserver(self, selector: #selector(timerDidEnd), name: .timerDidEnd, object: nil)
    }

    // MARK: - UI Setup
    
    /// UI를 설정하는 메서드
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
            
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 1),
            indicatorView.topAnchor.constraint(equalTo: rulerScrollView.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: rulerScrollView.bottomAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 3)
        ])
    }
    
    // MARK: - Timer End Handling
    
    /// 타이머가 종료되었을 때 호출되는 메서드
    @objc private func timerDidEnd() {
        // 알림 생성 및 발송
        let content = UNMutableNotificationContent()
        content.title = "Timer Ended"
        content.body = "Tap to dismiss"
        content.sound = UNNotificationSound.default


        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
        
        // 타이머 종료 후 시간 업데이트
        let currentOffset = rulerScrollView.contentOffset.x
        updateTimeAndLabel(with: currentOffset)
    }
    
    /// 스크롤 오프셋에 따라 타이머 시간과 라벨을 업데이트하는 메서드
    /// - Parameter currentOffset: 현재 스크롤 오프셋
    private func updateTimeAndLabel(with currentOffset: CGFloat) {
        let value = round(currentOffset / TimerConstants.TickInterval) * TimerConstants.TimeStep
        timerManager.updateTime(to: TimeInterval(value))
        timeLabel.text = formattedTime(TimeInterval(value))
    }

    /// 주어진 시간을 형식화하여 문자열로 반환하는 메서드
    /// - Parameter time: 포맷할 시간
    /// - Returns: "MM:SS" 형식의 문자열
    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// 스크롤 뷰의 초기 오프셋을 설정하여 중앙에 0초가 오도록 조정하는 메서드
    private func updateScrollViewOffset() {
        let initialOffsetX = -view.bounds.width / 2
        rulerScrollView.setContentOffset(CGPoint(x: initialOffsetX, y: 0), animated: false)
    }
}

// MARK: - Gesture Handling
extension MainViewController {
    
    /// 제스처 인식기를 설정하는 메서드
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        rulerScrollView.addGestureRecognizer(panGesture)
    }
    
    /// 화면 탭 제스처를 처리하는 메서드
    @objc private func handleTap() {
        if timerManager.isTimerRunning {
            timerManager.stopTimer()
        } else {
            timerManager.startTimer()
        }
    }
    
    /// 스와이프 제스처를 처리하는 메서드
    /// - Parameter gesture: 인식된 스와이프 제스처
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .down:
            timerManager.resetTimer()
        default:
            break
        }
    }
    
    /// 팬 제스처를 처리하는 메서드
    /// - Parameter gesture: 인식된 팬 제스처
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: rulerScrollView)
        let velocity = gesture.velocity(in: rulerScrollView)
        let velocityFactor: CGFloat = 0.005
        
        let newOffsetX = rulerScrollView.contentOffset.x - translation.x - (velocity.x * velocityFactor)
        rulerScrollView.contentOffset.x = max(0, min(newOffsetX, rulerScrollView.contentSize.width - rulerScrollView.bounds.width))
        gesture.setTranslation(.zero, in: rulerScrollView)
        
        let currentOffset = rulerScrollView.contentOffset.x
        updateTimeAndLabel(with: currentOffset)
        
        if gesture.state == .ended {
            let nearestTickOffset = round(currentOffset / TimerConstants.TickInterval) * TimerConstants.TickInterval
            UIView.animate(withDuration: 0.2) {
                self.rulerScrollView.contentOffset.x = nearestTickOffset
            }
        }
    }
}

// MARK: - TimerManagerDelegate
extension MainViewController: TimerManagerDelegate {
    
    /// 타이머가 업데이트될 때 호출되는 메서드
    func timerDidUpdate(time: TimeInterval) {
        timeLabel.text = formattedTime(time)
    }

    /// 타이머 상태가 변경될 때 호출되는 메서드
    func timerDidChangeState(isRunning: Bool) {
        view.backgroundColor = isRunning ? .red : .systemBackground
    }
}
