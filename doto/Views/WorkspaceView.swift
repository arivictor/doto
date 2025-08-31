//
//  WorkspaceView.swift
//  doto
//
//  Created by AI Assistant
//

import SwiftUI

struct WorkspaceView: View {
    @ObservedObject var workspaceManager: WorkspaceManager
    @State private var isCreatingFolder = false
    @State private var newFolderName = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with workspace controls
            HStack {
                Text("Workspace")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        newFolderName = ""
                        isCreatingFolder = true
                    }) {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Create New Folder")
                    
                    Button(action: {
                        workspaceManager.createNewNote()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Create New Note")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Workspace status and folder selection
            if workspaceManager.workspaceURL == nil {
                VStack(spacing: 16) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No Workspace Selected")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Text("Select a folder to store your notes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Select Workspace Folder") {
                        workspaceManager.selectWorkspace()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                // Notes list
                VStack(alignment: .leading, spacing: 0) {
                    // Workspace info with breadcrumb navigation
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.blue)
                            Text(workspaceManager.workspaceURL?.lastPathComponent ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Button(action: {
                                workspaceManager.selectWorkspace()
                            }) {
                                Image(systemName: "folder.badge.gearshape")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Change Workspace")
                        }
                        
                        // Breadcrumb navigation if in subdirectory
                        if workspaceManager.isInSubdirectory {
                            HStack(spacing: 4) {
                                Button(action: {
                                    workspaceManager.navigateUp()
                                }) {
                                    Image(systemName: "arrow.up")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 12))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .help("Go Up")
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 4) {
                                        ForEach(Array(workspaceManager.breadcrumbPath.enumerated()), id: \.offset) { index, url in
                                            HStack(spacing: 2) {
                                                if index > 0 {
                                                    Text("/")
                                                        .foregroundColor(.secondary)
                                                        .font(.system(size: 10))
                                                }
                                                
                                                Button(url.lastPathComponent) {
                                                    workspaceManager.navigateToDirectory(url)
                                                }
                                                .foregroundColor(index == workspaceManager.breadcrumbPath.count - 1 ? .primary : .blue)
                                                .font(.system(size: 10))
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    
                    Divider()
                    
                    // Workspace items (files and folders)
                    if workspaceManager.workspaceItems.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary)
                            
                            Text("Empty Workspace")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Create your first note")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 1) {
                                ForEach(workspaceManager.workspaceItems) { item in
                                    WorkspaceItemRowView(
                                        item: item,
                                        workspaceManager: workspaceManager
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .alert("Create New Folder", isPresented: $isCreatingFolder) {
            TextField("Folder name", text: $newFolderName)
            Button("Create") {
                if !newFolderName.isEmpty {
                    workspaceManager.createFolder(newFolderName)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct WorkspaceItemRowView: View {
    let item: WorkspaceItem
    @ObservedObject var workspaceManager: WorkspaceManager
    @State private var isRenaming = false
    @State private var newName = ""
    
    var body: some View {
        HStack(spacing: 8) {
            // Icon
            Image(systemName: item.isDirectory ? "folder.fill" : (item.isMarkdownFile ? "doc.text" : "doc"))
                .foregroundColor(item.isDirectory ? .blue : (item.isMarkdownFile ? .green : .gray))
                .frame(width: 16)
            
            if isRenaming && item.isMarkdownFile {
                // Rename text field (only for markdown files)
                TextField("New name", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        if !newName.isEmpty, let note = workspaceManager.notes.first(where: { $0.url == item.url }) {
                            workspaceManager.renameNote(note, to: newName)
                        }
                        isRenaming = false
                    }
                    .onExitCommand {
                        isRenaming = false
                    }
            } else {
                // Item name
                Text(item.name)
                    .font(.system(size: 13, weight: item.isMarkdownFile && workspaceManager.selectedNote?.url == item.url ? .medium : .regular))
                    .foregroundColor(item.isMarkdownFile && workspaceManager.selectedNote?.url == item.url ? .white : .primary)
                    .lineLimit(1)
                
                Spacer()
                
                // Context menu for markdown files
                if item.isMarkdownFile {
                    HStack(spacing: 4) {
                        Button(action: {
                            newName = item.url.deletingPathExtension().lastPathComponent
                            isRenaming = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.secondary)
                                .font(.system(size: 10))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(0.7)
                        
                        Button(action: {
                            if let note = workspaceManager.notes.first(where: { $0.url == item.url }) {
                                workspaceManager.deleteNote(note)
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 10))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(0.7)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(item.isMarkdownFile && workspaceManager.selectedNote?.url == item.url ? Color.blue : Color.clear)
        )
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            if item.isDirectory {
                // Navigate into the directory
                workspaceManager.navigateToDirectory(item.url)
            } else if item.isMarkdownFile {
                // Select the note
                if let note = workspaceManager.notes.first(where: { $0.url == item.url }) {
                    workspaceManager.selectedNote = note
                }
            }
        }
    }
}

struct NoteRowView: View {
    let note: Note
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .lineLimit(1)
            
            Text(RelativeDateTimeFormatter().localizedString(for: note.lastModified, relativeTo: Date()))
                .font(.system(size: 11))
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.blue : Color.clear)
        )
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}