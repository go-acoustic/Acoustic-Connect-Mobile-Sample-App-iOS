//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

//
// Consumed by the Screen Views screen and its per-case screen. The table is the
// part of the contract that has to match React Native byte for byte, so review
// it against `screenViewCases.ts` on its own.
//

import Foundation

/// How a screen-view case reaches the SDK.
///
/// The two paths are not interchangeable, so a case declares which ones apply.
enum ScreenViewCaseDelivery {
    /// Pushes a screen and logs the name from the route.
    ///
    /// This is the path a customer's app actually takes. It cannot carry a
    /// falsy name — an empty or missing name falls back to the route's own
    /// name, so the empty and null cases are unreachable this way.
    case navigation

    /// Calls `logScreenViewContext(_:withClass:applicationContext:referrer:)`
    /// directly, which emits the exact string given. The only way to exercise
    /// the empty and null names.
    case direct

    /// Both paths.
    case both
}

/// One screen name under test, and what that name probes.
///
/// Background: the platform derives a `pageView` signal from every type-2
/// (screenview) message. That inference was written for web, where the message
/// carries a URL; a native screen view has none, so the inferred signal failed
/// schema validation with `Missing required field: [url] in object:
/// [signalContent]` and every one was discarded to the invalid-signal topic.
/// The server-side rule now falls back to the screenview name when no URL is
/// present, which makes `screenview.name` the input under test.
///
/// ``name`` is the exact string expected to arrive as `screenview.name` in the
/// type-2 message, and therefore as `signalContent.url` on the inferred signal.
/// The values mirror `screens/screenViewCases.ts` in the React Native sample
/// byte for byte, because the point of the exercise is that all three samples
/// log the same names.
struct ScreenViewCase: Identifiable, Hashable {

    /// Stable id — also the identifier suffix, so automation can address a case.
    let id: String

    /// Button label.
    let label: String

    /// The screen name to log.
    ///
    /// `nil` is deliberate: the Android bridge stringifies a null logical page
    /// name, so it should arrive as the literal text `"null"` rather than as
    /// absent. iOS drops the message instead — a platform difference this case
    /// exists to record. iOS drops an empty name the same way: the SDK refuses
    /// a missing or empty name and the direct call returns `false`, so neither
    /// reaches the collector from these apps.
    let name: String?

    /// What this case probes on the server side.
    let probes: String

    /// Which delivery paths apply.
    let delivery: ScreenViewCaseDelivery
}

/// The screen-name test matrix, in the order the sample renders it.
enum ScreenViewCases {

    /// Exactly 300 characters, to probe any max-length bound on the url attribute.
    private static let longName = String(String(repeating: "Lot 4815 ", count: 34).prefix(300))

    /// Plausible drill-down screens for an auction/retail app — the shape the
    /// reporting customer's bidder app actually produces. The happy path:
    /// ordinary names, one with a space, repeated visits as you navigate back
    /// and forth.
    static let realistic: [ScreenViewCase] = [
        ScreenViewCase(
            id: "catalog",
            label: "Catalog",
            name: "Catalog",
            probes: "Baseline. A bare word is not a URL — proves the schema accepts a non-URL string in url at all.",
            delivery: .navigation
        ),
        ScreenViewCase(
            id: "product_details",
            label: "Product Details",
            name: "Product Details",
            probes: "Space in the name. Most common real-world shape; a naive URL normaliser may reject or escape it.",
            delivery: .navigation
        ),
        ScreenViewCase(
            id: "bid_confirmation",
            label: "Bid Confirmation",
            name: "Bid Confirmation",
            probes: "Second spaced name, so repeat vs distinct url values can be told apart in Signal Management.",
            delivery: .navigation
        ),
        ScreenViewCase(
            id: "checkout",
            label: "Checkout",
            name: "Checkout",
            probes: "Terminal screen. Visited more than once via back-navigation, to check repeat urls all stay valid.",
            delivery: .navigation
        )
    ]

    /// Name shapes that could still defeat the fallback. Ugly on purpose — each
    /// one answers a specific question about the server-side rule, and the
    /// blank and null cases are the two most likely to still land in the DLQ.
    static let edge: [ScreenViewCase] = [
        ScreenViewCase(
            id: "reserved_chars",
            label: "URL-reserved characters",
            name: "Order #4815 & Refund?ref=a/b",
            probes: "Contains ? & # / — if the rule parses the value as a URL, the query/fragment split may truncate or reject it.",
            delivery: .both
        ),
        ScreenViewCase(
            id: "non_ascii",
            label: "Non-ASCII + emoji",
            name: "Płatności ✓ 🛒",
            probes: "Multi-byte characters. Probes encoding through the collector, the rule, and the schema validator.",
            delivery: .both
        ),
        ScreenViewCase(
            id: "long",
            label: "300-character name",
            name: longName,
            probes: "Any max-length bound on the url attribute. A truncation would show as a clipped url; a bound would show as invalid.",
            delivery: .both
        ),
        ScreenViewCase(
            id: "url_shaped",
            label: "Already URL-shaped",
            name: "https://app.example.com/looks-like-a-url",
            probes: "Name that is already a URL — confirms the rule does not prefix or wrap a value that needs no fallback treatment.",
            delivery: .both
        ),
        ScreenViewCase(
            id: "whitespace",
            label: "Whitespace only",
            name: "   ",
            probes: "Non-empty but semantically blank. Passes a null check, so it may produce a valid-but-useless url.",
            delivery: .both
        ),
        ScreenViewCase(
            id: "empty",
            label: "Empty name",
            name: "",
            probes: "The highest-risk case. TLTRN maps an undefined route name to '', so a real app can emit this — and an empty url may still fail the required-field check.",
            delivery: .direct
        ),
        ScreenViewCase(
            id: "null",
            label: "Null name",
            name: nil,
            probes: "Android stringifies a null name, so url should read literally \"null\". iOS drops the message instead — a platform difference worth recording.",
            delivery: .direct
        )
    ]

    /// Every case, realistic first.
    static let all: [ScreenViewCase] = realistic + edge

    /// Cases reachable by navigating to a screen that carries the name.
    static let navigation: [ScreenViewCase] = all.filter {
        $0.delivery == .navigation || $0.delivery == .both
    }

    /// Cases that must go through the direct call to keep the exact string.
    static let direct: [ScreenViewCase] = all.filter {
        $0.delivery == .direct || $0.delivery == .both
    }

    /// The first navigation case other than `screenViewCase`, which a case
    /// screen pushes to build a deeper stack.
    ///
    /// Deliberately not "the next case in order": this is React Native's
    /// `NAV_CASES.find((entry) => entry.id !== caseId)`, so all three samples
    /// offer the same push from the same screen. The button exists to deepen
    /// the stack, not to walk the list.
    ///
    /// - Parameter screenViewCase: The case on screen.
    /// - Returns: The case to push next, or `nil` if there is none.
    static func next(after screenViewCase: ScreenViewCase) -> ScreenViewCase? {
        navigation.first { $0.id != screenViewCase.id }
    }

    /// A name as the screens print it, so a blank or null one is visible rather
    /// than invisible. Matches `describeName` in the React Native sample's
    /// `DirectScreenViewCard.tsx`.
    ///
    /// - Parameter name: The name to describe.
    /// - Returns: The printable form.
    static func describe(_ name: String?) -> String {
        guard let name else { return "(null)" }
        if name.isEmpty { return "(empty string)" }
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return "(whitespace ×\(name.utf16.count))"
        }
        if name.utf16.count > 48 {
            // React Native slices the first 45 UTF-16 units and counts the whole
            // name in UTF-16 units; this does the same, but stops at the last
            // whole character that fits, so it never splits a surrogate pair
            // or a grapheme. For ASCII names the output is identical.
            return "\(prefix(of: name, utf16Units: 45))… (\(name.utf16.count) chars)"
        }
        return name
    }

    /// The longest run of whole characters from the start of `name` that fits
    /// in `limit` UTF-16 units.
    private static func prefix(of name: String, utf16Units limit: Int) -> Substring {
        var units = 0
        var end = name.startIndex
        for character in name {
            units += character.utf16.count
            guard units <= limit else { break }
            end = name.index(after: end)
        }
        return name[..<end]
    }

    /// Looks a case up by id, for a screen restored from its route.
    ///
    /// - Parameter id: The ``ScreenViewCase/id`` to find.
    /// - Returns: The matching case, or `nil` when no case carries that id.
    static func with(id: String) -> ScreenViewCase? {
        all.first { $0.id == id }
    }
}
