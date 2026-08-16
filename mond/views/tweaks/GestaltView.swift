//
//  GestaltView.swift
//  mond
//
//  Created by ruter on 11.08.26.
//

import SwiftUI
import PartyUI

private extension mg_tweak.InfoType {
    var party_info_type: ToggleInfoType {
        switch self {
            case .info: return .info
            case .warning, .error: return .warning
        }
    }
}

struct TweakToggle: View {
    let title: String

    var body: some View {
        if let tweak = tweak(title) {
            PlainToggle(
                text: tweak.title,
                infoType: tweak.info_t?.party_info_type ?? .none,
                infoMessage: tweak.info_msg ?? "",
                minSupportedVersion: tweak.minv ?? 0.0,
                isOn: mg_tweak_binding(tweak)
            )
        }
    }
}

fileprivate func mg_ui_state() -> (String, Bool, String, String) {
    (selected_st, enable_device_name, mg_device_name, product_type)
}

fileprivate func mg_apply_ui_state(_ selected: String, _ enableName: Bool, _ deviceName: String, _ product: String) {
    selected_st = selected
    enable_device_name = enableName
    mg_device_name = deviceName
    product_type = product
}

struct GestaltView: View {
    @EnvironmentObject var state: AppState

    @State private var show_settings: Bool = false

    @State private var selected_st: String = "og"
    @State private var enable_device_name: Bool = false
    @State private var mg_device_name: String = ""
    @State private var product_type: String = ""

    var body: some View {
        NavigationStack {
            List {
                if !is_valid || is_empty {
                    Section {
                        if is_empty {
                            PlainAlert(title: NSLocalizedString("do_not_reboot",tableName: "GestaltView", comment: ""), icon: "exclamationmark.triangle.fill", text: NSLocalizedString("mg_empty_warning", tableName: "GestaltView", comment: ""), color: Color.yellow)
                        }

                        if !is_valid {
                            PlainAlert(title: NSLocalizedString("do_not_reboot",tableName: "GestaltView", comment: ""), icon: "exclamationmark.triangle.fill", text: NSLocalizedString("mg_invalid_warning", tableName: "GestaltView", comment: ""), color: Color.yellow)
                        }
                    } header: {
                        Label(NSLocalizedString("warning", comment: ""), systemImage: "exclamationmark.triangle")
                    } footer: {
                        Text(NSLocalizedString("bootloop_warning", tableName: "GestaltView", comment: ""))
                    }
                }

                Section {
                    Button {
                        mg_apply_ui_state(selected_st, enable_device_name, mg_device_name, product_type)
                        mg_apply()
                    } label: {
                        Text(NSLocalizedString("apply_tweaks", tableName: "GestaltView", comment: ""))
                    }

                    Button {
                        mg_revert()
                    } label: {
                        Text(NSLocalizedString("revert_tweaks", tableName: "GestaltView", comment: ""))
                    }
                    
                    Button {
                        state.respring()
                    } label: {
                        Text(NSLocalizedString("respring", comment: ""))
                    }
                } footer: {
                    Text(try! AttributedString(NSLocalizedString("tweak_warning", tableName: "GestaltView", comment: "")))
                }

                Section {
                    Picker(selection: $selected_st) {
                        Text(NSLocalizedString("original_subtype_format", tableName: "GestaltView", comment: "")).tag("og")

                        if is_device_good() {
                            Text(NSLocalizedString("disable_dynamic_island", tableName: "GestaltView", comment: "")).tag("no_dynamic_island")
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

                        if has_home_button() {
                            Text("iPhone X Gestures").tag("x")
                        }
                    } label: {
                        HStack {
                            Text(NSLocalizedString("subtype", tableName: "GestaltView", comment: ""))
                            Spacer()
                        }
                    }

                    Toggle(NSLocalizedString("custom_device_name", tableName: "GestaltView", comment: ""), isOn: $enable_device_name)

                    if enable_device_name {
                        TextField(NSLocalizedString("device_name", tableName: "GestaltView", comment: ""), text: $mg_device_name)
                    }
                } header: {
                    Label(NSLocalizedString("device_artwork", tableName: "GestaltView", comment: ""), systemImage: "paintbrush.pointed")
                }

                Section {
                    TweakToggle(title: NSLocalizedStrings("enable_dynamic_island_capability", tableName: "GestaltView", comment: ""))
                    TweakToggle(title: NSLocalizedString("always_on_display", tableName: "GestaltView", comment: ""))
                    TweakToggle(title: NSLocalizedString("aod_vibrancy", tableName: "GestaltView", comment: ""))
                    TweakToggle(title: NSLocalizedString("disable_wallpaper_parallax", tableName: "GestaltView", comment: ""))
                    TweakToggle(title: NSLocalizedString("charge_limit_menu", tableName: "GestaltView", comment: ""))
                    TweakToggle(title: NSLocalizedString("boot_shutdown_chime", tableName: "GestaltView", comment: ""))
                    TweakToggle(title: NSLocalizedString("enable_liquid_glass_low_performance_mode", tableName: "GestaltView", comment: ""))
                    TweakToggle(title: NSLocalizedString("disable_liquid_glass_low_performance_mode", tableName: "GestaltView", comment: ""))
                } header: {
                    Label(NSLocalizedString("software_oriented_features", tableName: "GestaltView", comment: ""), systemImage: "gearshape")
                }

                Section {
                    TweakToggle(title: "iPhone 16 Camera Control Settings")
                    TweakToggle(title: "Action Button Settings")
                    TweakToggle(title: "Collision SOS")
                    if has_home_button() {
                        TweakToggle(title: "Tap to Wake")
                    }
                    TweakToggle(title: "Pulse Width Modulation")
                } header: {
                    Label("Hardware-Oriented Features", systemImage: "iphone")
                }

                Section {
                    TweakToggle(title: "Security Research Device Mode")
                    TweakToggle(title: "Disable Region Restrictions")
                    TweakToggle(title: "Apple Intelligence")

                    HStack(spacing: 10) {
                        Picker("Spoofing", selection: $product_type) {
                            Text("Default").tag(machine_name())
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
                                title: "Device Spoofing Info",
                                body: "Only spoof your device model if you want to download Apple Intelligence. This may break Face ID. If you decide to unspoof and want to keep Apple Intelligence, do NOT re-enter the Apple Intelligence & Siri menu in Settings."
                            )
                        } label: {
                            Image(systemName: "info.circle")
                                .frame(width: 24, height: 22)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Label("Eligibility", systemImage: "checklist")
                }

                Section {
                    let cache_extra = mg_dict_now["CacheExtra"] as? NSMutableDictionary

                    TweakToggle(title: "Allow iPad Apps")
                    TweakToggle(title: "Apple Pencil Settings")

                    if UIDevice.current.userInterfaceIdiom == .pad {
                        TweakToggle(title: "Stage Manager Support")
                    }

                    TweakToggle(title: "Enable iPadOS Mode")
                        .disabled(cache_extra?["+3Uf0Pm5F8Xy7Onyvko0vA"] as? String != "iPhone")
                } header: {
                    Label("iPadOS Features", systemImage: "ipad")
                }

                Section {
                    TweakToggle(title: "Internal Storage View")
                    TweakToggle(title: "Internal Features")
                    TweakToggle(title: "Apple Internal Install")
                } header: {
                    Label("Internal", systemImage: "ant")
                }
            }
            .navigationTitle("mond")
            .tint(Color("AccentColor"))
            .task {
                mg_load()
                while is_loading {
                    try? await Task.sleep(for: .milliseconds(50))
                }
                let s = mg_ui_state()
                selected_st = s.0
                enable_device_name = s.1
                mg_device_name = s.2
                product_type = s.3
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
}