//
//  SUKINOTEApp.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct SUKINOTEApp: App {
    var body: some Scene {
        WindowGroup {
            NoteListScreen(
                store: Store(
                    initialState: NoteListScreenReducer.State()
                ) {
                    NoteListScreenReducer()
                }
            )
        }
    }
}
