//
//  LanguageSelectionView.swift
//  mond
//

import SwiftUI

struct LanguageSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = LanguageManager.shared

    var body: some View {
        NavigationStack {
            List(AppLanguage.supported) { language in
                Button {
                    manager.select(language.id)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title(for: language))
                                .font(.body)
                                .foregroundColor(.primary)

                            Text(subtitle(for: language))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if manager.current == language.id {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("AccentColor"))
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
            .navigationTitle(NSLocalizedString("choose_language", tableName: "SettingsView", comment: "Language picker navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text(NSLocalizedString("done", comment: "Done button label"))
                    }
                }
            }
        }
    }

    private func title(for language: AppLanguage) -> String {
        language.id == "system"
            ? NSLocalizedString("system_default", tableName: "SettingsView", comment: "System default language option")
            : language.nativeName
    }

    private func subtitle(for language: AppLanguage) -> String {
        language.id == "system"
            ? NSLocalizedString("system_default_description", tableName: "SettingsView", comment: "System default language description")
            : language.englishName
    }
}