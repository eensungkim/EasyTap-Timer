//
//  RulerScrollView.swift
//  EasyTap Timer
//
//  Created by Kim EenSung on 8/8/24.
//

import UIKit

final class RulerScrollView: UIScrollView {
    private var rulerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let TICK_INTERVAL: CGFloat = 10.0
    let MAX_TIME: CGFloat = 600.0
    let TIME_STEP: CGFloat = 5.0
    
    init(viewWidth: CGFloat) {
        super.init(frame: CGRect())
        setupUI(viewWidth: viewWidth)
        setupRuler(viewWidth: viewWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(viewWidth: CGFloat) {
        addSubview(rulerView)
        
        rulerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rulerView.heightAnchor.constraint(equalTo: heightAnchor),
            rulerView.topAnchor.constraint(equalTo: topAnchor),
            rulerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rulerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rulerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rulerView.widthAnchor.constraint(equalToConstant: (MAX_TIME / TIME_STEP) * TICK_INTERVAL + viewWidth),
        ])
    }
    
    private func setupRuler(viewWidth: CGFloat) {
        let totalTicks = Int(MAX_TIME / TIME_STEP)
        for i in 0...totalTicks {
            let tickView = UIView()
            tickView.backgroundColor = .black
            tickView.translatesAutoresizingMaskIntoConstraints = false
            rulerView.addSubview(tickView)

            NSLayoutConstraint.activate([
                tickView.widthAnchor.constraint(equalToConstant: 2),
                tickView.heightAnchor.constraint(equalToConstant: i % 12 == 0 ? 30 : 15),
                tickView.leadingAnchor.constraint(equalTo: rulerView.leadingAnchor, constant: CGFloat(i) * TICK_INTERVAL + viewWidth / 2),
                tickView.centerYAnchor.constraint(equalTo: rulerView.centerYAnchor)
            ])
        }
    }
}
