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
import Combine
import Foundation

/// `UserDefaults` key for the persisted identity history.
private let identityHistoryKey = "connectSampleIdentityPairs"

/// Identity signalling for the sample apps.
///
/// Holds no UI, so both the SwiftUI sample and the UIKit sample drive the same
/// code — SwiftUI observes it directly, UIKit subscribes to the publishers.
@MainActor
final class IdentityStore: ObservableObject {

    // MARK: - Shared instance

    static let shared = IdentityStore()

    // MARK: - Types

    /// A name/value pair used in the Identity demo form.
    struct IdentityPair: Codable, Equatable, Identifiable {
        var id: String { name }
        var name: String
        var value: String
    }

    // MARK: - Observable state

    /// The last five logged identity pairs, most recent first.
    @Published private(set) var history: [IdentityPair] = {
        guard
            let data = UserDefaults.standard.data(forKey: identityHistoryKey),
            let saved = try? JSONDecoder().decode([IdentityPair].self, from: data)
        else { return [] }
        return saved
    }()

    /// The result message from the most recent identity log call.
    @Published private(set) var lastResult: String?

    // MARK: - Private

    private init() {}

    // MARK: - Logging

    /// Logs a `loggedIn` identity signal to associate the current device with a known user.
    ///
    /// Call this right after a successful sign-in so Connect can stitch the user's
    /// session to their profile and any subsequent behavioral signals.
    ///
    /// - Parameters:
    ///   - identifierName: The identifier type (for example, `"email"` or `"customerId"`).
    ///   - identifierValue: The identifier value for the signed-in user.
    ///   - additionalParameters: Optional context attached to the signal.
    ///     Defaults to `["loginMethod": "email"]`.
    ///
    /// See: https://developer.goacoustic.com/acoustic-connect/docs/identify-users-at-sign-in-ios
    func logUserLoggedIn(
        identifierName: String,
        identifierValue: String,
        additionalParameters: [String: String] = ["loginMethod": "email"]
    ) {
        log(
            identifierName: identifierName,
            identifierValue: identifierValue,
            signalType: "loggedIn",
            additionalParameters: additionalParameters
        )
    }

    /// Logs an `accountRegistered` identity signal when a new user completes registration.
    ///
    /// Call this once at the end of a successful sign-up flow so Connect can create
    /// the user's profile and begin tracking activity against it.
    ///
    /// - Parameters:
    ///   - identifierName: The identifier type (for example, `"email"` or `"customerId"`).
    ///   - identifierValue: The identifier value for the newly registered user.
    ///   - signalType: The signal name to record. Defaults to `"accountRegistered"`;
    ///     override only when your Connect configuration uses a custom signal.
    ///   - additionalParameters: Optional context attached to the signal.
    ///     Defaults to `["registrationMethod": "email"]`.
    ///
    /// See: https://developer.goacoustic.com/acoustic-connect/docs/identify-users-at-registration-ios
    func logUserRegistered(
        identifierName: String,
        identifierValue: String,
        signalType: String = "accountRegistered",
        additionalParameters: [String: String] = ["registrationMethod": "email"]
    ) {
        log(
            identifierName: identifierName,
            identifierValue: identifierValue,
            signalType: signalType,
            additionalParameters: additionalParameters
        )
    }

    /// Trims and forwards an identity signal to the SDK, updates ``lastResult``,
    /// and prepends the pair to ``history`` (capped at the five most recent).
    ///
    /// Empty or whitespace-only inputs are ignored so the demo form can't submit blanks.
    /// The history is persisted to `UserDefaults` so it survives app restarts.
    ///
    /// - Parameters:
    ///   - identifierName: The identifier type; trimmed before use.
    ///   - identifierValue: The identifier value; trimmed before use.
    ///   - signalType: The Connect identity signal name (for example, `"loggedIn"`).
    ///   - additionalParameters: Context attached to the signal.
    private func log(
        identifierName: String,
        identifierValue: String,
        signalType: String,
        additionalParameters: [String: String]
    ) {
        let trimmedName = identifierName.trimmingCharacters(in: .whitespaces)
        let trimmedValue = identifierValue.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, !trimmedValue.isEmpty else { return }

        let success = ConnectSDK.shared.identity.log(
            identifierName: trimmedName,
            identifierValue: trimmedValue,
            signalType: signalType,
            additionalParameters: additionalParameters
        )
        lastResult = success
            ? "✓ \(trimmedName): \(trimmedValue)"
            : "✗ Failed to log \(trimmedName)"

        let pair = IdentityPair(name: trimmedName, value: trimmedValue)
        var updated = history.filter { $0.name != pair.name }
        updated.insert(pair, at: 0)
        history = Array(updated.prefix(5))
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: identityHistoryKey)
        }
    }
}
