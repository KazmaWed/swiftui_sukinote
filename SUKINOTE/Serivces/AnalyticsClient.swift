import FirebaseAnalytics

struct AnalyticsClient {
    var logEvent: (String, [String: Any]?) -> Void
    var logSaveNote: ([String: Any]) -> Void
    var setUserProperty: (String?, String) -> Void
}

extension AnalyticsClient {
    static let live = Self(
        logEvent: { name, params in
            Analytics.logEvent(name, parameters: params)
        },
        logSaveNote: { params in
            Analytics.logEvent("saveNote", parameters: params)
        },
        setUserProperty: { value, property in
            Analytics.setUserProperty(value, forName: property)
        }
    )

    /// No-op client for previews and tests
    static let noop = Self(
        logEvent: { _, _ in },
        logSaveNote: { _ in },
        setUserProperty: { _, _ in }
    )
}
