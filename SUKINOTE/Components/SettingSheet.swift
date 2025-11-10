//
//  SettingSheet.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/11/10.
//

import SwiftUI

struct SettingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .system

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Appearance", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.displayName)
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Theme")
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("App Information")
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    SettingSheet()
}
