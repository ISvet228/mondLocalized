//
//  GestaltView.swift
//  mond
//
//  Created by ruter on 11.08.26.
//

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
    @State private var selected_st: String = ""
    
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
                            PlainAlert(title: NSLocalizedString("do_not_reboot", comment: "Warning title"), icon: "exclamationmark.triangle.fill", text: NSLocalizedString("mg_empty_warning", comment: "Empty gestalt warning"), color: Color.yellow)
                        }
                        
                        if !is_valid {
                            PlainAlert(title: NSLocalizedString("do_not_reboot", comment: "Warning title"), icon: "exclamationmark.triangle.fill", text: NSLocalizedString("mg_invalid_warning", comment: "Invalid gestalt warning"), color: Color.yellow)
                        }
                    } header: {
                        Label(NSLocalizedString("warning", comment: "Warning section label"), systemImage: "exclamationmark.triangle")
                    } footer: {
                        Text(NSLocalizedString("bootloop_warning", comment: "Bootloop warning text"))
                    }
                }
                
                Section {
                    Button {
                        mg_apply()
                    } label: {
                        Text(NSLocalizedString("apply_tweaks", comment: "Apply tweaks button"))
                    }
                    
                    Button {
                        mg_revert()
                    } label: {
                        Text(NSLocalizedString("revert_tweaks", comment: "Revert tweaks button"))
                    }
                } footer: {
                    Text(NSLocalizedString("warning_footer", comment: "Warning footer text"))
                }
                
                Section {
                    Picker(selection: $selected_st) {
                        Text(String(format: NSLocalizedString("original_subtype_format", comment: "Original subtype label"), og_st)).tag("og")
                        
                        if is_device_good() {
                            Text(NSLocalizedString("disable_dynamic_island", comment: "Disable dynamic island option")).tag("no_dynamic_island")
                        }
                    
                        Text(NSLocalizedString("iphone_14_pro", comment: "iPhone 14 Pro option")).tag("14p")
                        Text(NSLocalizedString("iphone_14_pro_max", comment: "iPhone 14 Pro Max option")).tag("14pm")
                        Text(NSLocalizedString("iphone_15_pro_max", comment: "iPhone 15 Pro Max option")).tag("15pm")
                    
                        if doubleSystemVersion() >= 18.0 {
                            Text(NSLocalizedString("iphone_16_pro", comment: "iPhone 16 Pro option")).tag("16p")
                            Text(NSLocalizedString("iphone_16_pro_max", comment: "iPhone 16 Pro Max option")).tag("16pm")
                        }
                    
                        if doubleSystemVersion() >= 26.0 {
                            Text(NSLocalizedString("iphone_air", comment: "iPhone Air option")).tag("air")
                        }
                    
                        if hasHomeButton() {
                            Text(NSLocalizedString("iphone_x_gestures", comment: "iPhone X Gestures option")).tag("x")
                        }
                    } label: {
                        HStack {
                            Text(NSLocalizedString("subtype", comment: "Subtype label"))
                            Spacer()
                        }
                    }
                    
                    Toggle(NSLocalizedString("custom_device_name", comment: "Custom device name toggle"), isOn: $enable_devicename)
                    
                    if enable_devicename {
                        TextField(NSLocalizedString("device_name", comment: "Device name field placeholder"), text: $mg_devicename)
                    }
                } header: {
                    Label(NSLocalizedString("device_artwork", comment: "Device artwork header"), systemImage: "paintbrush.pointed")
                }
                
                // basic tweak toggles
                Section {
                    PlainToggle(text: NSLocalizedString("dynamic_island", comment: "Dynamic Island toggle"), minSupportedVersion: 19.0, isOn: mg_key_binding(["YlEtTtHlNesRBMal1CqRaA"]))
                    PlainToggle(text: NSLocalizedString("always_on_display", comment: "Always On Display toggle"), minSupportedVersion: 18.0, isOn: mg_key_binding(["j8/Omm6s1lsmTDFsXjsBfA", "2OOJf1VhaM7NxfRok3HbWQ"]))
                    PlainToggle(text: NSLocalizedString("aod_vibrancy", comment: "AOD Vibrancy toggle"), minSupportedVersion: 18.0, isOn: mg_key_binding(["ykpu7qyhqFweVMKtxNylWA"]))
                    PlainToggle(text: NSLocalizedString("charge_limit", comment: "Charge Limit toggle"), minSupportedVersion: 17.0, isOn: mg_key_binding(["37NVydb//GP/GrhuTN+exg"]))
                    PlainToggle(text: NSLocalizedString("boot_chime", comment: "Boot Chime toggle"), isOn: mg_key_binding(["QHxt+hGLaBPbQJbXiUJX3w"]))
                    PlainToggle(text: NSLocalizedString("liquid_glass_lpm", comment: "Liquid Glass LPM toggle"), minSupportedVersion: 19.0, isOn: mg_key_binding(["SAGvsp6O6kAQ4fEfDJpC4Q"]))
                } header: {
                    Label(NSLocalizedString("software_oriented_features", comment: "Software features header"), systemImage: "gearshape")
                }
                
                Section {
                    PlainToggle(text: NSLocalizedString("camera_control", comment: "Camera Control toggle"), minSupportedVersion: 18.0, isOn: mg_key_binding(["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"]))
                    PlainToggle(text: NSLocalizedString("action_button", comment: "Action Button toggle"), minSupportedVersion: 17.0, isOn: mg_key_binding(["cT44WE1EohiwRzhsZ8xEsw"]))
                    PlainToggle(text: NSLocalizedString("crash_detection", comment: "Crash Detection toggle"), isOn: mg_key_binding(["HCzWusHQwZDea6nNhaKndw"]))
                    if hasHomeButton() {
                        PlainToggle(text: NSLocalizedString("enable_tap_to_wake", comment: "Tap to wake toggle"), isOn: mg_key_binding(["yZf3GTRMGTuwSV/lD7Cagw"]))
                    }
                    PlainToggle(text: NSLocalizedString("pulse_width_modulation", comment: "PWM toggle"), minSupportedVersion: 19.0, isOn: mg_key_binding(["6IejgN+1Fmu5/QrZFOIeNw"]))
                } header: {
                    Label(NSLocalizedString("hardware_oriented_features", comment: "Hardware features header"), systemImage: "iphone")
                }
                
                Section {
                    PlainToggle(text: NSLocalizedString("security_research_device_ui", comment: "Security Research Device UI toggle"), minSupportedVersion: 26.0, isOn: mg_key_binding(["XYlJKKkj2hztRP1NWWnhlw"]))
                    
                    PlainToggle(
                        text: NSLocalizedString("disable_region_restrictions", comment: "Disable region restrictions toggle"),
                        infoType: .info,
                        infoMessage: NSLocalizedString("disable_region_restrictions_info", comment: "Region restriction info"),
                        isOn: mg_region_restrict_binding()
                    )
                    
                    PlainToggle(
                        text: NSLocalizedString("apple_intelligence", comment: "Apple Intelligence toggle"),
                        infoType: .info,
                        infoMessage: NSLocalizedString("apple_intelligence_info", comment: "Apple intelligence info"),
                        minSupportedVersion: 18.1,
                        isOn: mg_apple_intelligence_binding()
                    )
                    
                    HStack(spacing: 10) {
                        Picker(NSLocalizedString("spoofing", comment: "Spoofing picker label"), selection: $product_type) {
                            Text(NSLocalizedString("default_model", comment: "Default device label")).tag(machine_name())
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                if doubleSystemVersion() >= 17.4 {
                                    Text(NSLocalizedString("ipad_pro_11_m4", comment: "iPad 11 M4 label")).tag("iPad16,3")
                                    Text(NSLocalizedString("ipad_pro_11_m4_cellular", comment: "iPad 11 M4 cellular label")).tag("iPad16,4")
                                }
                                Text(NSLocalizedString("ipad_pro_11_4th_gen", comment: "iPad 11 4th gen label")).tag("iPad14,3")
                                Text(NSLocalizedString("ipad_pro_11_4th_gen_cellular", comment: "iPad 11 4th gen cellular label")).tag("iPad14,4")
                            } else {
                                Text(NSLocalizedString("iphone_15_pro", comment: "iPhone 15 Pro label")).tag("iPhone16,1")
                                Text(NSLocalizedString("iphone_15_pro_max", comment: "iPhone 15 Pro Max label")).tag("iPhone16,2")
                                if doubleSystemVersion() >= 18.0 {
                                    Text(NSLocalizedString("iphone_16", comment: "iPhone 16 label")).tag("iPhone17,3")
                                    Text(NSLocalizedString("iphone_16_plus", comment: "iPhone 16 Plus label")).tag("iPhone17,4")
                                    Text(NSLocalizedString("iphone_16_pro", comment: "iPhone 16 Pro label")).tag("iPhone17,1")
                                    Text(NSLocalizedString("iphone_16_pro_max", comment: "iPhone 16 Pro Max label")).tag("iPhone17,2")
                                }
                                if doubleSystemVersion() >= 19.0 {
                                    Text(NSLocalizedString("iphone_17", comment: "iPhone 17 label")).tag("iPhone18,3")
                                    Text(NSLocalizedString("iphone_17_pro", comment: "iPhone 17 Pro label")).tag("iPhone18,1")
                                    Text(NSLocalizedString("iphone_17_pro_max", comment: "iPhone 17 Pro Max label")).tag("iPhone18,2")
                                    Text(NSLocalizedString("iphone_air", comment: "iPhone Air label")).tag("iPhone18,4")
                                }
                            }
                        }
                        
                        Button {
                            Alertinator.shared.alert(
                                title: NSLocalizedString("device_spoofing_info", comment: "Device spoofing info alert title"),
                                body: NSLocalizedString("device_spoofing_info_body", comment: "Device spoofing info alert body")
                            )
                        } label: {
                            Image(systemName: "info.circle")
                                .frame(width: 24, height: 22)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Label(NSLocalizedString("eligibility", comment: "Eligibility header"), systemImage: "checklist")
                }
                
                Section {
                    let cache_extra = mg_dict_now["CacheExtra"] as? NSMutableDictionary
                    
                    PlainToggle(text: NSLocalizedString("allow_installing_ipados_apps", comment: "Allow installing iPadOS apps toggle"), isOn: mg_key_binding(["9MZ5AdH43csAUajl/dU+IQ"], type: [Int].self, default_val: [1], on_val: [1, 2]))
                    PlainToggle(text: NSLocalizedString("apple_pencil_settings", comment: "Apple Pencil Settings toggle"), isOn: mg_key_binding(["yhHcB0iH0d1XzPO/CFd3ow"]))
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        PlainToggle(text: NSLocalizedString("stage_manager", comment: "Stage Manager toggle"), isOn: mg_key_binding(["qeaj75wk3HF4DwQ8qbIi7g"]))
                    }
                    PlainToggle(
                        text: NSLocalizedString("ipados_ui", comment: "iPadOS UI toggle"),
                        infoType: .warning,
                        infoMessage: NSLocalizedString("ipados_ui_info", comment: "iPadOS UI warning info"),
                        isOn: mg_trollpad_binding()
                    )
                    .disabled(cache_extra?["+3Uf0Pm5F8Xy7Onyvko0vA"] as? String != "iPhone")
                } header: {
                    Label(NSLocalizedString("ipados_features", comment: "iPadOS features header"), systemImage: "ipad")
                }
                
                Section {
                    PlainToggle(text: NSLocalizedString("internal_storage", comment: "Internal Storage toggle"), isOn: mg_key_binding(["LBJfwOEzExRxzlAnSuI7eg"]))
                    PlainToggle(text: NSLocalizedString("internal_features", comment: "Internal Features toggle"), isOn: mg_internal_binding())
                    PlainToggle(text: NSLocalizedString("metal_hud_in_all_apps", comment: "Metal HUD toggle"), isOn: mg_key_binding(["EqrsVvjcYDdxHBiQmGhAWw"]))
                } header: {
                    Label(NSLocalizedString("internal", comment: "Internal header"), systemImage: "ant")
                }
            }
            .navigationTitle(NSLocalizedString("app_name", comment: "App navigation title"))
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
                return NSLocalizedString("missing_artwork_subtype", comment: "Missing artwork subtype error")
            case .missingArtworkDeviceName:
                return NSLocalizedString("missing_artwork_device_name", comment: "Missing artwork device name error")
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
                    Alertinator.shared.alert(title: NSLocalizedString("failed_load_current_mg", comment: "Failed to load MobileGestalt alert title"), body: NSLocalizedString("failed_load_current_mg_body", comment: "Failed to load MobileGestalt alert body"))
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
            Alertinator.shared.alert(title: NSLocalizedString("mg_apply_success_title", comment: "Gestalt apply success title"), body: NSLocalizedString("mg_apply_success_body", comment: "Gestalt apply success body"), actionLabel: NSLocalizedString("respring", comment: "Respring action label"), action: {
                state.respring()
            })
        } catch {
            print("(mg) failed to apply mobilegestalt: \(error)")
            Alertinator.shared.alert(title: NSLocalizedString("mg_apply_failed_title", comment: "Gestalt apply failure title"), body: NSLocalizedString("mg_apply_failed_body", comment: "Gestalt apply failure body"))
        }
    }
    
    private func mg_revert() {
        do {
            let backup_url = URL(fileURLWithPath: AppPaths.backups).appendingPathComponent("SavedGestalt.plist")
            let backup_data = try Data(contentsOf: backup_url)
            try mg_write(backup_data)

            print("(mg) successfully reverted mobilegestalt!)")
            Alertinator.shared.alert(title: NSLocalizedString("mg_revert_success_title", comment: "Gestalt revert success title"), body: NSLocalizedString("mg_revert_success_body", comment: "Gestalt revert success body"))
        } catch {
            // The direct file write path now surfaces the underlying error through the catch.
            print("(mg) failed to revert mobilegestalt: \(error)")
            Alertinator.shared.alert(title: NSLocalizedString("mg_revert_failed_title", comment: "Gestalt revert failure title"), body: NSLocalizedString("mg_revert_failed_body", comment: "Gestalt revert failure body"))
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
                    title: NSLocalizedString("warning_alert_title", comment: "Warning alert title"),
                    body: NSLocalizedString("ipados_ui_alert_body", comment: "iPadOS UI alert body")
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
                    Alertinator.shared.alert(title: NSLocalizedString("warning_alert_title", comment: "Warning alert title"), body: NSLocalizedString("region_restrictions_alert_body", comment: "Region restrictions alert body"))
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
                        title: NSLocalizedString("apple_intelligence_spoof_title", comment: "Apple Intelligence spoof title"),
                        body: NSLocalizedString("apple_intelligence_spoof_body", comment: "Apple Intelligence spoof body")
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
