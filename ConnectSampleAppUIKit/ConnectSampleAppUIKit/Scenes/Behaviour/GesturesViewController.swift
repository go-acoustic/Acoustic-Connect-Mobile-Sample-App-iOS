//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import UIKit

@MainActor
final class GesturesViewController: UIViewController {

    private let statusLabel = makeResultLabel(identifier: SampleID.Gestures.last)
    private let pinchImage = UIImageView(image: UIImage(named: "logo"))
    private var zoom: CGFloat = 1
    private var zoomAtPinchStart: CGFloat = 1
    private var swipeStart = CGPoint.zero

    init() {
        super.init(nibName: nil, bundle: nil)
        title = BehaviourRoute.gestures.title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SampleScreenNaming.nameCurrentScreen(BehaviourRoute.gestures.screenName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "background")

        let list = makeRowList()
        let targets = makeTargets()
        view.addSubview(list)
        view.addSubview(targets)

        NSLayoutConstraint.activate([
            targets.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            targets.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            targets.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            list.topAnchor.constraint(equalTo: targets.bottomAnchor, constant: 12),
            list.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            list.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            list.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func makeTargets() -> UIStackView {
        statusLabel.text = SampleGesture.statusText()
        statusLabel.isHidden = false

        let longPress = makeTarget(label: "Long press me", identifier: SampleID.Gestures.longPress)
        longPress.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        longPress.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress)))

        let doubleTap = makeTarget(label: "Double tap me", identifier: SampleID.Gestures.doubleTap)
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTap.addGestureRecognizer(doubleTapRecognizer)

        let swipe = makeTarget(label: "Swipe me — any direction", identifier: SampleID.Gestures.swipe)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        pan.delegate = self
        swipe.addGestureRecognizer(pan)

        let swipeHolder = UIView()
        swipeHolder.addSubview(swipe)
        swipe.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            swipe.topAnchor.constraint(equalTo: swipeHolder.topAnchor),
            swipe.bottomAnchor.constraint(equalTo: swipeHolder.bottomAnchor),
            swipe.leadingAnchor.constraint(equalTo: swipeHolder.leadingAnchor, constant: SampleGesture.swipeInset),
            swipe.trailingAnchor.constraint(equalTo: swipeHolder.trailingAnchor, constant: -SampleGesture.swipeInset)
        ])

        let stack = UIStackView(arrangedSubviews: [statusLabel, longPress, doubleTap, swipeHolder, makePinchTarget()])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func makeTarget(label: String, identifier: String) -> UIView {
        let caption = UILabel()
        caption.text = label
        caption.font = .preferredFont(forTextStyle: .subheadline)
        caption.textColor = UIColor(named: "violet")
        caption.translatesAutoresizingMaskIntoConstraints = false

        let target = UIView()
        target.backgroundColor = UIColor(named: "lightGrey")
        target.layer.cornerRadius = 10
        target.addSubview(caption)
        NSLayoutConstraint.activate([
            target.heightAnchor.constraint(equalToConstant: 72),
            caption.centerXAnchor.constraint(equalTo: target.centerXAnchor),
            caption.centerYAnchor.constraint(equalTo: target.centerYAnchor)
        ])
        target.isAccessibilityElement = true
        target.accessibilityLabel = label
        target.accessibilityIdentifier = identifier
        return target
    }

    private func makePinchTarget() -> UIView {
        pinchImage.contentMode = .scaleAspectFit
        pinchImage.translatesAutoresizingMaskIntoConstraints = false

        let slot = UIView()
        slot.backgroundColor = UIColor(named: "lightGrey")
        slot.layer.cornerRadius = 10
        slot.clipsToBounds = true
        slot.isAccessibilityElement = true
        slot.accessibilityLabel = "Pinch to zoom"
        slot.accessibilityIdentifier = SampleID.Gestures.pinchZoom
        slot.translatesAutoresizingMaskIntoConstraints = false
        slot.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(didPinch)))
        slot.addSubview(pinchImage)

        let holder = UIView()
        holder.addSubview(slot)
        NSLayoutConstraint.activate([
            holder.heightAnchor.constraint(equalToConstant: SampleGesture.pinchSlot),
            slot.widthAnchor.constraint(equalToConstant: SampleGesture.pinchSlot),
            slot.heightAnchor.constraint(equalToConstant: SampleGesture.pinchSlot),
            slot.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
            slot.centerYAnchor.constraint(equalTo: holder.centerYAnchor),
            pinchImage.topAnchor.constraint(equalTo: slot.topAnchor, constant: 12),
            pinchImage.bottomAnchor.constraint(equalTo: slot.bottomAnchor, constant: -12),
            pinchImage.leadingAnchor.constraint(equalTo: slot.leadingAnchor, constant: 12),
            pinchImage.trailingAnchor.constraint(equalTo: slot.trailingAnchor, constant: -12)
        ])
        return holder
    }

    private func makeRowList() -> UIScrollView {
        let rows = UIStackView()
        rows.axis = .vertical
        rows.spacing = 4
        rows.translatesAutoresizingMaskIntoConstraints = false
        for index in 0..<SampleGesture.listRows {
            rows.addArrangedSubview(
                makeBodyLabel("Scrollable row \(index + 1)", style: .body, identifier: SampleID.Gestures.row(index))
            )
        }

        let list = UIScrollView()
        list.translatesAutoresizingMaskIntoConstraints = false
        list.accessibilityIdentifier = SampleID.Gestures.scrollList
        list.addSubview(rows)
        NSLayoutConstraint.activate([
            rows.topAnchor.constraint(equalTo: list.contentLayoutGuide.topAnchor),
            rows.bottomAnchor.constraint(equalTo: list.contentLayoutGuide.bottomAnchor),
            rows.leadingAnchor.constraint(equalTo: list.frameLayoutGuide.leadingAnchor),
            rows.trailingAnchor.constraint(equalTo: list.frameLayoutGuide.trailingAnchor)
        ])
        return list
    }

    @objc private func didTap() {
        report(SampleGesture.tap)
    }

    @objc private func didLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            report(SampleGesture.longPress)
        }
    }

    @objc private func didDoubleTap() {
        report(SampleGesture.doubleTap)
    }

    @objc private func didPan(_ recognizer: UIPanGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        let end = recognizer.location(in: recognizer.view)
        let travel = CGSize(width: end.x - swipeStart.x, height: end.y - swipeStart.y)
        if let name = SampleGesture.swipeName(travel: travel) {
            report(name)
        }
    }

    @objc private func didPinch(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .began:
            zoomAtPinchStart = zoom
        case .changed:
            zoom = SampleGesture.zoomed(zoomAtPinchStart, by: recognizer.scale)
            pinchImage.transform = CGAffineTransform(scaleX: zoom, y: zoom)
            if let name = SampleGesture.zoomName(magnification: recognizer.scale) {
                report(name)
            }
        case .cancelled:
            zoom = zoomAtPinchStart
            pinchImage.transform = CGAffineTransform(scaleX: zoom, y: zoom)
        default:
            break
        }
    }

    private func report(_ name: String) {
        statusLabel.text = SampleGesture.statusText(name)
    }
}

extension GesturesViewController: UIGestureRecognizerDelegate {

    // Pan translation starts after the touch slop (~10 pt); measured from touch-down instead.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.state == .possible && gestureRecognizer.numberOfTouches == 0 {
            swipeStart = touch.location(in: gestureRecognizer.view)
        }
        return true
    }
}
