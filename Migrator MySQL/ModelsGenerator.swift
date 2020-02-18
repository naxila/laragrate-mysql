//
//  ModelsGenerator.swift
//  Migrator MySQL
//
//  Created by Алихан on 16/02/2020.
//  Copyright © 2020 Nexen Origin, LLC. All rights reserved.
//

import Foundation

class ModelsGenerator {
    
    //MARK: - Properties -
    private let filesManager = FilesManager(delegate: nil)
    private var tables: [Table]
    private var path: String
    private var filesManagerDelegate: FilesManagerDelegate?
    
    
    //MARK: - Constructor -
    
    init(tables: [Table], path: String, filesManagerDelegate: FilesManagerDelegate?) {
        self.tables = tables
        self.path = path
        self.filesManagerDelegate = filesManagerDelegate
        self.filesManager.delegate = self.filesManagerDelegate
    }
    
    
    //MARK: - Generator -
    
    func start() {
        let tables = self.tables
        
        for table in tables {
            let modelName = self.modelNameFrom(tableName: table.title)
            
            var modelTemplate = self.filesManager.contentsOfTemplateWith(name: "L5ModelTemplate")
            modelTemplate = modelTemplate.replacingOccurrences(of: "%MODEL_NAME%", with: modelName)
            modelTemplate = modelTemplate.replacingOccurrences(of: "%REFERENCES%", with: self.referencesFrom(table: table)).replacingOccurrences(of: "%FILLABLE%", with: self.fillableFrom(table: table))
            self.filesManager.save(string: modelTemplate, with: "app/" + modelName + ".php", at: self.path)
            
        }
        
    }
    
    
    //MARK: - Private -
    
    private func referencesFrom(table: Table) -> String {
        var referencesString = ""
        
        for field in table.fields {
            if let reference = field.reference {
                var refsFunction = self.modelNameFrom(tableName: reference.toTable)
                refsFunction = refsFunction.prefix(1).lowercased() + refsFunction.dropFirst()
                referencesString += "\n\tpublic function \(refsFunction)() {\n" +
                    "\t\treturn $this->belongsTo('App\\\(self.modelNameFrom(tableName: reference.toTable)))');\n" +
                "\t}\n"
            }
        }
        
        for reference in table.backReferences {
            var refsFunction = self.modelNameFrom(tableName: reference.table)
            refsFunction = refsFunction.prefix(1).lowercased() + refsFunction.dropFirst()
            referencesString += "\n\tpublic function \(refsFunction)Objects() {\n" +
                "\t\treturn $this->hasMany('App\\\(self.modelNameFrom(tableName: reference.table)))');\n" +
            "\t}\n"
        }
        
        return referencesString
    }
    
    private func fillableFrom(table: Table) -> String {
        
        var fillable = ""
        
        for field in table.fields {
            fillable += (field.title == table.fields.last?.title) ? "\"\(field.title)\"" : "\"\(field.title)\", "
        }
        
        return fillable
    }
    
    private func modelNameFrom(tableName: String) -> String {
        let modelNameComponents = tableName.components(separatedBy: "_")
        
        var modelName = ""
        
        for component in modelNameComponents {
            modelName += component.capitalized
        }
        
        if modelName.suffix(3) == "ies" {
            modelName = modelName.prefix(modelName.count - 3) + "y"
        } else if modelName == "News" {
            //do nothing
        } else if modelName.suffix(3) == "ses" {
            modelName = modelName.prefix(modelName.count - 3) + "s"
        } else if modelName.suffix(1) == "s" {
            modelName = modelName.prefix(modelName.count - 1) + ""
        }
        return modelName
    }
}
