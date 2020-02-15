//
//  MigrationsGenerator.swift
//  Migrator MySQL
//
//  Created by Алихан on 13/02/2020.
//  Copyright © 2020 Nexen Origin, LLC. All rights reserved.
//

import Foundation

protocol MigrationsGeneratorDelegate {
    func generationDoneWith(fail: Bool)
}

class MigrationsGenerator {
    
    //MARK: - Properties -
    let path: String
    let sqlCode: String
    var delegate: MigrationsGeneratorDelegate?
    
    
    //MARK: - Constructors -
    
    init(path: String, sqlCode: String) {
        self.path = path
        self.sqlCode = sqlCode.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "").lowercased()
    }
    
    
    //MARK: - Generator -
    
    func start() {
        let rows: [String] = self.sqlCode.components(separatedBy: ";")
        print(rows.count)
        
        let tableRows = rows.filter { $0.contains("createtable") }
        let referenceRows = rows.filter { $0.contains("foreignkey") }
        
        var tables: [Table] = []
        
        for row in tableRows {
            let tableTitle = row.components(separatedBy: "(")[0].replacingOccurrences(of: "createtable`", with: "").replacingOccurrences(of: "`", with: "")
            let fields = self.extractFieldsFrom(string: row)
            
            let table = Table(title: tableTitle, fields: fields)
            tables.append(table)
        }
        
        for row in referenceRows {
            if let reference = self.extractReferenceFrom(string: row) {
                
                if let tableIndex = tables.firstIndex(where: { $0.title == reference.table }) {
                    if let fieldIndex = tables[tableIndex].fields.firstIndex(where: { $0.title == reference.field }) {
                        tables[tableIndex].fields[fieldIndex].reference = reference
                    }
                }
                
            }
        }
        
        print(tables)
    }
    
    //MARK: - Private -
    
    private func extractFieldsFrom(string: String) -> [TableField] {
        let fieldsStringFirst = string.components(separatedBy: "(")[0]
        var fieldsString = string.replacingOccurrences(of: fieldsStringFirst, with: "")
        fieldsString = fieldsString.replacingCharacters(in: ...fieldsString.startIndex, with: "")
        let fieldsList = fieldsString.components(separatedBy: ",")
        var fieldsObjects: [TableField] = []
        
        for fieldString in fieldsList {
            if !fieldString.contains("primarykey") {
                let fieldTitle = fieldString.replacingCharacters(in: ...fieldString.startIndex, with: "").components(separatedBy: "`")[0]
                var field = TableField(title: fieldTitle, type: self.fieldTypeFrom(fieldString: fieldString))
                
                if !fieldString.contains("notnull") {
                    field.isNullable = true
                }
                
                if fieldString.contains("auto_increment") {
                    field.isPrimary = true
                }
                
                if fieldString.contains("unique") {
                    field.isUnique = true
                }
                
                if fieldString.contains("default'") {
                    let defaultValue = fieldString.components(separatedBy: "default'").last?.replacingOccurrences(of: "'", with: "")
                    field.defaultValue = defaultValue
                }
                
                fieldsObjects.append(field)
                
            }
            
            
        }
        
        return fieldsObjects
    }
    
    private func fieldTypeFrom(fieldString: String) -> TableFieldType {
        if fieldString.contains("int") {
            return .int
        } else if fieldString.contains("varchar") || fieldString.contains("text") {
            return .string
        } else if fieldString.contains("datetime") {
            return .datetime
        } else if fieldString.contains("timestamp") {
            return .timestamp
        } else {
            return .string
        }
    }
    
    private func extractReferenceFrom(string: String) -> TableReference? {
        if string.contains("references") {
            let table = string.components(separatedBy: "`addconstraint`")[0].replacingOccurrences(of: "altertable`", with: "")
            let field = string.components(separatedBy: "foreignkey(`")[1].components(separatedBy: "`)")[0]
            let toTable = string.components(separatedBy: "references`")[1].components(separatedBy: "`(")[0]
            let toField = string.components(separatedBy: "\(toTable)`(`")[1].components(separatedBy: "`")[0]
            let reference = TableReference(table: table, field: field, toTable: toTable, toField: toField)
            return reference
        }
        
        return nil
    }
    
}
