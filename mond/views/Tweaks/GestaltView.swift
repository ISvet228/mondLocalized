//
//  GestaltView.swift
//  mond
//
//  Created by ruter on 11.08.26.
//

import Foundation
import SwiftUI
import PartyUI

struct GestaltView: View {
    @EnvironmentObject var state: AppState
    @AppStorage("mg_devicename") private var mg_devicename: String = ""
    
    @State private var mg_dict_now: NSMutableDictionary = NSMutableDictionary()
    @State private var is_valid: Bool = true
    @State private var is_empty: Bool = false
    @State private var is_loading: Bool = false
    
    @State private var og_st: Int = 0
    @State private var selected_st: String = "og"
    
    @State private var enable_devicename: Bool = false
    @State private var og_devicename: String = ""
    @State private var product_type: String = ""
    
    @State private var show_settings: Bool = false
    
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
    
    var body: some View {
        NavigationStack {
            List {
                if !is_valid || is_empty {
                    Section {
                        if is_empty {
                            PlainAlert(title: NSLocalizedStringFromTable("do_not_reboot", "GestaltView", comment: "Warning title"), icon: "exclamationmark.triangle.fill", 
                            text: NSLocalizedStringFromTable("mg_empty_warning", "GestaltView", comment: "Empty gestalt warning"), color: Color.yellow)
                        }
                        
                        if !is_valid {
                            PlainAlert(title: NSLocalizedStringFromTable("do_not_reboot", "GestaltView", comment: "Warning title"), icon: "exclamationmark.triangle.fill", 
                            text: NSLocalizedStringFromTable("mg_invalid_warning", "GestaltView", comment: "Invalid gestalt warning"), color: Color.yellow)
                        }
                    } header: {
                        Label(NSLocalizedStringFromTable("warning", "GestaltView", comment: "Warning section label"), systemImage: "exclamationmark.triangle")
                    } footer: {
                        Text(NSLocalizedStringFromTable("bootloop_warning", "GestaltView", comment: "Bootloop warning text"))
                    }
                }
                
                Section {
                    Button {
                        mg_apply()
                    } label: {
                        Text(NSLocalizedStringFromTable("apply_tweaks", "GestaltView", comment: "Apply tweaks button"))
                    }
                    
                    Button {
                        mg_revert()
                    } label: {
                        Text(NSLocalizedStringFromTable("revert_tweaks", "GestaltView", comment: "Revert tweaks button"))
                    }
                } footer: {
                    Text(NSLocalizedStringFromTable("warning_footer", "GestaltView", comment: "Warning footer text"))
                }
                
                Section {
                    Picker(selection: $selected_st) {
                        Text(String(format: NSLocalizedStringFromTable("original_subtype_format", "GestaltView", comment: "Original subtype label"), og_st)).tag("og")
                        
                        if is_device_good() {
                            Text(NSLocalizedStringFromTable("disable_dynamic_island", "GestaltView", comment: "Disable dynamic island option")).tag("no_dynamic_island")
                        }
                    
                        Text("iPhone 14 Pro").tag("14p")
                        Text("iPhone 14 Pro Max").tag("14pm")
                        Text("iPhone 15 Pro Max").tag("15pm")
                    
                        if doubleSystemVersion() >= 18.0 {
                            Text("iPhone 16 Pro").tag("16p")
                            Text("iPhone 16 Pro Max").tag("16pm")
                        }
                    
                        if doubleSystemVersion() >= 26.0 {
                            Text("iPhone Air").tag("air")
                        }
                    
                        if hasHomeButton() {
                            Text("iPhone X Gestures").tag("x")
                        }
                    } label: {
                        HStack {
                            Text(NSLocalizedStringFromTable("subtype", "GestaltView", comment: "Subtype label"))
                            Spacer()
                        }
                    }
                    
                    Toggle(NSLocalizedStringFromTable("custom_device_name", "GestaltView", comment: "Custom device name toggle"), isOn: $enable_devicename)
                    
                    if enable_devicename {
                        TextField(NSLocalizedStringFromTable("device_name", "GestaltView", comment: "Device name field placeholder"), text: $mg_devicename)
                    }
                } header: {
                    Label(NSLocalizedStringFromTable("device_artwork", "GestaltView", comment: "Device artwork header"), systemImage: "paintbrush.pointed")
                }
                
                // basic tweak toggles
                Section {
                    PlainToggle(text: NSLocalizedStringFromTable("dynamic_island", "GestaltView", comment: "Dynamic Island toggle"), minSupportedVersion: 19.0, isOn: mg_key_binding(["YlEtTtHlNesRBMal1CqRaA"]))
                    PlainToggle(text: NSLocalizedStringFromTable("always_on_display", "GestaltView", comment: "Always On Display toggle"), minSupportedVersion: 18.0, isOn: mg_key_binding(["j8/Omm6s1lsmTDFsXjsBfA", "2OOJf1VhaM7NxfRok3HbWQ"]))
                    PlainToggle(text: NSLocalizedStringFromTable("aod_vibrancy", "GestaltView", comment: "AOD Vibrancy toggle"), minSupportedVersion: 18.0, isOn: mg_key_binding(["ykpu7qyhqFweVMKtxNylWA"]))
                    PlainToggle(text: NSLocalizedStringFromTable("charge_limit", "GestaltView", comment: "Charge Limit toggle"), minSupportedVersion: 17.0, isOn: mg_key_binding(["37NVydb//GP/GrhuTN+exg"]))
                    PlainToggle(text: NSLocalizedStringFromTable("boot_chime", "GestaltView", comment: "Boot Chime toggle"), isOn: mg_key_binding(["QHxt+hGLaBPbQJbXiUJX3w"]))
                    PlainToggle(text: NSLocalizedStringFromTable("liquid_glass_lpm", "GestaltView", comment: "Liquid Glass LPM toggle"), minSupportedVersion: 19.0, isOn: mg_key_binding(["SAGvsp6O6kAQ4fEfDJpC4Q"]))
                } header: {
                    Label(NSLocalizedStringFromTable("software_oriented_features", "GestaltView", comment: "Software features header"), systemImage: "gearshape")
                }
                
                Section {
                    PlainToggle(text: NSLocalizedStringFromTable("camera_control", "GestaltView", comment: "Camera Control toggle"), minSupportedVersion: 18.0, isOn: mg_key_binding(["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"]))
                    PlainToggle(text: NSLocalizedStringFromTable("action_button", "GestaltView", comment: "Action Button toggle"), minSupportedVersion: 17.0, isOn: mg_key_binding(["cT44WE1EohiwRzhsZ8xEsw"]))
                    PlainToggle(text: NSLocalizedStringFromTable("crash_detection", "GestaltView", comment: "Crash Detection toggle"), isOn: mg_key_binding(["HCzWusHQwZDea6nNhaKndw"]))
                    if hasHomeButton() {
                        PlainToggle(text: NSLocalizedStringFromTable("enable_tap_to_wake", "GestaltView", comment: "Tap to wake toggle"), isOn: mg_key_binding(["yZf3GTRMGTuwSV/lD7Cagw"]))
                    }
                    PlainToggle(text: NSLocalizedStringFromTable("pulse_width_modulation", "GestaltView", comment: "PWM toggle"), minSupportedVersion: 19.0, isOn: mg_key_binding(["6IejgN+1Fmu5/QrZFOIeNw"]))
                } header: {
                    Label(NSLocalizedStringFromTable("hardware_oriented_features", "GestaltView", comment: "Hardware features header"), systemImage: "iphone")
                }
                
                Section {
                    PlainToggle(text: NSLocalizedStringFromTable("security_research_device_ui", "GestaltView", comment: "Security Research Device UI toggle"), minSupportedVersion: 26.0, isOn: mg_key_binding(["XYlJKKkj2hztRP1NWWnhlw"]))
                    
                    PlainToggle(
                        text: NSLocalizedStringFromTable("disable_region_restrictions", "GestaltView", comment: "Disable region restrictions toggle"),
                        infoType: .info,
                        infoMessage: NSLocalizedStringFromTable("disable_region_restrictions_info", "GestaltView", comment: "Region restriction info"),
                        isOn: mg_region_restrict_binding()
                    )
                    
                    PlainToggle(
                        text: NSLocalizedStringFromTable("apple_intelligence", "GestaltView", comment: "Apple Intelligence toggle"),
                        infoType: .info,
                        infoMessage: NSLocalizedStringFromTable("apple_intelligence_info", "GestaltView", comment: "Apple intelligence info"),
                        minSupportedVersion: 18.1,
                        isOn: mg_apple_intelligence_binding()
                    )
                    
                    HStack(spacing: 10) {
                        Picker(NSLocalizedStringFromTable("spoofing", "GestaltView", comment: "Spoofing picker label"), selection: $product_type) {
                            Text(NSLocalizedStringFromTable("default_model", "GestaltView", comment: "Default device label")).tag(machine_name())
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                if doubleSystemVersion() >= 17.4 {
                                    Text("iPad Pro 11-inch (M4)").tag("iPad16,3")
                                    Text("iPad Pro 11-inch (M4, Cellular)").tag("iPad16,4")
                                }
                                Text("iPad Pro 11-inch (4th Gen)").tag("iPad14,3")
                                Text("iPad Pro 11-inch (4th Gen, Cellular)").tag("iPad14,4")
                            } else {
                                Text("iPhone 15 Pro").tag("iPhone16,1")
                                Text("iPhone 15 Pro Max").tag("iPhone16,2")
                                if doubleSystemVersion() >= 18.0 {
                                    Text("iPhone 16").tag("iPhone17,3")
                                    Text("iPhone 16 Plus").tag("iPhone17,4")
                                    Text("iPhone 16 Pro").tag("iPhone17,1")
                                    Text("iPhone 16 Pro Max").tag("iPhone17,2")
                                }
                                if doubleSystemVersion() >= 19.0 {
                                    Text("iPhone 17").tag("iPhone18,3")
                                    Text("iPhone 17 Pro").tag("iPhone18,1")
                                    Text("iPhone 17 Pro Max").tag("iPhone18,2")
                                    Text("iPhone Air").tag("iPhone18,4")
                                }
                            }
                        }
                        
                        Button {
                            Alertinator.shared.alert(
                                title: NSLocalizedStringFromTable("device_spoofing_info", "GestaltView", comment: "Device spoofing info alert title"),
                                body: NSLocalizedStringFromTable("device_spoofing_info_body", "GestaltView", comment: "Device spoofing info alert body")
                            )
                        } label: {
                            Image(systemName: "info.circle")
                                .frame(width: 24, height: 22)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Label(NSLocalizedStringFromTable("eligibility", "GestaltView", comment: "Eligibility header"), systemImage: "checklist")
                }
                
                Section {
                    let cache_extra = mg_dict_now["CacheExtra"] as? NSMutableDictionary
                    
                    PlainToggle(text: NSLocalizedStringFromTable("allow_installing_ipados_apps", "GestaltView", comment: "Allow installing iPadOS apps toggle"), isOn: mg_key_binding(["9MZ5AdH43csAUajl/dU+IQ"], type: [Int].self, default_val: [1], on_val: [1, 2]))
                    PlainToggle(text: NSLocalizedStringFromTable("apple_pencil_settings", "GestaltView", comment: "Apple Pencil Settings toggle"), isOn: mg_key_binding(["yhHcB0iH0d1XzPO/CFd3ow"]))
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        PlainToggle(text: NSLocalizedStringFromTable("stage_manager", "GestaltView", comment: "Stage Manager toggle"), isOn: mg_key_binding(["qeaj75wk3HF4DwQ8qbIi7g"]))
                    }
                    PlainToggle(
                        text: NSLocalizedStringFromTable("ipados_ui", "GestaltView", comment: "iPadOS UI toggle"),
                        infoType: .warning,
                        infoMessage: NSLocalizedStringFromTable("ipados_ui_info", "GestaltView", comment: "iPadOS UI warning info"),
                        isOn: mg_trollpad_binding()
                    )
                    .disabled(cache_extra?["+3Uf0Pm5F8Xy7Onyvko0vA"] as? String != "iPhone")
                } header: {
                    Label(NSLocalizedStringFromTable("ipados_features", "GestaltView", comment: "iPadOS features header"), systemImage: "ipad")
                }
                
                Section {
                    PlainToggle(text: NSLocalizedStringFromTable("internal_storage", "GestaltView", comment: "Internal Storage toggle"), isOn: mg_key_binding(["LBJfwOEzExRxzlAnSuI7eg"]))
                    PlainToggle(text: NSLocalizedStringFromTable("internal_features", "GestaltView", comment: "Internal Features toggle"), isOn: mg_internal_binding())
                    PlainToggle(text: NSLocalizedStringFromTable("metal_hud_in_all_apps", "GestaltView", comment: "Metal HUD toggle"), isOn: mg_key_binding(["EqrsVvjcYDdxHBiQmGhAWw"]))
                } header: {
                    Label(NSLocalizedStringFromTable("internal", "GestaltView", comment: "Internal header"), systemImage: "ant")
                }
            }
            .navigationTitle("mond")
            .tint(Color("AccentColor"))
            .onAppear {
                mg_load()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            show_settings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .sheet(isPresented: $show_settings) {
                SettingsView()
            }
        }
    }
    
    private enum MGViewError: Error, LocalizedError {
        case missingArtworkSubtype
        case missingArtworkDeviceName
        
        var errorDescription: String? {
            switch self {
            case .missingArtworkSubtype:
                return NSLocalizedStringFromTable("missing_artwork_subtype", "GestaltView", comment: "Missing artwork subtype error")
            case .missingArtworkDeviceName:
                return NSLocalizedStringFromTable("missing_artwork_device_name", "GestaltView", comment: "Missing artwork device name error")
            }
        }
    }
    
    private func mg_load() {
        guard !is_loading, mg_dict_now.count == 0 else { return }
        is_loading = true

        let mg_url_now = URL(fileURLWithPath: TweakPaths.gestalt)

        DispatchQueue.global(qos: .userInitiated).async { [self] in
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

                guard let og_subtype = og_artwork["ArtworkDeviceSubType"] as? Int else { throw MGViewError.missingArtworkSubtype }
                guard let og_devicename = og_artwork["ArtworkDeviceProductDescription"] as? String else { throw MGViewError.missingArtworkDeviceName }

                let cache_extra = loaded_dict["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
                let artwork = cache_extra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()

                let new_selected_st = self.st_to_sel[artwork["ArtworkDeviceSubType"] as? Int ?? og_subtype] ?? "og"
                let new_devicename = artwork["ArtworkDeviceProductDescription"] as? String ?? og_devicename
                let new_enable_devicename = new_devicename != og_devicename

                let new_product_type: String
                if let productType = cache_extra["h9jDsbgj7xIVeIQ8S3/X3Q"] as? String, !productType.isEmpty {
                    new_product_type = productType
                } else {
                    new_product_type = self.machine_name()
                }

                DispatchQueue.main.async {
                    self.mg_dict_now = loaded_dict
                    self.og_st = og_subtype
                    self.selected_st = new_selected_st
                    self.mg_devicename = new_devicename
                    self.enable_devicename = new_enable_devicename
                    self.product_type = new_product_type
                    self.is_valid = true
                    self.is_empty = file_size == 0
                    self.is_loading = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("(mg) failed to load data: \(error)")
                    self.is_valid = false
                    self.is_empty = (try? FileManager.default.attributesOfItem(atPath: mg_url_now.path))?[.size] as? UInt64 == 0
                    self.is_loading = false
                    Alertinator.shared.alert(title: NSLocalizedStringFromTable("failed_load_current_mg", "GestaltView", comment: "Failed to load MobileGestalt alert title"), body: NSLocalizedStringFromTable("failed_load_current_mg_body", "GestaltView", comment: "Failed to load MobileGestalt alert body"))
                }
            }
        }
    }
    
    private func mg_apply() {
        do {
            let cache_extra = mg_dict_now["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
            if !product_type.isEmpty {
                cache_extra["h9jDsbgj7xIVeIQ8S3/X3Q"] = product_type
            }
            
            let artwork_dict = cache_extra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()
            artwork_dict["ArtworkDeviceSubType"] = selected_st_value
            if enable_devicename {
                artwork_dict["ArtworkDeviceProductDescription"] = mg_devicename
            }
            
            let data = try PropertyListSerialization.data(fromPropertyList: mg_dict_now, format: .xml, options: 0)

            try mg_write(data)
            mg_dict_now = NSMutableDictionary()
            enable_devicename = false

            print("(mg) successfully overwrote mobilegestalt!")
            Alertinator.shared.alert(title: NSLocalizedStringFromTable("mg_apply_success_title", "GestaltView", comment: "Gestalt apply success title"), body: NSLocalizedStringFromTable("mg_apply_success_body", "GestaltView", comment: "Gestalt apply success body"), actionLabel: NSLocalizedString("respring", comment: "Respring action label"), action: {
                state.respring()
            })
        } catch {
            print("(mg) failed to apply mobilegestalt: \(error)")
            Alertinator.shared.alert(title: NSLocalizedStringFromTable("mg_apply_failed_title", "GestaltView", comment: "Gestalt apply failure title"), body: NSLocalizedStringFromTable("mg_apply_failed_body", "GestaltView", comment: "Gestalt apply failure body"))
        }
    }
    
    private func mg_revert() {
        do {
            let backup_url = URL(fileURLWithPath: AppPaths.backups).appendingPathComponent("SavedGestalt.plist")
            let backup_data = try Data(contentsOf: backup_url)
            try mg_write(backup_data)

            print("(mg) successfully reverted mobilegestalt!)")
            Alertinator.shared.alert(title: NSLocalizedStringFromTable("mg_revert_success_title", "GestaltView", comment: "Gestalt revert success title"), body: NSLocalizedStringFromTable("mg_revert_success_body", "GestaltView", comment: "Gestalt revert success body"))
        } catch {
            // The direct file write path now surfaces the underlying error through the catch.
            print("(mg) failed to revert mobilegestalt: \(error)")
            Alertinator.shared.alert(title: NSLocalizedStringFromTable("mg_revert_failed_title", "GestaltView", comment: "Gestalt revert failure title"), body: NSLocalizedStringFromTable("mg_revert_failed_body", "GestaltView", comment: "Gestalt revert failure body"))
        }
    }

    private func mg_write(_ data: Data) throws {
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
    
    private func mg_key_binding<T: Equatable>(_ keys: [String], type: T.Type = Int.self, default_val: T? = 0, on_val: T? = 1) -> Binding<Bool>  {
        return Binding(get: {
            guard let cache_extra = self.mg_dict_now["CacheExtra"] as? NSMutableDictionary,
                  let on_val,
                  let value = cache_extra[keys.first!] as? T? else {
                return false
            }
            
            return value == on_val
        }, set: { enabled in
            guard let cache_extra = self.mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return }
            
            for key in keys {
                // if it exists inside of the plist, then update it. if not then pull the value completely.
                if enabled {
                    cache_extra[key] = on_val
                } else {
                    cache_extra.removeObject(forKey: key)
                }
            }
        })
    }
    
    private func mg_trollpad_binding() -> Binding<Bool> {
        let value_off = cache_data_offset("mtrAoWJ3gsq+I90ZnQ0vQw")
        let values: [String: Int] = [
            "mG0AnH/Vy1veoqoLRAIgTA": 1, // MedusaFloatingLiveAppCapability
            "UCG5MkVahJxG1YULbbd5Bg": 1, // MedusaOverlayAppCapability
            "ZYqko/XM5zD3XBfN5RmaXA": 1, // MedusaPinnedAppCapability
            "nVh/gwNpy7Jv1NOk00CMrw": 1, // MedusaPIPCapability
            "uKc7FPnEO++lVhHWHFlGbQ": 1, // ipad
        ]
    
        return Binding(get: {
            guard let cache_extra = self.mg_dict_now["CacheExtra"] as? NSMutableDictionary else {
                return false
            }
    
            return values.allSatisfy { key, value in
                (cache_extra[key] as? Int) == value
            }
        }, set: { enabled in
            guard let cache_data = self.mg_dict_now["CacheData"] as? NSMutableData,
                  let cache_extra = self.mg_dict_now["CacheExtra"] as? NSMutableDictionary else {
                return
            }
    
            if enabled {
                Alertinator.shared.alert(
                    title: NSLocalizedString("warning", comment: "Warning alert title"),
                    body: NSLocalizedStringFromTable("ipados_ui_alert_body", "GestaltView", comment: "iPadOS UI alert body")
                )
            }
    
            cache_data.mutableBytes.storeBytes(
                of: enabled ? 3 : 1,
                toByteOffset: value_off,
                as: Int.self
            )
    
            if enabled {
                for (key, value) in values {
                    cache_extra[key] = value
                }
            } else {
                for key in values.keys {
                    cache_extra.removeObject(forKey: key)
                }
            }
        })
    }
    
    private func mg_region_restrict_binding() -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                guard let cache_extra = self.mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return false }
                
                return cache_extra["h63QSdBCiT/z0WU6rdQv6Q"] as? String == "US" &&
                    cache_extra["zHeENZu+wbg7PUprwNwBWg"] as? String == "LL/A"
            },
            set: { enabled in
                guard let cache_extra = self.mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return }
                
                if enabled {
                    Alertinator.shared.alert(title: NSLocalizedString("warning", comment: "Warning alert title"), body: NSLocalizedStringFromTable("region_restrictions_alert_body", "GestaltView", comment: "Region restrictions alert body"))
                    cache_extra["h63QSdBCiT/z0WU6rdQv6Q"] = "US"
                    cache_extra["zHeENZu+wbg7PUprwNwBWg"] = "LL/A"
                } else {
                    cache_extra.removeObject(forKey: "h63QSdBCiT/z0WU6rdQv6Q")
                    cache_extra.removeObject(forKey: "zHeENZu+wbg7PUprwNwBWg")
                }
            }
        )
    }
    
    private func mg_apple_intelligence_binding() -> Binding<Bool> {
        let key = "A62OafQ85EJAiiqKn4agtg"
    
        return Binding<Bool>(
            get: {
                guard let cache_extra = self.mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return false }
                
                if let value = cache_extra[key] as? Int {
                    return value == 1
                }
    
                return false
            },
            set: { enabled in
                guard let cache_extra = self.mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return }
                
                if enabled {
                    cache_extra[key] = 1
    
                    Alertinator.shared.alert(
                        title: NSLocalizedStringFromTable("apple_intelligence_spoof_title", "GestaltView", comment: "Apple Intelligence spoof title"),
                        body: NSLocalizedStringFromTable("apple_intelligence_spoof_body", "GestaltView", comment: "Apple Intelligence spoof body")
                    )
                } else {
                    cache_extra.removeObject(forKey: key)
                }
            }
        )
    }
    
    private func mg_internal_binding() -> Binding<Bool> {
        let off_apple_internal_install = cache_data_offset("EqrsVvjcYDdxHBiQmGhAWw")
        let off_has_internal_settings_bundle = cache_data_offset("Oji6HRoPi7rH7HPdWVakuw")
        let off_internal_build = cache_data_offset("LBJfwOEzExRxzlAnSuI7eg")
        
        return Binding(
            get: {
                guard let cache_data = self.mg_dict_now["CacheData"] as? NSMutableData else { return false }
                
                return cache_data.bytes.load(fromByteOffset: off_apple_internal_install, as: Int.self) == 1
            },
            set: { enabled in
                guard let cache_data = self.mg_dict_now["CacheData"] as? NSMutableData else { return }
                
                cache_data.mutableBytes.storeBytes(of: enabled ? 1 : 0, toByteOffset: off_apple_internal_install, as: Int.self)
                cache_data.mutableBytes.storeBytes(of: enabled ? 1 : 0, toByteOffset: off_has_internal_settings_bundle, as: Int.self)
                cache_data.mutableBytes.storeBytes(of: enabled ? 1 : 0, toByteOffset: off_internal_build, as: Int.self)
            }
        )
    }
    
    private func is_device_good() -> Bool {
        let supported: [String] = ["iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5", "iPhone16,1", "iPhone16,2", "iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone17,5"]
        
        if supported.contains(machine_name()) && doubleSystemVersion() < 19.0 {
            return true
        }
        
        return false
    }
    
    private func machine_name() -> String {
        var sys_info = utsname()
        uname(&sys_info)
        let machine_mirror = Mirror(reflecting: sys_info.machine)
        
        return machine_mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
}
