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
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private var rulerView: UIView = {
        let view = UIView()
        return view
    }()
    private var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    private let tickInterval: CGFloat = 10.0
    private let maxTime: CGFloat = 600.0
    private let timeStep: CGFloat = 5.0

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
        setupRuler()
        setupGestureRecognizers()

        NotificationCenter.default.addObserver(self, selector: #selector(timerDidEnd), name: .timerDidEnd, object: nil)

        // 중앙을 초기 위치로 설정
        scrollView.contentOffset.x = 0
        updateScrollViewOffset()
    }

    private func setupUI() {
        view.addSubview(timeLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(rulerView)
        view.addSubview(indicatorView)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        rulerView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
            scrollView.heightAnchor.constraint(equalToConstant: 50),
            rulerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            rulerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            rulerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            rulerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            rulerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            rulerView.widthAnchor.constraint(equalToConstant: (maxTime / timeStep) * tickInterval + view.bounds.width),
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func setupRuler() {
        let totalTicks = Int(maxTime / timeStep)
        for i in 0...totalTicks {
            let tickView = UIView()
            tickView.backgroundColor = .black
            tickView.translatesAutoresizingMaskIntoConstraints = false
            rulerView.addSubview(tickView)

            NSLayoutConstraint.activate([
                tickView.widthAnchor.constraint(equalToConstant: 2),
                tickView.heightAnchor.constraint(equalToConstant: i % 12 == 0 ? 30 : 15),
                tickView.leadingAnchor.constraint(equalTo: rulerView.leadingAnchor, constant: CGFloat(i) * tickInterval + view.bounds.width / 2),
                tickView.centerYAnchor.constraint(equalTo: rulerView.centerYAnchor)
            ])
        }
    }

    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        scrollView.addGestureRecognizer(panGesture)
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
        let translation = gesture.translation(in: scrollView)
        let newOffsetX = scrollView.contentOffset.x - translation.x
        scrollView.contentOffset.x = max(0, min(newOffsetX, scrollView.contentSize.width - scrollView.bounds.width))
        gesture.setTranslation(.zero, in: scrollView)
        
        let currentOffset = scrollView.contentOffset.x
        let value = round(currentOffset / tickInterval) * timeStep
        timerManager.updateTime(to: TimeInterval(value))
        timeLabel.text = formattedTime(TimeInterval(value))
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
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func playSound() {
        AudioServicesPlaySystemSound(1005)
    }

    private func updateScrollViewOffset() {
        // 스크롤뷰의 초기 오프셋을 설정하여 0초가 중앙에 오도록 조정
        let initialOffsetX = -view.bounds.width / 2
        scrollView.setContentOffset(CGPoint(x: initialOffsetX, y: 0), animated: false)
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
