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
import WebKit

/// WebView POST screen — checks that the SDK's WebView capture does not turn a
/// form POST into a GET. Pushed from the Verification screen.
///
/// The check itself lives in ``WebViewPostModel``, shared with the UIKit
/// sample; this view only lays it out.
struct WebViewPostView: View {

    @StateObject private var model = WebViewPostModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ScenarioCardView(scenario: Scenarios.webViewPostNotReplayedAsGet) {
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(model.statusText)
                            Text("navigations: \(model.navigations)")
                        }
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(Color("violet"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color("lightGrey"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        Button("Submit payment (POST)") {
                            model.submit()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .connectIdentifier(SampleID.WebView.submit)

                        Button("Capture layout now (triggers the reload)") {
                            model.captureLayout()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .connectIdentifier(SampleID.WebView.capture)

                        Text("""
                            Scroll the WebView fully into view before capturing — the \
                            capture skips off-screen subtrees, so a WebView below the \
                            fold yields a layout with no WebView nodes.
                            """)
                            .font(.caption)
                            .foregroundStyle(Color("darkGrey"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button("Reload form") {
                            model.reset()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .connectIdentifier(SampleID.WebView.reset)
                    }
                }

                DemoCard(title: "WebView") {
                    WebViewContainer(webView: model.webView)
                        .frame(height: 420)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
    }
}

/// Hosts the model's web view. The identifier is set on the `WKWebView` itself,
/// a real UIKit view, so it reaches layout capture without a marker.
private struct WebViewContainer: UIViewRepresentable {

    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    NavigationView {
        WebViewPostView()
    }
}
