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
        LockScreenWidget()
        // The codebase's first version check: controls arrived in iOS 18, and the app still deploys
        // to 17.0. An iPhone on 17 simply never offers this one.
        if #available(iOS 18.0, *) {
            LogWaterControl()
        }
    }
}
