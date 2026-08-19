//
//  LanguageManager.swift
//  mond
//

import Foundation
import Combine

struct AppLanguage: Identifiable, Equatable {
    let id: String            // "system", or the .lproj code (en, ru, es, sr)
    let nativeName: String    // Name of the language written in itself
    let englishName: String   // Name of the language written in English

    static let system = AppLanguage(id: "system", nativeName: "", englishName: "")

    // Add a line here whenever a new .lproj is added to the project.
    static let supported: [AppLanguage] = [
        .system,
        AppLanguage(id: "en", nativeName: "English", englishName: "English"),
        AppLanguage(id: "ru", nativeName: "Русский", englishName: "Russian"),
        AppLanguage(id: "es", nativeName: "Español", englishName: "Spanish"),
        AppLanguage(id: "sr", nativeName: "Srpski", englishName: "Serbian"),
    ]
}

@MainActor
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    private static let storageKey = "app_language"

    @Published private(set) var current: String

    private init() {
        current = UserDefaults.standard.string(forKey: Self.storageKey) ?? "system"
        Bundle.mond_setLanguage(current == "system" ? nil : current)
    }

    func select(_ code: String) {
        guard code != current else { return }
        current = code
        UserDefaults.standard.set(code, forKey: Self.storageKey)
        Bundle.mond_setLanguage(code == "system" ? nil : code)
    }
}