import Dependencies
import FirebaseAnalytics

struct AnalyticsClient {
    var logEvent: (String, [String: Any]?) -> Void
    var logSaveNote: ([String: Any]) -> Void
    var setUserProperty: (String?, String) -> Void
}

extension AnalyticsClient: DependencyKey {
    static let liveValue = Self(
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

    static let testValue = Self(
        logEvent: { _, _ in },
        logSaveNote: { _ in },
        setUserProperty: { _, _ in }
    )
}

extension DependencyValues {
    var analyticsClient: AnalyticsClient {
        get { self[AnalyticsClient.self] }
        set { self[AnalyticsClient.self] = newValue }
    }
}
