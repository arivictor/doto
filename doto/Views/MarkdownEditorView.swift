//
//  MarkdownEditorView.swift
//  doto
//
//  Created by AI Assistant
//

import SwiftUI

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
                    // Preview mode
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            MarkdownRenderer(content: editingContent)
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

struct MarkdownRenderer: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(parseMarkdown(content), id: \.self) { element in
                renderElement(element)
            }
        }
    }
    
    private func parseMarkdown(_ content: String) -> [MarkdownElement] {
        let lines = content.components(separatedBy: .newlines)
        var elements: [MarkdownElement] = []
        var currentParagraph: [String] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                if !currentParagraph.isEmpty {
                    elements.append(.paragraph(currentParagraph.joined(separator: "\n")))
                    currentParagraph = []
                }
            } else if trimmedLine.hasPrefix("# ") {
                if !currentParagraph.isEmpty {
                    elements.append(.paragraph(currentParagraph.joined(separator: "\n")))
                    currentParagraph = []
                }
                elements.append(.heading1(String(trimmedLine.dropFirst(2))))
            } else if trimmedLine.hasPrefix("## ") {
                if !currentParagraph.isEmpty {
                    elements.append(.paragraph(currentParagraph.joined(separator: "\n")))
                    currentParagraph = []
                }
                elements.append(.heading2(String(trimmedLine.dropFirst(3))))
            } else if trimmedLine.hasPrefix("### ") {
                if !currentParagraph.isEmpty {
                    elements.append(.paragraph(currentParagraph.joined(separator: "\n")))
                    currentParagraph = []
                }
                elements.append(.heading3(String(trimmedLine.dropFirst(4))))
            } else if trimmedLine.hasPrefix("- ") || trimmedLine.hasPrefix("* ") {
                if !currentParagraph.isEmpty {
                    elements.append(.paragraph(currentParagraph.joined(separator: "\n")))
                    currentParagraph = []
                }
                elements.append(.bulletPoint(String(trimmedLine.dropFirst(2))))
            } else {
                currentParagraph.append(line)
            }
        }
        
        if !currentParagraph.isEmpty {
            elements.append(.paragraph(currentParagraph.joined(separator: "\n")))
        }
        
        return elements
    }
    
    @ViewBuilder
    private func renderElement(_ element: MarkdownElement) -> some View {
        switch element {
        case .heading1(let text):
            Text(text)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 4)
        case .heading2(let text):
            Text(text)
                .font(.title)
                .fontWeight(.semibold)
                .padding(.bottom, 4)
        case .heading3(let text):
            Text(text)
                .font(.title2)
                .fontWeight(.medium)
                .padding(.bottom, 4)
        case .paragraph(let text):
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        case .bulletPoint(let text):
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .font(.body)
                Text(text)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
        }
    }
}

enum MarkdownElement: Hashable {
    case heading1(String)
    case heading2(String)
    case heading3(String)
    case paragraph(String)
    case bulletPoint(String)
}