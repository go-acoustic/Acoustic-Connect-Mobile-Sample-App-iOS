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
import UIKit

/// Session-replay reference for a full-screen modal, opaque or transparent.
///
/// A modal is presented by its own view controller rather than pushed onto the
/// navigation stack, so session replay has to resolve its controls outside the
/// stack the rest of the app lives in. The controls are deliberately varied —
/// text, a bordered text field, two buttons and a status line — so a replay
/// reviewer can confirm each one is individually inspectable rather than just
/// seeing a correct-looking screenshot.
///
/// The status line echoes the note and the action count, so an interaction that
/// never registered can be told apart from one the SDK failed to capture.
///
/// The two variants mirror React Native's `transparent` prop, which maps to an
/// opaque full-screen presentation or to `UIModalPresentationOverFullScreen`.
/// SwiftUI's `fullScreenCover` is always opaque before iOS 16.4, and these
/// samples deploy to iOS 15.1, so the transparent variant presents a hosting
/// controller over full screen through UIKit — the presentation React Native
/// itself produces.
struct ReplayModalCard: View {

    /// Whether the modal shows the screen beneath it through a dimmed
    /// backdrop.
    var transparent = false

    /// The screen name to restore when the modal closes — the screen the card
    /// sits on.
    ///
    /// Dismissing a full-screen cover does not re-run the presenting screen's
    /// `onAppear`, so without this the next screen view would still carry the
    /// modal's name.
    let returnScreenName: String

    @State private var isPresented = false

    var body: some View {
        DemoCard(title: transparent ? "Modal (transparent)" : "Modal (opaque)") {
            VStack(alignment: .leading, spacing: 10) {
                CardBodyText("""
                    Opens a full-screen modal. Every element inside it should be \
                    selectable in session replay, not just visible in the \
                    screenshot.
                    """)

                Button("Open modal") {
                    open()
                }
                .buttonStyle(PrimaryButtonStyle())
                .connectIdentifier(
                    transparent ? SampleID.ReplayModal.openTransparent : SampleID.ReplayModal.openOpaque
                )
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            ReplayModalContent(transparent: false) {
                SampleScreenNaming.nameCurrentScreen(returnScreenName)
                isPresented = false
            }
        }
    }

    private func open() {
        guard transparent else {
            isPresented = true
            return
        }
        let returnScreenName = returnScreenName
        OverFullScreenPresenter.present { dismiss in
            ReplayModalContent(transparent: true) {
                SampleScreenNaming.nameCurrentScreen(returnScreenName)
                dismiss()
            }
        }
    }
}

/// Presents SwiftUI content over full screen, with the presenting screen left
/// visible beneath it.
@MainActor
private enum OverFullScreenPresenter {

    /// Presents `content` from the frontmost view controller.
    ///
    /// - Parameter content: Builds the content, given the action that
    ///   dismisses it.
    static func present<Content: View>(_ content: (@escaping () -> Void) -> Content) {
        guard let presenter = frontmostViewController() else { return }
        let holder = PresentedController()
        let host = UIHostingController(rootView: content {
            holder.controller?.dismiss(animated: true)
        })
        holder.controller = host
        host.modalPresentationStyle = .overFullScreen
        host.view.backgroundColor = .clear
        presenter.present(host, animated: true)
    }

    private static func frontmostViewController() -> UIViewController? {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        var controller = window?.rootViewController
        while let presented = controller?.presentedViewController {
            controller = presented
        }
        return controller
    }

    /// Lets the dismiss action reach the controller it is created before.
    private final class PresentedController {
        weak var controller: UIViewController?
    }
}

/// The modal's contents — on the sample's background colour when opaque, over
/// a dimmed view of the screen beneath when transparent.
private struct ReplayModalContent: View {

    let transparent: Bool
    let close: () -> Void

    @State private var note = ""
    @State private var actionCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Modal content")
                .font(.headline)
                .foregroundStyle(Color("violet"))

            CardBodyText("""
                Text, a field and buttons — each should appear as its own control \
                in the captured layout.
                """)

            DemoTextField(
                label: "Note",
                placeholder: "Type to check text capture",
                text: $note,
                identifier: SampleID.ReplayModal.note
            )

            Button("Primary action") {
                actionCount += 1
            }
            .buttonStyle(PrimaryButtonStyle())
            .connectIdentifier(SampleID.ReplayModal.action)

            Button("Close", action: close)
                .buttonStyle(SecondaryButtonStyle())
                .connectIdentifier(SampleID.ReplayModal.close)

            Text("Note: \(note.isEmpty ? "—" : note) · Primary action taps: \(actionCount)")
                .font(.caption)
                .foregroundStyle(Color("violet"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .connectIdentifier(SampleID.ReplayModal.result)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(transparent ? Color("violet").opacity(0.45) : Color("background"))
        .logsScreenView(named: BehaviourRoute.replayModalScreenName)
    }
}

#Preview {
    VStack(spacing: 20) {
        ReplayModalCard(returnScreenName: BehaviourRoute.showcase.screenName)
        ReplayModalCard(transparent: true, returnScreenName: BehaviourRoute.showcase.screenName)
    }
    .padding()
}
