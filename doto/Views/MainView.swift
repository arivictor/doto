//
//  MainView.swift
//  doto
//
//  Created by AI Assistant
//

import SwiftUI

struct MainView: View {
    @StateObject private var workspaceManager = WorkspaceManager()
    
    var body: some View {
        HSplitView {
            // Left sidebar - Workspace
            WorkspaceView(workspaceManager: workspaceManager)
                .frame(minWidth: 250, idealWidth: 300, maxWidth: 400)
            
            // Right side - Editor
            MarkdownEditorView(workspaceManager: workspaceManager)
                .frame(minWidth: 400)
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            // Auto-load workspace if we have one stored in UserDefaults
            if let workspaceData = UserDefaults.standard.data(forKey: "lastWorkspaceURL") {
                var isStale = false
                if let url = try? URL(resolvingBookmarkData: workspaceData, bookmarkDataIsStale: &isStale) {
                    if url.startAccessingSecurityScopedResource() {
                        workspaceManager.workspaceURL = url
                        workspaceManager.currentDirectoryURL = url // Initialize current directory
                        workspaceManager.loadWorkspaceItems()
                        workspaceManager.loadNotes()
                    }
                }
            }
        }
        .onChange(of: workspaceManager.workspaceURL) { _, newURL in
            // Save workspace URL to UserDefaults
            if let url = newURL {
                do {
                    let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                    UserDefaults.standard.set(bookmarkData, forKey: "lastWorkspaceURL")
                } catch {
                    print("Error saving workspace bookmark: \(error)")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "lastWorkspaceURL")
            }
        }
    }
}
