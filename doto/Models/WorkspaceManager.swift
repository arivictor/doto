//
//  WorkspaceManager.swift
//  doto
//
//  Created by AI Assistant
//

import Foundation
import Combine
import AppKit

class WorkspaceManager: ObservableObject {
    @Published var workspaceURL: URL?
    @Published var notes: [Note] = []
    @Published var selectedNote: Note?
    
    private var autoSaveTimer: Timer?
    
    func selectWorkspace() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Notes Workspace"
        
        if panel.runModal() == .OK, let url = panel.url {
            workspaceURL = url
            loadNotes()
        }
    }
    
    func loadNotes() {
        guard let workspaceURL = workspaceURL else { return }
        
        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(at: workspaceURL, includingPropertiesForKeys: [.isRegularFileKey])
            
            let markdownFiles = contents.filter { url in
                url.pathExtension.lowercased() == "md"
            }
            
            var loadedNotes: [Note] = []
            for fileURL in markdownFiles {
                do {
                    let content = try String(contentsOf: fileURL)
                    let note = Note(url: fileURL, content: content)
                    loadedNotes.append(note)
                } catch {
                    print("Error loading note \(fileURL.lastPathComponent): \(error)")
                }
            }
            
            notes = loadedNotes.sorted { $0.lastModified > $1.lastModified }
        } catch {
            print("Error loading workspace: \(error)")
        }
    }
    
    func createNewNote() {
        guard let workspaceURL = workspaceURL else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "New Note \(timestamp).md"
        let fileURL = workspaceURL.appendingPathComponent(fileName)
        
        let newNote = Note(url: fileURL, content: "# \(fileURL.deletingPathExtension().lastPathComponent)\n\n")
        
        do {
            try newNote.content.write(to: fileURL, atomically: true, encoding: .utf8)
            notes.insert(newNote, at: 0)
            selectedNote = newNote
        } catch {
            print("Error creating new note: \(error)")
        }
    }
    
    func saveNote(_ note: Note) {
        do {
            try note.content.write(to: note.url, atomically: true, encoding: .utf8)
            
            // Update the note in our array
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = note
            }
        } catch {
            print("Error saving note: \(error)")
        }
    }
    
    func scheduleAutoSave(for note: Note) {
        autoSaveTimer?.invalidate()
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.saveNote(note)
        }
    }
}