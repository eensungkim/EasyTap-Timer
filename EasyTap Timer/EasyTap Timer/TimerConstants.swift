//
//  TimerConstants.swift
//  EasyTap Timer
//
//  Created by Kim EenSung on 8/8/24.
//

import Foundation

// MARK: - TimerConstants Structure
struct TimerConstants {
    
    // MARK: - Public Constants
    
    /// 타이머 눈금자 간격 (포인트 단위)
    static let TickInterval: CGFloat = 10.0
    
    /// 타이머의 시간 단위
    static let TimeStep: CGFloat = 5.0
    
    /// 초기 타이머 값
    static let InitialTimerValue: CGFloat = 30.0
    
    /// 총 타이머 틱 수 (MaxTime을 TimeStep으로 나눈 값)
    static var TotalTicks: CGFloat {
        get { MaxTime / TimeStep }
    }
    
    // MARK: - Private Constants
    
    /// 타이머의 최대 시간
    private static let MaxTime: CGFloat = 300.0
}
