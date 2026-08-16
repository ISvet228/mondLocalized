//
//  SettingsView.swift
//  mond
//
//  Created by ruter on 18.07.26.
//

import Foundation
import SwiftUI
import PartyUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState
    
    @AppStorage("method") private var method: String = "bad_query"
    @AppStorage("ka_on") private var ka_on = true
    @AppStorage("token") private var token: String = ""
    
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
                                     ?? NSLocalizedStringFromTable("unknown_app", "SettingsView", comment: "Fallback app name"))
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
                    Picker(NSLocalizedStringFromTable("method", "SettingsView", comment: "Method picker label"), selection: $method) {
                        Text("bad_query").tag("bad_query")
                        Text("cmg").tag("cmg")
                    }
                    .pickerStyle(.segmented)
                    
                    Button {
                        grant_all(state: state)
                    } label: {
                        Text(NSLocalizedStringFromTable("run_exploit", "SettingsView", comment: "Run exploit button"))
                    }
                } header: {
                    Label(NSLocalizedStringFromTable("exploit", "SettingsView", comment: "Exploit section title"), systemImage: "wrench.and.screwdriver")
                } footer: {
                    if method == "cmg" {
                        Text(NSLocalizedStringFromTable("exploit_method_cmg", "SettingsView", comment: "CMG footer text"))
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(NSLocalizedStringFromTable("exploit_method_bad_query_prefix", "SettingsView", comment: "bad_query intro text"))
                            Link("forcequit", destination: URL(string: "https://github.com/forcequitOS")!)
                        }
                    }
                }
                
                Section {
                    HStack {
                        TextField(NSLocalizedStringFromTable("sandbox_extension_token_placeholder", "SettingsView", comment: "Token field placeholder"), text: $token)
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = token
                        } label: {
                            Image(systemName: "document.on.document")
                        }
                    }
                    .contextMenu {
                         let tokenValue = token.split(separator: ";")
                          .first { $0.contains("com.apple") }
                          .map(String.init) ?? "N/A"
    
                            // 2. Теперь компилятор моментально соберет эту строку
                        Text("\(NSLocalizedStringFromTable("token_class", "SettingsView", comment: "Token class label")) \(tokenValue)")
                        Text(NSLocalizedStringFromTable("token_path", "SettingsView", comment: "Token path label") + " \(token.split(separator: ";").last.map(String.init) ?? "N/A")")
                        
                        Button {
                            UIPasteboard.general.string = token
                        } label: {
                            Label(NSLocalizedStringFromTable("copy_token", "SettingsView", comment: "Copy token action"), systemImage: "doc.on.doc")
                        }
                    }
                    .lineLimit(1)
                    
                    Button {
                        token = sandbox_extension_issue_file(path: TweakPaths.gestalt_dir) ?? NSLocalizedStringFromTable("failed_to_get_token", "SettingsView", comment: "Failed token fallback")
                    } label: {
                        Text(NSLocalizedStringFromTable("generate_token", "SettingsView", comment: "Generate token button"))
                    }
                    .disabled(!state.exploit_succeeded)
                } header: {
                    Label(NSLocalizedStringFromTable("token", "SettingsView", comment: "Token section title"), systemImage: "key")
                } footer: {
                    if !token.isEmpty && token != NSLocalizedStringFromTable("failed_to_get_token", "SettingsView", comment: "Failed token fallback") {
                        if valid {
                            Text(NSLocalizedStringFromTable("sandbox_token_valid", "SettingsView", comment: "Valid sandbox token"))
                        } else {
                            Text(NSLocalizedStringFromTable("sandbox_token_invalid", "SettingsView", comment: "Invalid sandbox token"))
                        }
                    }
                    
                    if !state.exploit_succeeded {
                        Text(NSLocalizedStringFromTable("exploit_failed_version", "SettingsView", comment: "Exploit failure message"))
                    }
                }
                
                Section {
                    Toggle(NSLocalizedStringFromTable("keep_alive", "SettingsView", comment: "Keep alive toggle"), isOn: $ka_on)
                        .onChange(of: ka_on) { _, enabled in
                            if enabled {
                                keep_alive()
                            } else {
                                let_die()
                            }
                        }
                } header: {
                    Label(NSLocalizedStringFromTable("settings", "SettingsView", comment: "Settings section title"), systemImage: "gear")
                }
                
                Section {
                    Button {
                        show_confirm = true
                    } label: {
                        Text(NSLocalizedString("respring", "SettingsView", comment: "Respring button"))
                    }
                } header: {
                    Label(NSLocalizedStringFromTable("tools", "SettingsView", comment: "Tools section title"), systemImage: "wrench.and.screwdriver")
                } footer: {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(NSLocalizedStringFromTable("respring_method_prefix", "SettingsView", comment: "Respring intro text"))
                        Link("neon", destination: URL(string: "https://github.com/neonmodder123")!)
                        Text(NSLocalizedStringFromTable("respring_method_middle", "SettingsView", comment: "Respring middle text"))
                        Link("skadz", destination: URL(string: "https://github.com/skadz108")!)
                    }
                }
                
                Section {
                    CreditsRow(name: "roooot", role: NSLocalizedStringFromTable("credit_main_developer", "SettingsView", comment: "Credit role"), profile: URL(string: "https://github.com/rooootdev")!)
                    CreditsRow(name: "forcequit", role: NSLocalizedStringFromTable("credit_bad_query_exploit", "SettingsView", comment: "Credit role"), profile: URL(string: "https://github.com/forcequitOS")!)
                    CreditsRow(name: "johnny", role: NSLocalizedStringFromTable("credit_mcm_bug_class", "SettingsView", comment: "Credit role"), profile: URL(string: "https://github.com/0xjohnnydev")!)
                    CreditsRow(name: "jailbreak.party", role: NSLocalizedStringFromTable("credit_partyui_gestaltview", "SettingsView", comment: "Credit role"), profile: URL(string: "https://github.com/jailbreakdotparty")!)
                    CreditsRow(name: "Hikariman", role: NSLocalizedStringFromTable("credit_locaclization_project", "SettingsView", comment: "Credit role"), profile: URL(string: "https://github.com/ISvet228")!)
                } header: {
                    Label(NSLocalizedStringFromTable("credits", "SettingsView", comment: "Credits section title"), systemImage: "person.3.fill")
                }
            }
            .navigationTitle(NSLocalizedStringFromTable("settings", "SettingsView", comment: "Settings view title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text(NSLocalizedStringFromTable("done", "SettingsView", comment: "Done button"))
                        }
                    }
                }
            }
            .alert(NSLocalizedStringFromTable("are_you_sure", "SettingsView", comment: "Confirmation dialog title"), isPresented: $show_confirm) {
                Button(NSLocalizedStringFromTable("cancel", "SettingsView", comment: "Cancel button")) {
                    show_confirm = false
                }
                
                Button(NSLocalizedStringFromTable("confirm", "SettingsView", comment: "Confirm button")) {
                    state.respring()
                }
            } message: {
                Text(NSLocalizedStringFromTable("confirm_respring", "SettingsView", comment: "Respring confirmation message"))
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
