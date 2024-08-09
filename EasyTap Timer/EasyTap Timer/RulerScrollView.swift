//
//  RulerScrollView.swift
//  EasyTap Timer
//
//  Created by Kim EenSung on 8/8/24.
//

import UIKit

// MARK: - RulerScrollView Class
final class RulerScrollView: UIScrollView {
    
    // MARK: - Properties
    
    /// 눈금자를 표시할 뷰
    private var rulerView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Initializers
    
    /// RulerScrollView 초기화 메서드
    /// - Parameter viewWidth: 메인 뷰(RulerScrollView의 부모 뷰) 너비를 전달받아 활용
    init(viewWidth: CGFloat) {
        super.init(frame: CGRect())
        setupUI(viewWidth: viewWidth)
        setupRuler(viewWidth: viewWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 눈금자 스크롤 뷰의 UI를 설정하는 메서드
    /// - Parameter viewWidth: 메인 뷰(RulerScrollView의 부모 뷰)의 너비
    private func setupUI(viewWidth: CGFloat) {
        addSubview(rulerView)
        
        rulerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rulerView.heightAnchor.constraint(equalTo: heightAnchor),
            rulerView.topAnchor.constraint(equalTo: topAnchor),
            rulerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rulerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rulerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rulerView.widthAnchor.constraint(equalToConstant: TimerConstants.TotalTicks * TimerConstants.TickInterval + viewWidth),
        ])
    }
    
    /// 눈금자 뷰를 설정하는 메서드, 각 틱(tick)을 rulerView에 추가
    /// - Parameter viewWidth: 메인 뷰(RulerScrollView의 부모 뷰)의 너비
    private func setupRuler(viewWidth: CGFloat) {
        let totalTicks = Int(TimerConstants.TotalTicks)
        for i in 0...totalTicks {
            let tickView = UIView()
            tickView.backgroundColor = .black
            tickView.translatesAutoresizingMaskIntoConstraints = false
            rulerView.addSubview(tickView)

            NSLayoutConstraint.activate([
                tickView.widthAnchor.constraint(equalToConstant: 2),
                tickView.heightAnchor.constraint(equalToConstant: i % 12 == 0 ? 30 : 15),  // 큰 틱과 작은 틱의 높이 설정
                tickView.leadingAnchor.constraint(equalTo: rulerView.leadingAnchor, constant: CGFloat(i) * TimerConstants.TickInterval + viewWidth / 2),
                tickView.centerYAnchor.constraint(equalTo: rulerView.centerYAnchor)
            ])
        }
    }
}
