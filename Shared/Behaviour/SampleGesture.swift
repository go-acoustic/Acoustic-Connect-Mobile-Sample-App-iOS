//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import CoreGraphics

enum SampleGesture {

    static let tap = "tap"
    static let longPress = "longPress"
    static let doubleTap = "doubleTap"
    static let zoomIn = "zoomIn"
    static let zoomOut = "zoomOut"

    static let swipeThreshold: CGFloat = 48

    static let swipeInset: CGFloat = 24

    static let pinchSlot: CGFloat = 120

    static let zoomRange: ClosedRange<CGFloat> = 0.5...4

    static let pinchSlop: CGFloat = 0.05

    static let listRows = 40

    static func statusText(_ name: String = "none") -> String {
        "Last gesture: \(name)"
    }

    static func swipeName(travel: CGSize) -> String? {
        let horizontal = abs(travel.width)
        let vertical = abs(travel.height)
        if horizontal < swipeThreshold && vertical < swipeThreshold {
            return nil
        }
        if horizontal >= vertical {
            return travel.width > 0 ? "swipeRight" : "swipeLeft"
        }
        return travel.height > 0 ? "swipeDown" : "swipeUp"
    }

    static func zoomName(magnification: CGFloat) -> String? {
        guard abs(magnification - 1) >= pinchSlop else {
            return nil
        }
        return magnification > 1 ? zoomIn : zoomOut
    }

    static func zoomed(_ zoom: CGFloat, by magnification: CGFloat) -> CGFloat {
        min(max(zoom * magnification, zoomRange.lowerBound), zoomRange.upperBound)
    }
}
