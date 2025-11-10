//
//  SUKINOTEApp.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/24.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct SUKINOTEApp: App {
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .system

    // Shared ModelContainer for the entire app
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Note.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // Shared Store that persists across theme changes
    let store = Store(
        initialState: NoteListScreenReducer.State()
    ) {
        NoteListScreenReducer()
    }

    var body: some Scene {
        WindowGroup {
            NoteListScreen(store: store)
                .preferredColorScheme(selectedTheme.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
