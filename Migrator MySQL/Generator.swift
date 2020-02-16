//
//  MigrationsGenerator.swift
//  Migrator MySQL
//
//  Created by Алихан on 13/02/2020.
//  Copyright © 2020 Nexen Origin, LLC. All rights reserved.
//

import Foundation

protocol GeneratorDelegate {
    func generationDoneWith(fail: Bool, message: String?)
}

class Generator {
    
    //MARK: - Properties -
    let path: String
    let sqlCode: String
    var delegate: GeneratorDelegate?
    
    
    //MARK: - Constructors -
    
    init(path: String, sqlCode: String) {
        self.path = path
        self.sqlCode = sqlCode
    }
    
    
    //MARK: - Generator -
    
    func start() {
        let parser = MySQLParser()
        let tables = parser.tablesFrom(mysql: self.sqlCode)
        for table in tables {
            
            let tableName = table.title
            let className = classNameFrom(name: tableName)
            let tableFields = migrationFieldsFrom(table: table)
            var migration = contentsOfTemplate(name: "L5MigrationTemplate")
            migration = migration.replacingOccurrences(of: "%CLASS_NAME%", with: className).replacingOccurrences(of: "%TABLE_NAME%", with: tableName).replacingOccurrences(of: "%TABLE_FIELDS%", with: tableFields)
            save(string: migration, with: Date().description.replacingOccurrences(of: " ", with: "_") + "_create_\(tableName)" + ".php")
        }
    }
    
    
    //MARK: - Private -
    
    private func classNameFrom(name: String) -> String {
        let components = name.components(separatedBy: "_")
        var result = ""
        for component in components {
            result += component.lowercased().capitalized
        }
        
        return result
    }
    
    private func migrationFieldsFrom(table: Table) -> String {
        
        var fieldsString = ""
        
        for field in table.fields {
            
            if field.isPrimary {
                fieldsString += "\t\t\t$table->bigIncrements('\(field.title)');\n"
                continue
            }
            
            switch field.type {
            case .int:
                fieldsString += "\t\t\t$table->unsignedBigInteger('\(field.title)')"
                break
            case .string:
                fieldsString += "\t\t\t$table->string('\(field.title)')"
                break
            case .datetime:
                fieldsString += "\t\t\t$table->dateTime('\(field.title)')"
                break
            case .timestamp:
                fieldsString += "\t\t\t$table->timestamp('\(field.title)')->useCurrent()"
                break
            }
            
            fieldsString += (field.isNullable ? "->nullable()" : "") + (field.isUnique ? "->unique()" : "") + (field.defaultValue != nil ? "->default('\(field.defaultValue!)')" : "") + (field.reference != nil ? "->onDelete('cascade')" : "") + ";\n"
            
        }
        
        for field in table.fields {
            if let reference = field.reference {
                fieldsString += "\t\t\t$table->foreign('\(reference.field)')->references('\(reference.toField)')->on('\(reference.toTable)');\n"
            }

        }
        return fieldsString
    }
    
    private func save(string: String, with name: String) {
        let filename = self.path + "/" + name
        let manager = FileManager.default
        
        if !manager.fileExists(atPath: filename, isDirectory: nil) {
            do {
                try manager.createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error)
                self.delegate?.generationDoneWith(fail: true, message: "Path is incorrect")
            }
            
        }
        
        do {
            try string.write(toFile: filename, atomically: false, encoding: .utf8)
            self.delegate?.generationDoneWith(fail: false, message: nil)
        } catch let error as NSError {
            print(error)
        }
        
//        if manager.createFile(atPath: filename, contents: string.data(using: .utf8), attributes: nil) {
//            self.delegate?.generationDoneWith(fail: false, message: nil)
//        } else {
//            self.delegate?.generationDoneWith(fail: true, message: "File saving error")
//        }
    }
    
    private func contentsOfTemplate(name: String) -> String {
        var migration = ""
        
        if let filepath = Bundle.main.path(forResource: name, ofType: "lms") {
            do {
                migration = try String(contentsOfFile: filepath)
            } catch {
                self.delegate?.generationDoneWith(fail: true, message: "Template loading failed (\(name))")
            }
        } else {
            self.delegate?.generationDoneWith(fail: true, message: "Path is incorrect")
        }
        
        return migration
    }
}
