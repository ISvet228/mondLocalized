//
//  Bundle+Language.swift
//  mond
//
//  Allows overriding the language used by NSLocalizedString at runtime,
//  independent of the device's system language.
//

import Foundation
import ObjectiveC

private var associatedBundleKey: UInt8 = 0

private final class LanguageBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &associatedBundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    // Swaps Bundle.main's class exactly once so our override above starts
    // intercepting every NSLocalizedString(...) call from then on.
    private static let mond_swizzleOnce: Void = {
        object_setClass(Bundle.main, LanguageBundle.self)
    }()

    /// Overrides the language `NSLocalizedString` resolves to.
    /// Pass `nil` (or an unknown code) to go back to following the
    /// device's own language settings.
    static func mond_setLanguage(_ code: String?) {
        _ = mond_swizzleOnce

        guard let code,
              let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let overrideBundle = Bundle(path: path) else {
            objc_setAssociatedObject(Bundle.main, &associatedBundleKey, nil, .OBJC_ASSOCIATION_RETAIN)
            return
        }

        objc_setAssociatedObject(Bundle.main, &associatedBundleKey, overrideBundle, .OBJC_ASSOCIATION_RETAIN)
    }
}