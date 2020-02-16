//
//  MigrationsGenerator.swift
//  Migrator MySQL
//
//  Created by Алихан on 16/02/2020.
//  Copyright © 2020 Nexen Origin, LLC. All rights reserved.
//

import Foundation

class MigrationsGenerator {
    
    private let filesManager = FilesManager(delegate: nil)
    private var tables: [Table]
    private var path: String
    private var filesManagerDelegate: FilesManagerDelegate?
    
    init(tables: [Table], path: String, filesManagerDelegate: FilesManagerDelegate?) {
        self.tables = tables
        self.path = path
        self.filesManagerDelegate = filesManagerDelegate
        self.filesManager.delegate = self.filesManagerDelegate
    }
    
    func start() {
        let tables = self.tables
        var i = 1
        
        for table in tables {
            
            let tableName = table.title
            let className = classNameFrom(name: "create_\(tableName)")
            let tableFields = migrationFieldsFrom(table: table)
            var migration = self.filesManager.contentsOfTemplateWith(name: "L5MigrationCreateTemplate")
            migration = migration.replacingOccurrences(of: "%CLASS_NAME%", with: className).replacingOccurrences(of: "%TABLE_NAME%", with: tableName).replacingOccurrences(of: "%TABLE_FIELDS%", with: tableFields)
            self.filesManager.save(string: migration, with: "database/migrations/" + "2019_08_19_0000" + (i > 10 ? i.description : "0" + i.description) + "_create_\(tableName)_table" + ".php", at: self.path)
            i += 1
        }
        
        for table in tables {
            
            let tableName = table.title
            let className = classNameFrom(name: "add_refs_to_\(tableName)")
            let tableFields = migrationReferencesFrom(table: table)
            let dropFields = dropForeignKeysFrom(table: table)
            var migration = self.filesManager.contentsOfTemplateWith(name: "L5MigrationUpdateTemplate")
            migration = migration.replacingOccurrences(of: "%CLASS_NAME%", with: className).replacingOccurrences(of: "%TABLE_NAME%", with: tableName).replacingOccurrences(of: "%TABLE_FIELDS%", with: tableFields).replacingOccurrences(of: "%DROP_FIELDS%", with: dropFields)
            self.filesManager.save(string: migration, with: "database/migrations/" + "2019_08_19_001" + (i > 10 ? i.description : "0" + i.description) + "_add_refs_to_\(tableName)_table" + ".php", at: self.path)
            i += 1
        }
    }
    
    
    //MARK: - Private -
    
    private func classNameFrom(name: String) -> String {
        let components = name.components(separatedBy: "_")
        var result = ""
        for component in components {
            result += component.lowercased().capitalized
        }
        
        return result + "Table"
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
        
        return fieldsString
    }
    
    private func migrationReferencesFrom(table: Table) -> String {
        var fieldsString = ""
        for field in table.fields {
            if let reference = field.reference {
                fieldsString += "\t\t\t$table->foreign('\(reference.field)')->references('\(reference.toField)')->on('\(reference.toTable)');\n"
            }

        }
        return fieldsString
    }
    
    private func dropForeignKeysFrom(table: Table) -> String {
        var fieldsString = ""
        for field in table.fields {
            if let reference = field.reference {
                fieldsString += "\t\t\t$table->dropForeign('\(reference.field)');\n"
            }

        }
        return fieldsString
    }
    
}
