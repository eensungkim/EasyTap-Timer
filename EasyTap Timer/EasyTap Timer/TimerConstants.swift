//
//  TimerConstants.swift
//  EasyTap Timer
//
//  Created by Kim EenSung on 8/8/24.
//

import Foundation

struct TimerConstants {
    static let TickInterval: CGFloat = 10.0
    static let TimeStep: CGFloat = 5.0
    static let InitialTimerValue: CGFloat = 30.0
    static var TotalTicks: CGFloat {
        get { MaxTime / TimeStep }
    }
    
    private static let MaxTime: CGFloat = 300.0
}
