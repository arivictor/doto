//
//  WorkspaceView.swift
//  doto
//
//  Created by AI Assistant
//

import SwiftUI

struct WorkspaceView: View {
    @ObservedObject var workspaceManager: WorkspaceManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with workspace controls
            HStack {
                Text("Workspace")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    workspaceManager.createNewNote()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Create New Note")
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
                    // Workspace info
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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    
                    Divider()
                    
                    // Notes list
                    if workspaceManager.notes.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary)
                            
                            Text("No Notes")
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
                                ForEach(workspaceManager.notes) { note in
                                    NoteRowView(
                                        note: note,
                                        isSelected: workspaceManager.selectedNote?.id == note.id
                                    ) {
                                        workspaceManager.selectedNote = note
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
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