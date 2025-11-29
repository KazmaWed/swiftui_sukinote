//
//  PersonSelectorView.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/11/10.
//

import SwiftUI

struct PersonSelectorView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                Text("Person Selector")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Select a person to filter notes.\nThis feature is coming soon.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
            .navigationTitle("Select Person")
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
    PersonSelectorView()
}
