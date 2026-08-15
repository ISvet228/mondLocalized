//
//  SantanderView.swift
//  mond
//
//  Created by ruter on 14.08.26.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers
import AVKit
import AVFoundation

struct SantanderView: View {
    var body: some View {
        SantanderBrowserSheet(
            start_path: "/private/var/mobile/Containers/Data/Application/"
        )
    }
}

struct SantanderBrowserSheet: UIViewControllerRepresentable {
    let start_path: String

    func makeUIViewController(context: Context) -> SantanderPathListViewController {
        SantanderPathListViewController(path: SantanderPath(url: URL(fileURLWithPath: start_path)))
    }

    func updateUIViewController(_ uiViewController: SantanderPathListViewController, context: Context) {}
}

private struct SantanderDirectoryListing {
    let items: [SantanderPath]
    let emptyStateMessage: String?
}

struct SantanderPath: Hashable {
    let url: URL
    let lastPathComponent: String
    let isDirectory: Bool
    let contentType: UTType?

    var path: String { url.path }
    var title: String { path == "/" ? "/" : lastPathComponent }

    var displayImage: UIImage? {
        if isDirectory { return UIImage(systemName: "folder.fill") }
        guard let type = contentType else { return UIImage(systemName: "doc") }
        if type.isSubtype(of: .text) { return UIImage(systemName: "doc.text") }
        if type.isSubtype(of: .image) { return UIImage(systemName: "photo") }
        if type.isSubtype(of: .audio) { return UIImage(systemName: "waveform") }
        if type.isSubtype(of: .movie) || type.isSubtype(of: .video) { return UIImage(systemName: "play") }
        return UIImage(systemName: "doc")
    }

    nonisolated init(url: URL) {
        self.url = url
        self.lastPathComponent = url.path == "/" ? "/" : url.lastPathComponent
        let values = try? url.resourceValues(forKeys: [.contentTypeKey])
        var isDir = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        self.isDirectory = exists && isDir.boolValue
        self.contentType = values?.contentType
    }
}

final class SantanderPathListViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    private var unfilteredContents: [SantanderPath]
    private var renderedContents: [SantanderPath]
    private let currentPath: SantanderPath
    private let initialEmptyStateMessage: String?
    private var isSearching = false
    private var displayHiddenFiles = true

    init(path: SantanderPath) {
        let initialListing = Self.loadDirectoryContents(for: path)
        self.currentPath = path
        self.unfilteredContents = initialListing.items
        self.renderedContents = initialListing.items
        self.initialEmptyStateMessage = initialListing.emptyStateMessage
        super.init(style: .insetGrouped)
        self.title = path.title
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = currentPath.title
        configureSearchController()
        configureRightBarButton()
        applyFilters()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        renderedContents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let path = renderedContents[indexPath.row]
        return pathCellRow(forURL: path, displayFullPathAsSubtitle: isSearching)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        open(renderedContents[indexPath.row])
    }

    private func applyFilters(query: String? = nil) {
        let query = query ?? searchQuery
        renderedContents = filteredContents(matching: query)
        updateEmptyState(query: query)
        tableView.reloadData()
    }

    private func updateEmptyState(query: String) {
        guard renderedContents.isEmpty else {
            tableView.backgroundView = nil
            return
        }

        let message: String
        if !query.isEmpty {
            message = "No matching items."
        } else if !displayHiddenFiles && !unfilteredContents.isEmpty {
            message = "No visible items. Enable \"Display hidden files\" to show dotfiles."
        } else {
            message = initialEmptyStateMessage ?? "Directory is empty."
        }

        let label = UILabel()
        label.text = message
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        tableView.backgroundView = label
    }

    private func filteredContents(matching query: String) -> [SantanderPath] {
        var items = unfilteredContents
        if !displayHiddenFiles {
            items.removeAll { $0.lastPathComponent.hasPrefix(".") }
        }
        guard !query.isEmpty else {
            return items
        }
        return items.filter {
            $0.lastPathComponent.localizedCaseInsensitiveContains(query) || $0.path.localizedCaseInsensitiveContains(query)
        }
    }

    private var searchQuery: String {
        navigationItem.searchController?.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func configureRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            menu: makeRightBarButton()
        )
    }

    private func makeRightBarButton() -> UIMenu {
        let sortAZ = makeMenuAction(title: "Sort A-Z", image: "textformat") { [weak self] in
            self?.unfilteredContents.sort {
                $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending
            }
            self?.applyFilters()
        }
        let sortZA = makeMenuAction(title: "Sort Z-A", image: "textformat") { [weak self] in
            self?.unfilteredContents.sort {
                $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedDescending
            }
            self?.applyFilters()
        }
        let goRoot = makeMenuAction(title: "Go to Root", image: "externaldrive") { [weak self] in
            self?.replaceDirectory(with: "/")
        }
        let goHome = makeMenuAction(title: "Go to Home", image: "house") { [weak self] in
            self?.replaceDirectory(with: NSHomeDirectory())
        }
        return UIMenu(children: [
            UIMenu(title: "Sort by..", image: UIImage(systemName: "arrow.up.arrow.down"), children: [sortAZ, sortZA]),
            UIMenu(title: "Go to..", image: UIImage(systemName: "arrow.right"), children: [goRoot, goHome])
        ])
    }

    private func makeMenuAction(title: String, image systemName: String, handler: @escaping () -> Void) -> UIAction {
        UIAction(title: title, image: UIImage(systemName: systemName)) { _ in handler() }
    }

    private func replaceDirectory(with path: String) {
        let vc = SantanderPathListViewController(path: SantanderPath(url: URL(fileURLWithPath: path)))
        navigationController?.setViewControllers([vc], animated: true)
    }

    private func open(_ path: SantanderPath) {
        let viewController = path.isDirectory
            ? SantanderPathListViewController(path: path)
            : SantanderFileReaderViewController(path: path)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private static func loadDirectoryContents(for path: SantanderPath) -> SantanderDirectoryListing {
        guard path.isDirectory else {
            return SantanderDirectoryListing(items: [], emptyStateMessage: "Not a directory.")
        }

        let fm = FileManager.default
        var isDir = ObjCBool(false)
        let exists = fm.fileExists(atPath: path.path, isDirectory: &isDir)
        if !exists || !isDir.boolValue {
            return SantanderDirectoryListing(items: [], emptyStateMessage: "Directory no longer exists.")
        }
        if !fm.isReadableFile(atPath: path.path) {
            return SantanderDirectoryListing(items: [], emptyStateMessage: "Cannot list directory (missing permissions).")
        }

        do {
            let urls = try fm.contentsOfDirectory(at: path.url, includingPropertiesForKeys: nil)
            let items = urls.map(SantanderPath.init(url:))
            if items.isEmpty {
                return SantanderDirectoryListing(items: [], emptyStateMessage: "Directory is empty.")
            }
            return SantanderDirectoryListing(items: items, emptyStateMessage: nil)
        } catch {
            let nsError = error as NSError
            if nsError.domain == NSCocoaErrorDomain && nsError.code == NSFileReadNoPermissionError {
                return SantanderDirectoryListing(items: [], emptyStateMessage: "Cannot list directory (missing permissions).")
            }
            return SantanderDirectoryListing(items: [], emptyStateMessage: "Unable to list directory: \(nsError.localizedDescription)")
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        isSearching = !query.isEmpty
        applyFilters(query: query)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        applyFilters(query: "")
    }

    private func pathCellRow(forURL fsItem: SantanderPath, displayFullPathAsSubtitle useSubtitle: Bool = false) -> UITableViewCell {
        let cell = UITableViewCell(style: useSubtitle ? .subtitle : .default, reuseIdentifier: nil)
        var conf = cell.defaultContentConfiguration()
        conf.text = fsItem.title
        conf.image = fsItem.displayImage

        if fsItem.lastPathComponent.first == "." {
            conf.textProperties.color = .gray
            conf.secondaryTextProperties.color = .gray
        }
        if useSubtitle {
            conf.secondaryText = fsItem.path
        }
        if fsItem.isDirectory {
            cell.accessoryType = .disclosureIndicator
        }

        cell.contentConfiguration = conf
        return cell
    }
}

private final class SantanderFileReaderViewController: UIViewController {
    private let path: SantanderPath
    private let textView = UITextView()
    private var playerViewController: AVPlayerViewController?
    
    private enum PreviewKind {
        case image
        case video
        case audio
        case text
    }
    
    init(path: SantanderPath) {
        self.path = path
        super.init(nibName: nil, bundle: nil)
        self.title = path.title
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareFile)
        )
        switch previewKind(for: path) {
        case .image:
            showImagePreview()
        case .video:
            showVideoPreview()
        case .audio:
            showAudioPreview()
        case .text:
            showTextPreview(text: Self.renderFile(at: path.url))
        }
    }
    
    @objc private func shareFile() {
        guard FileManager.default.isReadableFile(atPath: path.path) else {
            showTextPreview(text: failureText("Failed to share file"))
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [path.url], applicationActivities: nil)
        if let popover = activityController.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(activityController, animated: true)
    }
    
    private func showTextPreview(text: String) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.alwaysBounceVertical = true
        textView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        attachFullScreenView(textView)
        textView.text = text
    }
    
    private func showImagePreview() {
        guard let image = UIImage(contentsOfFile: path.path) else {
            showTextPreview(text: failureText("Failed to render image"))
            return
        }

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.clipsToBounds = true
        imageView.image = image
        attachFullScreenView(imageView)
    }
    
    private func showVideoPreview() {
        showMediaPreview(errorTitle: "Failed to play video")
    }
    
    private func showAudioPreview() {
        showMediaPreview(errorTitle: "Failed to play audio")
    }
    
    private func showMediaPreview(errorTitle: String) {
        guard FileManager.default.isReadableFile(atPath: path.path) else {
            showTextPreview(text: failureText(errorTitle))
            return
        }
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: path.url)
        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(playerVC)
        attachFullScreenView(playerVC.view)
        playerVC.didMove(toParent: self)
        playerVC.player?.play()
        playerViewController = playerVC
    }
    
    deinit {
        playerViewController?.player?.pause()
    }
    
    private func previewKind(for path: SantanderPath) -> PreviewKind {
        if let type = path.contentType {
            if type.isSubtype(of: .image) { return .image }
            if type.isSubtype(of: .movie) || type.isSubtype(of: .video) { return .video }
            if type.isSubtype(of: .audio) { return .audio }
            return .text
        }
        
        let ext = path.url.pathExtension.lowercased()
        if ["png", "jpg", "jpeg", "gif", "heic", "heif", "bmp", "tif", "tiff", "webp"].contains(ext) {
            return .image
        }
        if ["mp4", "mov", "m4v", "avi", "mkv"].contains(ext) {
            return .video
        }
        if [
            "mp3", "m4a", "m4b", "m4p", "aac", "aiff", "aif", "aifc", "wav", "wave",
            "caf", "flac", "alac", "opus", "oga", "ogg", "mka", "wma", "ac3", "eac3",
            "amr", "3gp", "3gpp", "3g2", "au", "snd", "mp2", "mp1", "ape", "tta", "wv"
        ].contains(ext) {
            return .audio
        }
        return .text
    }

    private func attachFullScreenView(_ contentView: UIView) {
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func failureText(_ title: String) -> String {
        """
        \(title):
        \(path.path)

        \(Self.unreadableFileDetails(for: path.url))
        """
    }
    
    private static func renderFile(at url: URL) -> String {
        let data: Data
        do {
            data = try Data(contentsOf: url, options: .mappedIfSafe)
        } catch {
            return """
            Failed to read file:
            \(url.path)
            Error: \(error.localizedDescription)
            
            \(unreadableFileDetails(for: url))
            """
        }
        
        if data.isEmpty {
            return "(empty file)"
        }
        
        if let plist = decodePropertyList(from: data) {
            return plist
        }
        
        if let text = decodeText(from: data) {
            return text
        }
        
        return binaryPreview(from: data)
    }
    
    private static func unreadableFileDetails(for url: URL) -> String {
        let fm = FileManager.default
        var lines: [String] = []
        
        var isDir = ObjCBool(false)
        let exists = fm.fileExists(atPath: url.path, isDirectory: &isDir)
        lines.append("Exists: \(exists ? "yes" : "no")")
        if exists {
            lines.append("Kind: \(isDir.boolValue ? "directory" : "regular item")")
        }
        
        let keys: Set<URLResourceKey> = [
            .contentTypeKey,
            .isSymbolicLinkKey,
            .isAliasFileKey,
            .fileSizeKey
        ]
        if let values = try? url.resourceValues(forKeys: keys) {
            if let type = values.contentType {
                lines.append("UTType: \(type.identifier)")
            }
            if let size = values.fileSize {
                lines.append("Size: \(size) bytes")
            }
            if let isSymLink = values.isSymbolicLink {
                lines.append("Symlink: \(isSymLink ? "yes" : "no")")
            }
            if values.isSymbolicLink == true,
               let target = try? fm.destinationOfSymbolicLink(atPath: url.path) {
                lines.append("Symlink target: \(target)")
            }
            if let isAlias = values.isAliasFile {
                lines.append("Alias file: \(isAlias ? "yes" : "no")")
            }
        }
        
        if let attrs = try? fm.attributesOfItem(atPath: url.path) {
            if let fileType = attrs[.type] as? FileAttributeType {
                lines.append("File attribute type: \(fileType.rawValue)")
            }
            let ownerName = attrs[.ownerAccountName] as? String
            let ownerID = (attrs[.ownerAccountID] as? NSNumber)?.intValue
            switch (ownerName, ownerID) {
            case let (name?, id?):
                lines.append("Owner: \(name) (\(id))")
            case let (name?, nil):
                lines.append("Owner: \(name)")
            case let (nil, id?):
                lines.append("Owner ID: \(id)")
            default:
                break
            }
            
            let groupName = attrs[.groupOwnerAccountName] as? String
            let groupID = (attrs[.groupOwnerAccountID] as? NSNumber)?.intValue
            switch (groupName, groupID) {
            case let (name?, id?):
                lines.append("Group: \(name) (\(id))")
            case let (name?, nil):
                lines.append("Group: \(name)")
            case let (nil, id?):
                lines.append("Group ID: \(id)")
            default:
                break
            }
            if let perms = attrs[.posixPermissions] as? NSNumber {
                lines.append(String(format: "POSIX perms: %04o", perms.intValue))
            }
        }
        
        lines.append("Readable: \(fm.isReadableFile(atPath: url.path) ? "yes" : "no")")
        lines.append("Writable: \(fm.isWritableFile(atPath: url.path) ? "yes" : "no")")
        lines.append("Executable: \(fm.isExecutableFile(atPath: url.path) ? "yes" : "no")")
        
        return lines.joined(separator: "\n")
    }
    
    private static func decodePropertyList(from data: Data) -> String? {
        guard data.starts(with: Data("bplist".utf8)) || data.starts(with: Data("<?xml".utf8)) else {
            return nil
        }
        
        guard let plistObject = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) else {
            return nil
        }
        
        if JSONSerialization.isValidJSONObject(plistObject),
           let jsonData = try? JSONSerialization.data(withJSONObject: plistObject, options: [.prettyPrinted, .sortedKeys]),
           let json = String(data: jsonData, encoding: .utf8) {
            return json
        }
        
        if let xmlData = try? PropertyListSerialization.data(fromPropertyList: plistObject, format: .xml, options: 0),
           let xml = String(data: xmlData, encoding: .utf8) {
            return xml
        }
        
        return String(describing: plistObject)
    }
    
    private static func decodeText(from data: Data) -> String? {
        let encodings: [String.Encoding] = [
            .utf8,
            .utf16,
            .utf16LittleEndian,
            .utf16BigEndian,
            .utf32,
            .utf32LittleEndian,
            .utf32BigEndian,
            .ascii,
            .isoLatin1,
            .windowsCP1252,
            .macOSRoman,
            .nonLossyASCII
        ]
        
        for encoding in encodings {
            guard let value = String(data: data, encoding: encoding) else { continue }
            if looksLikeText(value) {
                return value
            }
        }
        return nil
    }
    
    private static func looksLikeText(_ value: String) -> Bool {
        if value.isEmpty { return true }
        let scalars = value.unicodeScalars
        let disallowed = scalars.filter { scalar in
            let v = scalar.value
            if v == 9 || v == 10 || v == 13 { return false }
            if v < 32 { return true }
            if v >= 0x7F && v <= 0x9F { return true }
            return false
        }
        return Double(disallowed.count) / Double(scalars.count) < 0.01
    }
    
    private static func binaryPreview(from data: Data) -> String {
        let limit = min(data.count, 4096)
        let chunk = data.prefix(limit)
        var lines: [String] = []
        lines.append("Binary data (\(data.count) bytes). Showing first \(limit) bytes:")
        lines.append("")
        
        var offset = 0
        while offset < chunk.count {
            let row = chunk[offset..<min(offset + 16, chunk.count)]
            let hex = row.map { String(format: "%02X", $0) }.joined(separator: " ")
            let ascii = row.map { byte -> String in
                if byte >= 32 && byte <= 126 { return String(UnicodeScalar(byte)) }
                return "."
            }.joined()
            lines.append(String(format: "%08X  %-47@  %@", offset, hex as NSString, ascii))
            offset += 16
        }

        return lines.joined(separator: "\n")
    }
}
