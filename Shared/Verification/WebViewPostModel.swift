//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import Combine
import Connect
import UIKit
import WebKit

/// The WebView form-POST check, shared by both samples' WebView POST screens.
///
/// It probes whether the SDK's WebView capture turns a form POST into a GET:
/// the capture path reloaded the WebView's current URL to grab the layout, and
/// reloading a POST result re-issues it as a GET — which a customer saw as
/// HTTP 405 on payment submission. The endpoint here only answers POST, so a
/// replayed GET comes back 405, the customer's exact symptom.
///
/// The form is inline HTML, so the only network dependency is the echo
/// endpoint. Point ``echoURL`` elsewhere if the device has no route to the
/// public internet.
@MainActor
final class WebViewPostModel: NSObject, ObservableObject {

    /// The endpoint the form posts to. It rejects GET with 405.
    static let echoURL = "https://httpbin.org/post"

    /// Identical to `FORM_HTML` in the React Native sample's
    /// `WebViewPostScreen.tsx`.
    static let formHTML = """
        <!doctype html>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body { font: 15px -apple-system, Roboto, sans-serif; margin: 16px; color: #1F1E5D; }
          input, button { font-size: 16px; padding: 10px; width: 100%; box-sizing: border-box; margin-bottom: 10px; }
          button { background: #706CFF; color: #fff; border: 0; border-radius: 8px; font-weight: 700; }
          .note { color: #5A5D77; font-size: 13px; }
        </style>
        <h3>Payment form</h3>
        <p class="note">Submits a POST. The endpoint rejects GET with 405, so a
        replayed-as-GET reload is unmistakable.</p>
        <form method="POST" action="\(echoURL)">
          <input name="card" value="4111111111111111">
          <input name="amount" value="42.00">
          <button type="submit">Submit payment</button>
        </form>
        """

    /// What the last action or navigation did, or `nil` before the form is
    /// submitted.
    @Published private(set) var status: String?

    /// How many navigations have finished since the form was last loaded. A
    /// capture-driven reload shows up as one more than the submission explains.
    @Published private(set) var navigations = 0

    /// The web view both screens embed.
    let webView: WKWebView

    override init() {
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        super.init()
        webView.navigationDelegate = self
        webView.accessibilityIdentifier = SampleID.WebView.webView
        loadForm()
    }

    /// The status line as the screen prints it.
    var statusText: String {
        Self.statusText(status)
    }

    /// Formats a status for the status line.
    ///
    /// A subscriber to `$status` receives the new value before the property
    /// changes, so it formats the value it is given rather than reading
    /// ``statusText``.
    ///
    /// - Parameter status: The status to show, or `nil` before a submission.
    /// - Returns: The line to print.
    static func statusText(_ status: String?) -> String {
        status ?? "submit the form below"
    }

    /// Submits the form.
    ///
    /// The page's DOM is not in the accessibility tree, so tapping the HTML
    /// button by coordinate is unreliable and unautomatable. Submitting through
    /// JavaScript is deterministic and lets a test driver trigger the POST the
    /// way a person would.
    func submit() {
        status = "submitting…"
        webView.evaluateJavaScript("document.forms[0].submit(); true;")
    }

    /// Captures the screen's layout now, which is what triggered the reload
    /// that replayed the POST as a GET.
    ///
    /// Nothing captures by itself here: the configured trigger is a screen
    /// change, and submitting the form does not change screens. Without this
    /// the check passes on a broken build too.
    ///
    /// The capture records what is on screen and skips subtrees outside the
    /// viewport, so the web view has to be scrolled fully into view first, or
    /// the layout holds no web view nodes at all.
    func captureLayout() {
        guard let viewController = owningViewController() else {
            status = "no view controller to capture"
            return
        }
        status = "capturing layout…"
        ConnectCustomEvent.sharedInstance().logScreenLayout(
            with: viewController,
            andDelay: 0,
            andName: BehaviourRoute.webViewPost.screenName
        )
    }

    /// Loads the form again and clears the status.
    func reset() {
        status = nil
        navigations = 0
        loadForm()
    }

    // MARK: - Private

    private func loadForm() {
        webView.loadHTMLString(Self.formHTML, baseURL: URL(string: "https://httpbin.org"))
    }

    private func owningViewController() -> UIViewController? {
        var responder: UIResponder? = webView
        while let next = responder?.next {
            if let viewController = next as? UIViewController {
                return viewController
            }
            responder = next
        }
        return nil
    }
}

// MARK: - WKNavigationDelegate

extension WebViewPostModel: WKNavigationDelegate {

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void
    ) {
        if let response = navigationResponse.response as? HTTPURLResponse, response.statusCode >= 400 {
            let url = response.url?.absoluteString ?? "?"
            status = "HTTP \(response.statusCode) on \(url)"
                + (response.statusCode == 405 ? " — POST was replayed as GET" : "")
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigations += 1
        if let url = webView.url?.absoluteString, url.contains("/post"), status?.hasPrefix("HTTP") != true {
            status = "loaded \(url) — the POST-only endpoint answered, so the request stayed a POST"
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        status = "error: \(error.localizedDescription)"
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        status = "error: \(error.localizedDescription)"
    }
}
