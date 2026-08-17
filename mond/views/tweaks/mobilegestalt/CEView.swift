//
//  CEView.swift
//  mond
//
//  Created by ruter on 17.08.26.
//

import SwiftUI
import PartyUI

enum ce_type: String, CaseIterable, Identifiable {
    case str, int, bool, data
    var id: String { rawValue }

    var label: String {
        switch self {
            case .str: "String"
            case .int: "Integer"
            case .bool: "Boolean"
            case .data: "Data (Base64)"
        }
    }

    static func from(_ value: Any?) -> ce_type {
        switch value {
            case is String: .str
            case let n as NSNumber:
                CFGetTypeID(n) == CFBooleanGetTypeID() ? .bool : .int
            case is Data: .data
            default: .str
        }
    }
}

func ce_encode(_ value: Any?, as type: ce_type) -> String {
    switch type {
        case .str:
            value as? String ?? ""
        case .int:
            (value as? NSNumber)?.stringValue ?? ""
        case .bool:
            ((value as? NSNumber)?.boolValue == true) ? "true" : "false"
        case .data:
            (value as? Data)?.base64EncodedString() ?? ""
    }
}

func ce_parse(_ text: String, as type: ce_type) throws -> Any {
    let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
    
    switch type {
        case .str:
            return text
        case .int:
            guard let v = Int64(t) else { throw ce_err.bad_val("Invalid Integer") }
            return NSNumber(value: v)
        case .bool:
            switch t.lowercased() {
                case "true", "1", "yes": return NSNumber(value: true)
                case "false", "0", "no": return NSNumber(value: false)
                default: throw ce_err.bad_val("Enter true/false")
            }
        case .data:
            guard let d = Data(base64Encoded: t) else { throw ce_err.bad_val("Invalid base64") }
            return d
    }
}

enum ce_err: LocalizedError {
    case bad_val(String)

    var errorDescription: String? {
        switch self {
            case .bad_val(let m): m
        }
    }
}

struct CEView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var search = ""
    @State private var editing: CEField?
    @State private var showing_add = false

    private var keys: [String] {
        let cache = mg_dict_now["CacheExtra"] as? [String: Any] ?? [:]
        let all = cache.keys.sorted()
        guard !search.isEmpty else { return all }
        
        return all.filter {
            $0.localizedCaseInsensitiveContains(search) ||
            ce_summary(cache[$0]).localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        List {
            if keys.isEmpty {
                Text(search.isEmpty ? "No CacheExtra fields" : "No results")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(keys, id: \.self) { key in
                    let cache = mg_dict_now["CacheExtra"] as? [String: Any] ?? [:]
                    Button { editing = CEField(key: key, value: cache[key]) } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(key)                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Text(ce_summary(cache[key]))
                                    .monospaced()
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { offsets in
                    guard let cache = mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return }
                    let sorted = keys
                    for i in offsets {
                        cache.removeObject(forKey: sorted[i])
                    }
                    
                    mg_dict_now["CacheExtra"] = cache
                }
            }
        }
        .searchable(text: $search, prompt: "Search for keys or values")
        .navigationTitle("CacheExtra")
        .onAppear() {
            mg_load()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        showing_add = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                    Button {
                        save()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .sheet(item: $editing) { field in
            CEEditSheet(key: field.key, value: field.value) { key, value in
                guard let cache = mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return }
                cache[key] = value
                mg_dict_now["CacheExtra"] = cache
            }
        }
        .sheet(isPresented: $showing_add) {
            CEAddSheet { key, value in
                guard let cache = mg_dict_now["CacheExtra"] as? NSMutableDictionary else { return }
                cache[key] = value
                mg_dict_now["CacheExtra"] = cache
            }
        }
    }

    private func save() {
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: mg_dict_now, format: .xml, options: 0)
            try mg_write(data)
            
            Alertinator.shared.alert(
                title: "Saved",
                body: "Field changes written to MobileGestalt. Respring for changes to take effect.",
                actionLabel: "Respring",
                action: {
                    state.respring()
                }
            )
        } catch {
            Alertinator.shared.alert(title: "Save failed", body: error.localizedDescription)
        }
    }
}

private struct CEField: Identifiable {
    let key: String
    let value: Any?
    var id: String { key }
}

private struct CEEditSheet: View {
    @Environment(\.dismiss) private var dismiss

    let key: String
    let save: (String, Any) -> Void

    @State private var type: ce_type
    @State private var text: String
    @State private var error: String?

    init(key: String, value: Any?, save: @escaping (String, Any) -> Void) {
        self.key = key
        self.save = save
        let t = ce_type.from(value)
        _type = State(initialValue: t)
        _text = State(initialValue: ce_encode(value, as: t))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(ce_type.allCases) { t in Text(t.label).tag(t) }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: type) { _, _ in
                        error = nil
                    }
                }
                Section("Value") {
                    TextEditor(text: $text)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 120)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                if let error {
                    Section { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle(key)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        do {
                            save(key, try ce_parse(text, as: type))
                            dismiss()
                        } catch {
                            self.error = error.localizedDescription
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

private struct CEAddSheet: View {
    @Environment(\.dismiss) private var dismiss

    let save: (String, Any) -> Void

    @State private var key = ""
    @State private var type: ce_type = .str
    @State private var text = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Key") {
                    TextField("Key name", text: $key)
                        .font(.system(.body, design: .monospaced))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(ce_type.allCases) { t in Text(t.label).tag(t) }
                    }
                    .pickerStyle(.menu)
                }
                Section("Value") {
                    TextEditor(text: $text)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 100)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                if let error {
                    Section { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Add Field")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else {
                            error = "Key cannot be empty"
                            return
                        }
                        guard (mg_dict_now["CacheExtra"] as? [String: Any])?[trimmed] == nil else {
                            error = "Key already exists"
                            return
                        }
                        do {
                            save(trimmed, try ce_parse(text, as: type))
                            dismiss()
                        } catch {
                            self.error = error.localizedDescription
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

private func ce_summary(_ value: Any?) -> String {
    switch value {
    case let s as String: s.isEmpty ? "(empty str)" : s
    case let n as NSNumber:
        CFGetTypeID(n) == CFBooleanGetTypeID()
            ? (n.boolValue ? "true" : "false")
            : n.stringValue
    case let d as Data: "Data (\(d.count) bytes)"
    default: String(describing: value ?? "nil")
    }
}
