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
                    Label(NSLocalizedStringFromTable("logs", "ContentView", comment: "Logs section header"), systemImage: "apple.terminal")
                }
                
                Section {
                    NavigationLink {
                        GestaltView()
                    } label: {
                        Text("MobileGestalt")
                    }
                    
                    NavigationLink {
                        PosterView()
                    } label: {
                        Text("PosterBoard")
                    }
                    .disabled(method == "cmg")
                    
                    NavigationLink {
                        SantanderView()
                    } label: {
                        Text("HouseArrest")
                    }
                    .disabled(true)
                } header: {
                    Label(NSLocalizedStringFromTable("tweaks", "ContentView", comment: "Tweaks section header"), systemImage: "paintbrush")
                } footer: {
                    if method == "cmg" {
                         Text(NSLocalizedStringFromTable("only_mobilegestalt_available", "ContentView", comment: "CMG warning footer"))
                    } else {
                        Text(NSLocalizedStringFromTable("housearrest_dev_warning", "ContentView", comment: "PosterBoard warning footer"))
                    }
                }
            }
            .navigationTitle("mond")
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
