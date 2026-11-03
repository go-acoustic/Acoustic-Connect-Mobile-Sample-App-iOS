//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import Connect
import SwiftUI

struct GesturesView: View {

    @State private var status = SampleGesture.statusText()
    @State private var zoom: CGFloat = 1
    @GestureState private var pinchMagnification: CGFloat = 1

    var body: some View {
        VStack(spacing: 12) {
            // connectIdentifier adds a second element with this id and an empty text.
            Text(status)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(Color("violet"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(SampleID.Gestures.last)

            GestureTarget(label: "Long press me", identifier: SampleID.Gestures.longPress)
                .onTapGesture { report(SampleGesture.tap) }
                .onLongPressGesture { report(SampleGesture.longPress) }

            GestureTarget(label: "Double tap me", identifier: SampleID.Gestures.doubleTap)
                .onTapGesture(count: 2) { report(SampleGesture.doubleTap) }

            GestureTarget(label: "Swipe me — any direction", identifier: SampleID.Gestures.swipe)
                .gesture(
                    DragGesture().onEnded { value in
                        if let name = SampleGesture.swipeName(travel: value.translation) {
                            report(name)
                        }
                    }
                )
                .padding(.horizontal, SampleGesture.swipeInset)

            Image("logo")
                .resizable()
                .scaledToFit()
                .padding(12)
                .scaleEffect(SampleGesture.zoomed(zoom, by: pinchMagnification))
                .frame(width: SampleGesture.pinchSlot, height: SampleGesture.pinchSlot)
                .background(Color("lightGrey"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(Rectangle())
                .gesture(pinch)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Pinch to zoom")
                .connectIdentifier(SampleID.Gestures.pinchZoom)

            rows
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color("background"))
    }

    private var pinch: some Gesture {
        MagnificationGesture()
            .updating($pinchMagnification) { magnification, state, _ in
                state = magnification
            }
            .onChanged { magnification in
                if let name = SampleGesture.zoomName(magnification: magnification) {
                    report(name)
                }
            }
            .onEnded { magnification in
                zoom = SampleGesture.zoomed(zoom, by: magnification)
            }
    }

    private var rows: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(0..<SampleGesture.listRows, id: \.self) { index in
                    Text("Scrollable row \(index + 1)")
                        .foregroundStyle(Color("violet"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .connectIdentifier(SampleID.Gestures.row(index))
                }
            }
        }
        .connectIdentifier(SampleID.Gestures.scrollList)
    }

    private func report(_ name: String) {
        status = SampleGesture.statusText(name)
    }
}

private struct GestureTarget: View {

    let label: String
    let identifier: String

    var body: some View {
        Text(label)
            .font(.subheadline)
            .foregroundStyle(Color("violet"))
            .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
            .background(Color("lightGrey"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .contentShape(Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .connectIdentifier(identifier)
    }
}

#Preview {
    NavigationView {
        GesturesView()
    }
}
