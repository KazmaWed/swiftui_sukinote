//
//  SUKINOTEApp.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/24.
//

import ComposableArchitecture
import Firebase
import SwiftData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct SUKINOTEApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // Load theme setting from AppStorage
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .system

    // Shared ModelContainer for the entire app
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Note.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // Shared Store that persists across theme changes
    let store = Store(
        initialState: NoteListFeature.State()
    ) {
        NoteListFeature()
    }

    var body: some Scene {
        WindowGroup {
            NoteListView(store: store)
                .preferredColorScheme(selectedTheme.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
