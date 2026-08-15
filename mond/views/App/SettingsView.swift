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
                                     ?? NSLocalizedString("unknown_app", comment: "Fallback app name"))
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
                    Picker(NSLocalizedString("method", comment: "Method picker label"), selection: $method) {
                        Text("bad_query").tag("bad_query")
                        Text("cmg").tag("cmg")
                    }
                    .pickerStyle(.segmented)
                    
                    Button {
                        grant_all(state: state)
                    } label: {
                        Text(NSLocalizedString("run_exploit", comment: "Run exploit button"))
                    }
                } header: {
                    Label(NSLocalizedString("exploit", comment: "Exploit section title"), systemImage: "wrench.and.screwdriver")
                } footer: {
                    if method == "cmg" {
                        Text(NSLocalizedString("exploit_method_cmg", comment: "CMG footer text"))
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(NSLocalizedString("exploit_method_bad_query_prefix", comment: "bad_query intro text"))
                            Link("forcequit", destination: URL(string: "https://github.com/forcequitOS")!)
                        }
                    }
                }
                
                Section {
                    HStack {
                        TextField(NSLocalizedString("sandbox_extension_token_placeholder", comment: "Token field placeholder"), text: $token)
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = token
                        } label: {
                            Image(systemName: "document.on.document")
                        }
                    }
                    .contextMenu {
                        Text(NSLocalizedString("token_class", comment: "Token class label") + " \(token.split(separator: ";").first { $0.contains("com.apple") }.map(String.init) ?? "N/A")")
                        Text(NSLocalizedString("token_path", comment: "Token path label") + " \(token.split(separator: ";").last.map(String.init) ?? "N/A")")
                        
                        Button {
                            UIPasteboard.general.string = token
                        } label: {
                            Label(NSLocalizedString("copy_token", comment: "Copy token action"), systemImage: "doc.on.doc")
                        }
                    }
                    .lineLimit(1)
                    
                    Button {
                        token = sandbox_extension_issue_file(path: TweakPaths.gestalt_dir) ?? NSLocalizedString("failed_to_get_token", comment: "Failed token fallback")
                    } label: {
                        Text(NSLocalizedString("generate_token", comment: "Generate token button"))
                    }
                    .disabled(!state.exploit_succeeded)
                } header: {
                    Label(NSLocalizedString("token", comment: "Token section title"), systemImage: "key")
                } footer: {
                    if !token.isEmpty && token != NSLocalizedString("failed_to_get_token", comment: "Failed token fallback") {
                        if valid {
                            Text(NSLocalizedString("sandbox_token_valid", comment: "Valid sandbox token"))
                        } else {
                            Text(NSLocalizedString("sandbox_token_invalid", comment: "Invalid sandbox token"))
                        }
                    }
                    
                    if !state.exploit_succeeded {
                        Text(NSLocalizedString("exploit_failed_version", comment: "Exploit failure message"))
                    }
                }
                
                Section {
                    Toggle(NSLocalizedString("keep_alive", comment: "Keep alive toggle"), isOn: $ka_on)
                        .onChange(of: ka_on) { _, enabled in
                            if enabled {
                                keep_alive()
                            } else {
                                let_die()
                            }
                        }
                } header: {
                    Label(NSLocalizedString("settings", comment: "Settings section title"), systemImage: "gear")
                }
                
                Section {
                    Button {
                        show_confirm = true
                    } label: {
                        Text(NSLocalizedString("respring", comment: "Respring button"))
                    }
                } header: {
                    Label(NSLocalizedString("tools", comment: "Tools section title"), systemImage: "wrench.and.screwdriver")
                } footer: {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(NSLocalizedString("respring_method_prefix", comment: "Respring intro text"))
                        Link("neon", destination: URL(string: "https://github.com/neonmodder123")!)
                        Text(NSLocalizedString("respring_method_middle", comment: "Respring middle text"))
                        Link("skadz", destination: URL(string: "https://github.com/skadz108")!)
                    }
                }
                
                Section {
                    CreditsRow(name: "roooot", role: NSLocalizedString("credit_main_developer", comment: "Credit role"), profile: URL(string: "https://github.com/rooootdev")!)
                    CreditsRow(name: "forcequit", role: NSLocalizedString("credit_bad_query_exploit", comment: "Credit role"), profile: URL(string: "https://github.com/forcequitOS")!)
                    CreditsRow(name: "johnny", role: NSLocalizedString("credit_mcm_bug_class", comment: "Credit role"), profile: URL(string: "https://github.com/0xjohnnydev")!)
                    CreditsRow(name: "jailbreak.party", role: NSLocalizedString("credit_partyui_gestaltview", comment: "Credit role"), profile: URL(string: "https://github.com/jailbreakdotparty")!)
                    CreditsRow(name: "Hikariman", role: NSLocalizedString("credit_locaclization_project", comment: "Credit role"), profile: URL(string: "https://github.com/ISvet228")!)
                } header: {
                    Label(NSLocalizedString("credits", comment: "Credits section title"), systemImage: "person.3.fill")
                }
            }
            .navigationTitle(NSLocalizedString("settings", comment: "Settings view title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text(NSLocalizedString("done", comment: "Done button"))
                        }
                    }
                }
            }
            .alert(NSLocalizedString("are_you_sure", comment: "Confirmation dialog title"), isPresented: $show_confirm) {
                Button(NSLocalizedString("cancel", comment: "Cancel button")) {
                    show_confirm = false
                }
                
                Button(NSLocalizedString("confirm", comment: "Confirm button")) {
                    state.respring()
                }
            } message: {
                Text(NSLocalizedString("confirm_respring", comment: "Respring confirmation message"))
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
