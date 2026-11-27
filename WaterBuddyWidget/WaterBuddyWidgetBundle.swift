//
//  WaterBuddyWidgetBundle.swift
//  WaterBuddyWidget
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftUI
import WidgetKit

@main
struct WaterBuddyWidgetBundle: WidgetBundle {

    var body: some Widget {
        WaterBuddyWidget()
        WeekWidget()
        LockScreenWidget()
        // The fourth version check: the Live Activity is iOS 18's, because Apple Watch's small layout is and this
        // builder takes an `if` with no `else` (rule `15-project`). An iPhone on 17 is never offered it.
        if #available(iOS 18.0, *) {
            LiveWaterWidget()
        }
        // The codebase's first version check: controls arrived in iOS 18, and the app still deploys
        // to 17.0. An iPhone on 17 simply never offers this one.
        if #available(iOS 18.0, *) {
            LogWaterControl()
        }
    }
}
