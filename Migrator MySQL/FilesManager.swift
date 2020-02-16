//
//  FilesManager.swift
//  Migrator MySQL
//
//  Created by Алихан on 16/02/2020.
//  Copyright © 2020 Nexen Origin, LLC. All rights reserved.
//

import Foundation

protocol FilesManagerDelegate {
    func readingFailedWith(message: String)
    func savingFailedWith(message: String)
    func savingDone()
}

class FilesManager {
    
    var delegate: FilesManagerDelegate?
    
    init(delegate: FilesManagerDelegate?) {
        self.delegate = delegate
    }
    
    func contentsOfTemplateWith(name: String) -> String {
        var migration = ""
        
        if let filepath = Bundle.main.path(forResource: name, ofType: "lms") {
            do {
                migration = try String(contentsOfFile: filepath)
            } catch {
                self.delegate?.readingFailedWith(message: "Template loading failed (\(name))")
            }
        } else {
            self.delegate?.readingFailedWith(message: "Path is incorrect")
        }
        
        return migration
    }
    
    func save(string: String, with name: String, at path: String) {
        let filename = path + "/" + name
        let manager = FileManager.default
        
        if !manager.fileExists(atPath: filename, isDirectory: nil) {
            do {
                try manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error)
                self.delegate?.savingFailedWith(message: "Path is incorrect")
            }
            
        }
        
        do {
            try string.write(toFile: filename, atomically: false, encoding: .utf8)
            self.delegate?.savingDone()
        } catch let error as NSError {
            print(error)
        }
        
    }
    
}
