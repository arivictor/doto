//
//  Note.swift
//  doto
//
//  Created by AI Assistant
//

import Foundation

struct Note: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    var content: String
    var lastModified: Date
    
    var title: String {
        url.deletingPathExtension().lastPathComponent
    }
    
    var filename: String {
        url.lastPathComponent
    }
    
    init(url: URL, content: String = "") {
        self.url = url
        self.content = content
        self.lastModified = Date()
    }
    
    mutating func updateContent(_ newContent: String) {
        self.content = newContent
        self.lastModified = Date()
    }
}