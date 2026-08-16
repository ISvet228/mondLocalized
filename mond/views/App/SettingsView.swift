//
//  SettingsView.swift
//  mond
//
//  Created by ruter on 18.07.26.
//

import SwiftUI
import PartyUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState
    
    @AppStorage("method") private var method: String = "bad_query"
    @AppStorage("ka_on") private var ka_on = true
    @AppStorage("token") private var token: String = ""
    @AppStorage("dismiss_after_import") private var dismiss_after_import = false
    
    @State private var show_confirm: Bool = false
    
    var valid: Bool {
        (sandbox_extension_consume(token) ?? -1) >= 0
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        if let url = URL(string: "https://github.com/rooootdev/mond"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
                               let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
                               let files = primary["CFBundleIconFiles"] as? [String],
                               let icon = files.last,
                               let img = UIImage(named: icon) {
                                Image(uiImage: img)
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                                     ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
                                     ?? NSLocalizedString("unknown_app", tableName: "SettingsView", comment: "Fallback app name"))
                                .font(.headline)
                                
                                Text("\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .fontWeight(.semibold)
                                .foregroundStyle(.tertiary)
                                .imageScale(.small)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                Section {
                    Picker(NSLocalizedString("method", tableName: "SettingsView", comment: "Method picker label"), selection: $method) {
                        Text("bad_query").tag("bad_query")
                        Text("cmg").tag("cmg")
                    }
                    .pickerStyle(.segmented)
                    
                    Button {
                        grant_all(state: state)
                    } label: {
                        Text(NSLocalizedString("run_exploit", tableName: "SettingsView", comment: "Run exploit button label"))
                    }
                } header: {
                    Label(NSLocalizedString("exploit", tableName: "SettingsView", comment: "Exploit section header"), systemImage: "wrench.and.screwdriver")
                } footer: {
                    Text(method == "cmg" ? NSLocaclizedString("exploit_method_cmg", tableName: "SettingsView", comment: "") : 
                    NSLocaclizedString("exploit_method_bad_query_prefix", tableName: "SettingsView", comment: ""))
                }
                
                Section {
                    HStack {
                        TextField("Sandbox Extension Token.", text: $token)
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = token
                        } label: {
                            Image(systemName: "document.on.document")
                        }
                    }
                    .contextMenu {
                        Text("Class: \(token.split(separator: ";").first { $0.contains("com.apple") }.map(String.init) ?? "N/A")")
                        Text("Path: \(token.split(separator: ";").last.map(String.init) ?? "N/A")")
                        
                        Button {
                            UIPasteboard.general.string = token
                        } label: {
                            Label("Copy token", systemImage: "doc.on.doc")
                        }
                    }
                    .lineLimit(1)
                    
                    Button {
                        token = sandbox_extension_issue_file(path: TweakPaths.gestalt_dir) ?? "Failed to get token."
                    } label: {
                        Text("Generate Token")
                    }
                    .disabled(!state.exploit_succeeded)
                } header: {
                    Label("Token", systemImage: "key")
                } footer: {
                    if !token.isEmpty && token != "Failed to get token." {
                        if valid {
                            Text("Your sandbox token is valid.")
                        } else {
                            Text("Your sandbox token is invalid.")
                        }
                    }
                    
                    if !state.exploit_succeeded {
                        Text("Disabled because the exploit failed. Is your iOS version supported?")
                    }
                }
                
                Section {
                    PlainToggle(text: "Keep Alive", infoType: .info, infoMessage: "Keeps the app running in the background after you close it, allowing it to remain active.", isOn: $ka_on)
                        .onChange(of: ka_on) { _, enabled in
                            if enabled {
                                keep_alive()
                            } else {
                                let_die()
                            }
                        }

                    PlainToggle(text: "Dismiss after importing", infoType: .info, infoMessage: "When enabled, the Tendies explorer will close automatically after importing a .tendies file into PosterBoard.", isOn: $dismiss_after_import)
                } header: {
                    Label("Settings", systemImage: "gear")
                }
                
                Section {
                    Button {
                        show_confirm = true
                    } label: {
                        Text("Respring")
                    }
                } header: {
                    Label("Tools", systemImage: "wrench.and.screwdriver")
                } footer: {
                    Text("Respring method by [neon](https://github.com/neonmodder123), swift implementation by [skadz](https://github.com/skadz108).")
                }
                
                Section {
                    CreditsRow(name: "roooot", role: "Main developer", profile: URL(string: "https://github.com/rooootdev")!)
                    CreditsRow(name: "forcequit", role: "The bad_query exploit", profile: URL(string: "https://github.com/forcequitOS")!)
                    CreditsRow(name: "johnny", role: "His work on the MCM bug class", profile: URL(string: "https://github.com/0xjohnnydev")!)
                    CreditsRow(name: "jailbreak.party", role: "PartyUI, GestaltView", profile: URL(string: "https://github.com/jailbreakdotparty")!)
                    CreditsRow(name: "SerStars", role: "Tendies repository", profile: URL(string: "https://github.com/SerStars")!)
                } header: {
                    Label("Credits", systemImage: "person.3.fill")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                        }
                    }
                }
            }
            .alert("Are you sure?", isPresented: $show_confirm) {
                Button("Cancel") {
                    show_confirm = false
                }
                
                Button("Confirm") {
                    state.respring()
                }
            } message: {
                Text("Confirm that you want to respring.")
            }
        }
    }
}

struct CreditsRow: View {
    let name: String
    let role: String
    let profile: URL

    private var pfp: URL? {
        URL(string: profile.absoluteString + ".png")
    }

    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: pfp) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)

                Text(role)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .onTapGesture {
            UIApplication.shared.open(profile)
        }
    }
}