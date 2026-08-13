//
//  ContentView.swift
//  mond
//
//  Created by ruter on 17.07.26.
//

import SwiftUI
import PartyUI

struct ContentView: View {
    @EnvironmentObject var state: AppState
    @AppStorage("method") private var method: String = "bad_query"
    
    @State private var is_valid: Bool = false
    @State private var show_settings: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LogView()
                        .modifier(TerminalPlatter())
                } header: {
                    Label(NSLocalizedString("logs", comment: "Logs section header"), systemImage: "apple.terminal")
                }
                
                Section {
                    NavigationLink {
                        GestaltView()
                    } label: {
                        Text(NSLocalizedString("mobile_gestalt", comment: "MobileGestalt entry"))
                    }
                    
                    NavigationLink {
                        PosterView()
                    } label: {
                        Text(NSLocalizedString("posterboard", comment: "PosterBoard entry"))
                    }
                    .disabled(method == "cmg")
                } header: {
                    Label(NSLocalizedString("tweaks", comment: "Tweaks section header"), systemImage: "paintbrush")
                } footer: {
                    if method == "cmg" {
                         Text(NSLocalizedString("only_mobilegestalt_available", comment: "CMG warning footer"))
                    } else {
                        Text(NSLocalizedString("posterboard_dev_warning", comment: "PosterBoard warning footer"))
                    }
                }
            }
            .navigationTitle(NSLocalizedString("app_name", comment: "App title"))
            .tint(Color("AccentColor"))
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
