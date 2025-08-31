//
//  MarkdownEditorView.swift
//  doto
//
//  Created by AI Assistant
//

import SwiftUI
import MarkdownUI

struct MarkdownEditorView: View {
    @ObservedObject var workspaceManager: WorkspaceManager
    @State private var editingContent: String = ""
    @State private var isPreviewMode: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if let selectedNote = workspaceManager.selectedNote {
                // Editor toolbar
                HStack {
                    Text(selectedNote.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Preview toggle
                    Button(action: {
                        isPreviewMode.toggle()
                    }) {
                        Image(systemName: isPreviewMode ? "pencil" : "eye")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help(isPreviewMode ? "Edit" : "Preview")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                // Editor content
                if isPreviewMode {
                    // Preview mode using Apple's native markdown renderer
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            AppleMarkdownRenderer(content: editingContent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                    }
                    .background(Color(NSColor.textBackgroundColor))
                } else {
                    // Edit mode
                    TextEditor(text: $editingContent)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .background(Color(NSColor.textBackgroundColor))
                        .padding(8)
                        .onChange(of: editingContent) { _, newValue in
                            var updatedNote = selectedNote
                            updatedNote.updateContent(newValue)
                            workspaceManager.selectedNote = updatedNote
                            workspaceManager.scheduleAutoSave(for: updatedNote)
                        }
                }
            } else {
                // No note selected
                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("No Note Selected")
                        .font(.title)
                        .foregroundColor(.primary)
                    
                    Text("Select a note from the workspace or create a new one")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.textBackgroundColor))
            }
        }
        .onChange(of: workspaceManager.selectedNote) { _, newNote in
            if let note = newNote {
                editingContent = note.content
                isPreviewMode = false
            }
        }
        .onAppear {
            if let note = workspaceManager.selectedNote {
                editingContent = note.content
            }
        }
    }
}

struct AppleMarkdownRenderer: View {
    let content: String

    var body: some View {
        ScrollView {
            Markdown(content)
                .markdownTheme(.gitHub)
                .padding()
        }
    }
}
