//
//  PosterView.swift
//  mond
//
//  Created by ruter on 11.08.26.
//

import SwiftUI
import UniformTypeIdentifiers
import SafariServices
import PartyUI

struct PosterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState
    
    @State private var show_settings: Bool = false
    @State private var show_importer: Bool = false
    @State private var busy = false
    
    @State private var show_browser: Bool = false
    @State private var browser_url = URL(string: "https://cowabun.ga/wallpapers")!

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        apply()
                    } label: {
                        HStack {
                            if busy {
                                ProgressView()
                            }
                            
                            Text(NSLocalizedStringFromTable("apply", "PosterView", comment: "Apply poster button"))
                        }
                    }
                    .disabled(state.poster_files.isEmpty || busy)

                    Button {
                        reset()
                    } label: {
                        Text(NSLocalizedStringFromTable("reset", "PosterView", comment: "Reset poster button"))
                    }
                    .disabled(busy)
                }
                
                Section {
                    Button {
                        show_importer = true
                    } label: {
                        Text(NSLocalizedStringFromTable("import_tendies", "PosterView", comment: "Import tendies button"))
                    }
                    .disabled(busy)
                } footer: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(NSLocalizedStringFromTable("poster_import_hint", "PosterView", comment: "Wallpaper import hint"))
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(NSLocalizedStringFromTable("poster_get_tendies_prefix", "PosterView", comment: "Get tendies prefix"))
                            Link(NSLocalizedStringFromTable("poster_get_tendies_link", "PosterView", comment: "Get tendies link label"), destination: URL(string: "https://cowabun.ga/wallpapers")!)
                        }
                    }
                    .sheet(isPresented: $show_browser) {
                        SafariView(url: browser_url)
                    }
                }

                if !state.poster_files.isEmpty {
                    Section {
                        ForEach(state.poster_files, id: \.self) { url in
                            Text(url.lastPathComponent)
                        }
                        .onDelete { offsets in
                            state.remove_poster_files(at: offsets)
                        }
                    } header: {
                        Label(NSLocalizedStringFromTable("imported", "PosterView", comment: "Imported section header"), systemImage: "document.on.document")
                    }
                }
            }
            .navigationTitle(NSLocalizedStringFromTable("posterboard", "PosterView", comment: "PosterBoard navigation title"))
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
            .fileImporter(isPresented: $show_importer, allowedContentTypes: [.data], allowsMultipleSelection: true) { result in
                switch result {
                case .success(let urls):
                    urls.forEach { state.append_poster_file($0) }
                    show_browser = false
                case .failure(let error):
                    print("(pb) import failed: \(error)")
                }
            }
        }
    }

    private func apply() {
        busy = true
        do {
            let count = try pb.apply(at: state.poster_files)
            print("(pb) applied \(count) descriptor(s).")
            busy = false
            Alertinator.shared.alert(
                title: NSLocalizedStringFromTable("poster_apply_success_title", "PosterView", comment: "Poster apply success title"),
                body: NSLocalizedStringFromTable("poster_apply_success_body", "PosterView", comment: "Poster apply success body"),
                actionLabel: NSLocalizedStringFromTable("respring", "PosterView", comment: "Respring action label"),
                action: {
                    state.respring()
                }
            )
        } catch {
            print("(pb) failed: \(error.localizedDescription)\n")
            busy = false
            Alertinator.shared.alert(
                title: NSLocalizedStringFromTable("poster_apply_failed_title", "PosterView", comment: "Poster apply failure title"),
                body: NSLocalizedStringFromTable("poster_apply_failed_body", "PosterView", comment: "Poster apply failure body")
            )
        }
    }

    private func reset() {
        busy = true
        do {
            try pb.reset()
            print("(pb) reset done.")
            busy = false
            Alertinator.shared.alert(
                title: NSLocalizedStringFromTable("poster_reset_success_title", "PosterView", comment: "Poster reset success title"),
                body: NSLocalizedStringFromTable("poster_reset_success_body", "PosterView", comment: "Poster reset success body"),
                actionLabel: NSLocalizedStringFromTable("respring", "PosterView", comment: "Respring action label"),
                action: {
                    state.respring()
                }
            )
        } catch {
            print("(pb) failed: \(error.localizedDescription)")
            busy = false
            Alertinator.shared.alert(
                title: NSLocalizedStringFromTable("poster_reset_failed_title", "PosterView", comment: "Poster reset failure title"),
                body: NSLocalizedStringFromTable("poster_reset_failed_body", "PosterView", comment: "Poster reset failure body")
            )
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
