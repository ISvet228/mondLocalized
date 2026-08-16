//
//  mg.swift
//  mond
//
//  Created by ruter on 16.07.26.
//

import SwiftUI
import PartyUI
import Darwin
import MachO
import UIKit

struct mg_tweak {
    let title: String
    let minv: Double?
    let info_t: InfoType?
    let info_msg: String?
    
    let r: (NSMutableDictionary) -> Bool
    let w_on: (NSMutableDictionary) -> Void
    let w_off: (NSMutableDictionary) -> Void
    
    enum InfoType {
        case info
        case warning
        case error
    }
}

extension mg_tweak {
    init<T: Equatable>(title: String, minv: Double? = nil, key: String, value: T) {
        self.init(
            title: title,
            minv: minv,
            info_t: nil,
            info_msg: nil,
            r: { dict in
                guard let current = dict[key] as? T else { return false }
                return current == value
            },
            w_on: { dict in dict[key] = value },
            w_off: { dict in dict.removeObject(forKey: key) }
        )
    }

    init<T: Equatable>(title: String, minv: Double? = nil, keys: [String], value: T) {
        self.init(
            title: title,
            minv: minv,
            info_t: nil,
            info_msg: nil,
            r: { dict in
                guard let key = keys.first,
                      let current = dict[key] as? T
                else {
                    return false
                }
                return current == value
            },
            w_on: { dict in
                for key in keys {
                    dict[key] = value
                }
            },
            w_off: { dict in
                for key in keys {
                    dict.removeObject(forKey: key)
                }
            }
        )
    }

    init<T: Equatable>(title: String, minv: Double? = nil, key: String, value: T, info_t: InfoType, info_msg: String) {
        self.init(
            title: title,
            minv: minv,
            info_t: info_t,
            info_msg: info_msg,
            r: { dict in
                guard let current = dict[key] as? T else { return false }
                return current == value
            },
            w_on: { dict in dict[key] = value },
            w_off: { dict in dict.removeObject(forKey: key) }
        )
    }

    init<T: Equatable>(title: String, minv: Double? = nil, keys: [String], value: T, info_t: InfoType, info_msg: String) {
        self.init(
            title: title,
            minv: minv,
            info_t: info_t,
            info_msg: info_msg,
            r: { dict in
                guard let key = keys.first,
                      let current = dict[key] as? T
                else {
                    return false
                }
                return current == value
            },
            w_on: { dict in
                for key in keys {
                    dict[key] = value
                }
            },
            w_off: { dict in
                for key in keys {
                    dict.removeObject(forKey: key)
                }
            }
        )
    }
}

let all_tweaks: [mg_tweak] = [
    mg_tweak(title: "Enable Dynamic Island Capability", minv: 19.0, key: "YlEtTtHlNesRBMal1CqRaA", value: 1, info_t: .info, info_msg: "An alternate way to enable the Dynamic Island, as used by Nugget."),
    mg_tweak(title: "Always-On Display", minv: 18.0, keys: ["2OOJf1VhaM7NxfRok3HbWQ", "j8/Omm6s1lsmTDFsXjsBfA"], value: 1, info_t: .warning, info_msg: "Can increase screen burn-in risk on devices that don't officially support it."),
    mg_tweak(title: "AOD Vibrancy", minv: 18.0, key: "ykpu7qyhqFweVMKtxNylWA", value: 1, info_t: .info, info_msg: "Turn this on if your Always-On Display renders incorrectly."),
    mg_tweak(title: "Disable Wallpaper Parallax", key: "UIParallaxCapability", value: 0, info_t: .info, info_msg: "Prevents the wallpaper from moving when you tilt or move the device."),
    mg_tweak(title: "Enable Liquid Glass Low-Performance Mode", minv: 19.0, key: "SAGvsp6O6kAQ4fEfDJpC4Q", value: 1, info_t: .info, info_msg: "Intended for iOS 26 and newer."),
    mg_tweak(title: "Disable Liquid Glass Low-Performance Mode", minv: 19.0, key: "SAGvsp6O6kAQ4fEfDJpC4Q", value: 0, info_t: .info, info_msg: "Don't use this at the same time as the option above."),
    mg_tweak(title: "Boot & Shutdown Chime", key: "QHxt+hGLaBPbQJbXiUJX3w", value: 1, info_t: .info, info_msg: "Adds the chime sound when the device powers on or shuts down."),
    mg_tweak(title: "Charge Limit Menu", minv: 17.0, key: "37NVydb//GP/GrhuTN+exg", value: 1, info_t: .info, info_msg: "Reveals the Settings menu; whether it actually limits charging depends on your hardware."),
    mg_tweak(title: "Tap to Wake", key: "yZf3GTRMGTuwSV/lD7Cagw", value: 1, info_t: .info, info_msg: "Meant for devices like the iPhone SE where tapping to wake isn't otherwise available."),
    mg_tweak(title: "iPhone 16 Camera Control Settings", minv: 18.0, keys: ["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"], value: 1, info_t: .info, info_msg: "Exposes the Camera Control settings and its related capabilities."),
    mg_tweak(title: "Apple Pencil Settings", key: "yhHcB0iH0d1XzPO/CFd3ow", value: 1, info_t: .info, info_msg: "Reveals the Apple Pencil settings page."),
    mg_tweak(title: "Action Button Settings", minv: 17.0, key: "cT44WE1EohiwRzhsZ8xEsw", value: 1, info_t: .info, info_msg: "Reveals the Action Button settings page."),
    mg_tweak(title: "Collision SOS", key: "HCzWusHQwZDea6nNhaKndw", value: 1, info_t: .info, info_msg: "Reveals the collision detection options in the SOS settings."),
    mg_tweak(title: "Pulse Width Modulation", minv: 19.0, key: "6IejgN+1Fmu5/QrZFOIeNw", value: 1),
    mg_tweak(title: "Security Research Device Mode", minv: 26.0, key: "XYlJKKkj2hztRP1NWWnhlw", value: 1, info_t: .info, info_msg: "Flags the device as an Apple Security Research Device."),
    mg_tweak(title: "Allow iPad Apps", key: "9MZ5AdH43csAUajl/dU+IQ", value: [1, 2], info_t: .info, info_msg: "Allows iPad apps to be installed on iPhone."),
    mg_tweak(title: "Stage Manager Support", key: "qeaj75wk3HF4DwQ8qbIi7g", value: 1, info_t: .info, info_msg: "Flags the device as capable of Stage Manager."),
    mg_tweak(title: "Apple Internal Install", key: "EqrsVvjcYDdxHBiQmGhAWw", value: 1, info_t: .warning, info_msg: "Turns on internal features like the Metal HUD; some services may act up."),
    mg_tweak(title: "Internal Storage View", key: "LBJfwOEzExRxzlAnSuI7eg", value: 1, info_t: .warning, info_msg: "Displays internal files in the Storage settings; can be dangerous on some iPads."),
    
    mg_tweak(
        title: "Disable Region Restrictions",
        minv: nil,
        info_t: .info,
        info_msg: "This tweak may be broken or have no effect on some iOS versions or devices.",
        r: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return false }
            return cache_extra["h63QSdBCiT/z0WU6rdQv6Q"] as? String == "US" &&
                   cache_extra["zHeENZu+wbg7PUprwNwBWg"] as? String == "LL/A"
        },
        w_on: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
            Alertinator.shared.alert(title: "Warning!", body: "Please do not use this feature to bypass region restrictions that would equate to breaking regional laws (e.g. disabling the camera shutter sound). We will NOT be held responsible for enabling any illegal activites!")
            cache_extra["h63QSdBCiT/z0WU6rdQv6Q"] = "US"
            cache_extra["zHeENZu+wbg7PUprNwBWg"] = "LL/A"
        },
        w_off: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
            cache_extra.removeObject(forKey: "h63QSdBCiT/z0WU6rdQv6Q")
            cache_extra.removeObject(forKey: "zHeENZu+wbg7PUprNwBWg")
        }
    ),
    
    mg_tweak(
        title: "Apple Intelligence",
        minv: 18.1,
        info_t: .info,
        info_msg: "How to use this tweak:\n1. Spoof to the model next to the first one supported by Apple Intelligence.\n2. Spoof back to your model.\n3. Spoof to your final model and you should see the Apple Intelligence icon in Settings.\n4. Connect iPhone to power and leave the Settings > Storage tab open for ~1 hour.\n\nNOTE: Do not spoof back.",
        r: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return false }
            return (cache_extra["A62OafQ85EJAiiqKn4agtg"] as? Int) == 1
        },
        w_on: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
            cache_extra["A62OafQ85EJAiiqKn4agtg"] = 1
            Alertinator.shared.alert(
                title: "Apple Intelligence Spoof",
                body: "How to use this tweak:\n1. Spoof to the model next to the first one supported by Apple Intelligence.\n2. Spoof back to your model.\n3. Spoof to your final model and you should see the Apple Intelligence icon in Settings.\n4. Connect iPhone to power and leave the Settings > Storage tab open for ~1 hour.\n\nNOTE: Do not spoof back."
            )
        },
        w_off: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
            cache_extra.removeObject(forKey: "A62OafQ85EJAiiqKn4agtg")
        }
    ),
    
    mg_tweak(
        title: "Enable iPadOS Mode",
        minv: nil,
        info_t: .warning,
        info_msg: "Experimental and high risk; This is a very dangerous tweak to use! If you use an alphanumeric passcode, DO NOT USE THIS TWEAK AT ALL! Please do not turn off \"Show Dock In Stage Manager\" or your device will BOOTLOOP when rotating to landscape! Some users have also reported that enabling the iPadOS UI and then tapping Stage Manager can cause the device to enter Recovery Mode, even when the UI itself appears unchanged. The Settings search bar may move to the top before this happens. With these three things in mind, you may experience general instability, or other major issues such as app data randomly disappearing. But I guess some funny multitasking features that still make the device relatively unusable are cool? Whatever dude, I'm not here to tell you how to use your own device.",
        r: { dict in
            guard let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return false }
            let values: [String: Int] = [
                "mG0AnH/Vy1veoqoLRAIgTA": 1,
                "UCG5MkVahJxG1YULbbd5Bg": 1,
                "ZYqko/XM5zD3XBfN5RmaXA": 1,
                "nVh/gwNpy7Jv1NOk00CMrw": 1,
                "uKc7FPnEO++lVhHWHFlGbQ": 1,
            ]
            return values.allSatisfy { key, value in
                (cache_extra[key] as? Int) == value
            }
        },
        w_on: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData,
                  let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
            
            let value_off = cache_data_offset("mtrAoWJ3gsq+I90ZnQ0vQw")
            cache_data.mutableBytes.storeBytes(of: 3, toByteOffset: value_off, as: Int.self)
            
            let values: [String: Int] = [
                "mG0AnH/Vy1veoqoLRAIgTA": 1,
                "UCG5MkVahJxG1YULbbd5Bg": 1,
                "ZYqko/XM5zD3XBfN5RmaXA": 1,
                "nVh/gwNpy7Jv1NOk00CMrw": 1,
                "uKc7FPnEO++lVhHWHFlGbQ": 1,
            ]
            
            for (key, value) in values {
                cache_extra[key] = value
            }
        },
        w_off: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData,
                  let cache_extra = dict["CacheExtra"] as? NSMutableDictionary else { return }
            
            let value_off = cache_data_offset("mtrAoWJ3gsq+I90ZnQ0vQw")
            cache_data.mutableBytes.storeBytes(of: 1, toByteOffset: value_off, as: Int.self)
            
            let keys = ["mG0AnH/Vy1veoqoLRAIgTA", "UCG5MkVahJxG1YULbbd5Bg", "ZYqko/XM5zD3XBfN5RmaXA", "nVh/gwNpy7Jv1NOk00CMrw", "uKc7FPnEO++lVhHWHFlGbQ"]
            for key in keys {
                cache_extra.removeObject(forKey: key)
            }
        }
    ),
    
    mg_tweak(
        title: "Internal Features",
        minv: nil,
        info_t: nil,
        info_msg: nil,
        r: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData else { return false }
            let off_apple_internal_install = cache_data_offset("EqrsVvjcYDdxHBiQmGhAWw")
            return cache_data.bytes.load(fromByteOffset: off_apple_internal_install, as: Int.self) == 1
        },
        w_on: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData else { return }
            let off_apple_internal_install = cache_data_offset("EqrsVvjcYDdxHBiQmGhAWw")
            let off_has_internal_settings_bundle = cache_data_offset("Oji6HRoPi7rH7HPdWVakuw")
            let off_internal_build = cache_data_offset("LBJfwOEzExRxzlAnSuI7eg")
            
            cache_data.mutableBytes.storeBytes(of: 1, toByteOffset: off_apple_internal_install, as: Int.self)
            cache_data.mutableBytes.storeBytes(of: 1, toByteOffset: off_has_internal_settings_bundle, as: Int.self)
            cache_data.mutableBytes.storeBytes(of: 1, toByteOffset: off_internal_build, as: Int.self)
        },
        w_off: { dict in
            guard let cache_data = dict["CacheData"] as? NSMutableData else { return }
            let off_apple_internal_install = cache_data_offset("EqrsVvjcYDdxHBiQmGhAWw")
            let off_has_internal_settings_bundle = cache_data_offset("Oji6HRoPi7rH7HPdWVakuw")
            let off_internal_build = cache_data_offset("LBJfwOEzExRxzlAnSuI7eg")
            
            cache_data.mutableBytes.storeBytes(of: 0, toByteOffset: off_apple_internal_install, as: Int.self)
            cache_data.mutableBytes.storeBytes(of: 0, toByteOffset: off_has_internal_settings_bundle, as: Int.self)
            cache_data.mutableBytes.storeBytes(of: 0, toByteOffset: off_internal_build, as: Int.self)
        }
    )
]

extension mg_tweak {
    func is_on(in dict: NSMutableDictionary) -> Bool { return r(dict) }
    func apply_on(to dict: NSMutableDictionary) { w_on(dict) }
    func apply_off(to dict: NSMutableDictionary) { w_off(dict) }
    
    func supported() -> Bool {
        guard let minv = minv else { return true }
        return doubleSystemVersion() >= minv
    }
}

func is_device_good() -> Bool {
    let supported: [String] = ["iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5", "iPhone16,1", "iPhone16,2", "iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone17,5"]
    
    if supported.contains(machine_name()) && doubleSystemVersion() < 19.0 {
        return true
    }
    
    return false
}

func machine_name() -> String {
    var sys_info = utsname()
    uname(&sys_info)
    let machine_mirror = Mirror(reflecting: sys_info.machine)
    
    return machine_mirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
}

var _cache_data_offsets: [String: Int] = [:]

func cache_data_offset(_ key: String) -> Int {
    if let cached = _cache_data_offsets[key] {
        return cached
    }

    let lib_mg = "/usr/lib/libMobileGestalt.dylib"
    dlopen(lib_mg, RTLD_GLOBAL)

    var header: UnsafePointer<mach_header_64>?
    for i in 0..<_dyld_image_count() {
        if String(cString: _dyld_get_image_name(i)) == lib_mg {
            header = unsafeBitCast(_dyld_get_image_header(i), to: UnsafePointer<mach_header_64>.self)
            break
        }
    }
    guard let header else { return 0 }

    var text_size = 0
    guard let cstring = getsectiondata(header, "__TEXT", "__cstring", &text_size) else { return 0 }
    let cstr = cstring.withMemoryRebound(to: CChar.self, capacity: text_size) { $0 }

    var key_ptr = cstr
    while Int(key_ptr - cstr) < text_size {
        if String(cString: key_ptr) == key { break }
        key_ptr += strlen(key_ptr) + 1
    }

    var const_size = 0
    var ptr = getsectiondata(header, "__AUTH_CONST", "__const", &const_size)?.withMemoryRebound(to: UInt.self, capacity: const_size / 8) { $0 }
    if ptr == nil {
        ptr = getsectiondata(header, "__DATA_CONST", "__const", &const_size)?.withMemoryRebound(to: UInt.self, capacity: const_size / 8) { $0 }
    }

    guard let ptr else { return 0 }
    for i in 0..<const_size / 8 {
        if ptr[i] == UInt(bitPattern: key_ptr) {
            let offset = Int((ptr.advanced(by: i).withMemoryRebound(to: UInt16.self, capacity: 1) { $0[0x9a / 2] }) << 3)
            _cache_data_offsets[key] = offset
            return offset
        }
    }

    _cache_data_offsets[key] = 0
    return 0
}

let state = AppState()

let mg_device_name_key = "mg_device_name"
var mg_device_name: String {
    get {
        UserDefaults.standard.string(forKey: mg_device_name_key) ?? ""
    }
    set {
        UserDefaults.standard.set(newValue, forKey: mg_device_name_key)
    }
}

var og_st: Int = 0
var selected_st: String = "og"

var selected_st_value: Int {
    switch selected_st {
        case "og":
            return og_st
        case "no_dynamic_island":
            return 0
        case "14p":
            return 2436
        case "14pm":
            return 2796
        case "15pm":
            return 2976
        case "16p":
            return 2622
        case "16pm":
            return 2868
        case "air":
            return 2736
        case "x":
            return 2436
        default:
            return 0
    }
}

private var st_to_sel: [Int: String] {
    [
        0: "no_dynamic_island",
        2436: "14p",
        2796: "14pm",
        2976: "15pm",
        2622: "16p",
        2868: "16pm",
        2736: "air"
    ]
}

func tweak(_ title: String) -> mg_tweak? {
    all_tweaks.first { $0.title == title }
}

var is_loading: Bool = false
var is_empty: Bool = false

var enable_device_name: Bool = false
var og_device_name: String = ""
var product_type: String = ""

var is_valid: Bool = true

func mg_load() {
    guard !is_loading, mg_dict_now.count == 0 else { return }
    is_loading = true

    let mg_url_now = URL(fileURLWithPath: TweakPaths.gestalt)

    DispatchQueue.global(qos: .userInitiated).async {
        do {
            let file_size = (try? FileManager.default.attributesOfItem(atPath: mg_url_now.path))?[.size] as? UInt64 ?? 0

            let loaded_dict = try NSMutableDictionary(contentsOf: mg_url_now, error: ())

            // this'll cache gestalt and put it in a safe place
            let mg_url_saved = URL(fileURLWithPath: AppPaths.backups).appendingPathComponent("SavedGestalt.plist")

            if !FileManager.default.fileExists(atPath: mg_url_saved.path) {
                try FileManager.default.copyItem(at: mg_url_now, to: mg_url_saved)
            }

            // get original gestalt values
            let mg_saved_dict = try NSMutableDictionary(contentsOf: mg_url_saved, error: ())
            let og_cache_extra = mg_saved_dict["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
            let og_artwork = og_cache_extra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()

            guard let og_subtype = og_artwork["ArtworkDeviceSubType"] as? Int else { throw mg_view_err.missing_artwork_st }
            guard let og_device_name = og_artwork["ArtworkDeviceProductDescription"] as? String else { throw mg_view_err.missing_artwork_device_name }

            let cache_extra = loaded_dict["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
            let artwork = cache_extra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()

            let new_selected_st = st_to_sel[artwork["ArtworkDeviceSubType"] as? Int ?? og_subtype] ?? "og"
            let new_device_name = artwork["ArtworkDeviceProductDescription"] as? String ?? og_device_name
            let new_enable_device_name = new_device_name != og_device_name

            let new_product_type: String
            if let productType = cache_extra["h9jDsbgj7xIVeIQ8S3/X3Q"] as? String, !productType.isEmpty {
                new_product_type = productType
            } else {
                new_product_type = machine_name()
            }

            DispatchQueue.main.async {
                mg_dict_now = loaded_dict
                og_st = og_subtype
                selected_st = new_selected_st
                mg_device_name = new_device_name
                enable_device_name = new_enable_device_name
                product_type = new_product_type
                is_valid = true
                is_empty = file_size == 0
                is_loading = false
            }
        } catch {
            DispatchQueue.main.async {
                print("(mg) failed to load data: \(error)")
                is_valid = false
                is_empty = (try? FileManager.default.attributesOfItem(atPath: mg_url_now.path))?[.size] as? UInt64 == 0
                is_loading = false
                Alertinator.shared.alert(title: "Failed to load current MobileGestalt!", body: "Restart the app and try again. Check logs for more detailed information.")
            }
        }
    }
}

func mg_apply() {
    do {
        let cache_extra = mg_dict_now["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
        if !product_type.isEmpty {
            cache_extra["h9jDsbgj7xIVeIQ8S3/X3Q"] = product_type
        }
        
        let artwork_dict = cache_extra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()
        artwork_dict["ArtworkDeviceSubType"] = selected_st_value
        if enable_device_name {
            artwork_dict["ArtworkDeviceProductDescription"] = mg_device_name
        }
        
        let data = try PropertyListSerialization.data(fromPropertyList: mg_dict_now, format: .xml, options: 0)

        try mg_write(data)
        mg_dict_now = NSMutableDictionary()
        enable_device_name = false

        print("(mg) successfully overwrote mobilegestalt!")
        Alertinator.shared.alert(title: "Successfully applied Gestalt tweaks!", body: "Respring your device for changes to take effect. Note that some tweaks may require a reboot for them to apply properly.", actionLabel: "Respring", action: {
            state.respring()
        })
    } catch {
        print("(mg) failed to apply mobilegestalt: \(error)")
        Alertinator.shared.alert(title: "Failed to apply MobileGestalt!", body: "Restart the app and try again. Check logs for more detailed information.")
    }
}

func mg_revert() {
    do {
        let backup_url = URL(fileURLWithPath: AppPaths.backups).appendingPathComponent("SavedGestalt.plist")
        let backup_data = try Data(contentsOf: backup_url)
        try mg_write(backup_data)

        print("(mg) successfully reverted mobilegestalt!)")
        Alertinator.shared.alert(title: "Successfully reverted Gestalt tweaks!", body: "Reboot your device for changes to take effect.")
    } catch {
        print("(mg) failed to revert mobilegestalt: \(error)")
        Alertinator.shared.alert(title: "Failed to revert MobileGestalt!", body: "Check logs for error information.")
    }
}

func mg_write(_ data: Data) throws {
    let target_url = URL(fileURLWithPath: TweakPaths.gestalt)
    let temp_url = target_url.deletingLastPathComponent()
        .appendingPathComponent(".\(target_url.lastPathComponent).\(UUID().uuidString).tmp")
    
    try data.write(to: temp_url, options: [.withoutOverwriting])
    defer { try? fm.removeItem(at: temp_url) }
    
    if fm.fileExists(atPath: target_url.path) {
        _ = try fm.replaceItemAt(target_url, withItemAt: temp_url)
    } else {
        try fm.moveItem(at: temp_url, to: target_url)
    }
}

var mg_dict_now: NSMutableDictionary = NSMutableDictionary()

func mg_tweak_binding(_ tweak: mg_tweak) -> Binding<Bool> {
    Binding(
        get: {
            tweak.is_on(in: mg_dict_now)
        },
        set: { enabled in
            if enabled {
                tweak.apply_on(to: mg_dict_now)
            } else {
                tweak.apply_off(to: mg_dict_now)
            }
        }
    )
}

enum mg_view_err: Error, LocalizedError {
    case missing_artwork_st
    case missing_artwork_device_name
    
    var errorDescription: String? {
        switch self {
            case .missing_artwork_st:
                return "Failed to get ArtworkDeviceSubType!"
            case .missing_artwork_device_name:
                return "Failed to get ArtworkDeviceProductDescription!"
        }
    }
}