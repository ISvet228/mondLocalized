import SwiftUI

struct LanguageView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = LanguageManager.shared

    @State private var show_restart_alert = false

    var body: some View {
        NavigationStack {
            List(AppLanguage.supported) { language in
                Button {
                    guard language.id != manager.current else { return }
                    manager.select(language.id)
                    show_restart_alert = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title(for: language)).font(.body).foregroundColor(.primary)

                            Text(subtitle(for: language)).font(.subheadline).foregroundStyle(.secondary)
                        }

                        Spacer()

                        if manager.current == language.id {
                            Image(systemName: "checkmark").fontWeight(.semibold).foregroundStyle(Color("AccentColor"))
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
            .navigationTitle(NSLocalizedString("choose_language", tableName: "LanguageView", comment: "Language picker navigation title"))
            .navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text(NSLocalizedString("done", comment: "Done button label"))
                    }
                }
            }
            .alert(
                NSLocalizedString("restart_required", tableName: "LanguageView", comment: "Restart required alert title"),
                isPresented: $show_restart_alert
            ) {
                Button(NSLocalizedString("exit", tableName: "LanguageView", comment: "Exit button label"), role: .destructive) {
                    exit(0)
                }
            } message: {
                Text(NSLocalizedString("restart_required_message", tableName: "LanguageView", comment: "Restart required alert message"))
            }
        }.interactiveDismissDisabled(show_restart_alert)
    }

    private func title(for language: AppLanguage) -> String {
        language.id == "system"
            ? NSLocalizedString("system_default", tableName: "LanguageView", comment: "System default language option")
            : language.nativeName
    }

    private func subtitle(for language: AppLanguage) -> String {
        language.id == "system"
            ? NSLocalizedString("system_default_description", tableName: "LanguageView", comment: "System default language description")
            : language.localizationCredits
    }
}