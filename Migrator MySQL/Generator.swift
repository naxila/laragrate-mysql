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
    var isMigrationsNeeded: Bool
    var isModelsNeeded: Bool
    var isAuthTableDefined: Bool
    var authTableName: String
    
    
    //MARK: - Constructors -
    
    init(path: String, sqlCode: String, isMigrationsNeeded: Bool, isModelsNeeded: Bool, isAuthTableDefined: Bool, authTableName: String) {
        self.path = path
        self.sqlCode = sqlCode
        self.isMigrationsNeeded = isMigrationsNeeded
        self.isModelsNeeded = isModelsNeeded
        self.isAuthTableDefined = isAuthTableDefined
        self.authTableName = authTableName
    }
    
    
    //MARK: - Generator -
    
    func start() {
        let parser = MySQLParser()
        let tables = parser.tablesFrom(mysql: self.sqlCode)
        
        if isMigrationsNeeded {
            let migrationsGener = MigrationsGenerator(tables: tables, path: self.path, filesManagerDelegate: self)
            migrationsGener.start()
        }
        
        if true {
            let modelsGener = ModelsGenerator(tables: tables, path: self.path, filesManagerDelegate: self)
            modelsGener.start()
        }
        
    }

}


//MARK: - FilesManagerDelegate

extension Generator: FilesManagerDelegate {
    func readingFailedWith(message: String) {
        self.delegate?.generationDoneWith(fail: true, message: message)
    }
    
    func savingFailedWith(message: String) {
        self.delegate?.generationDoneWith(fail: true, message: message)
    }
    
    func savingDone() {
        self.delegate?.generationDoneWith(fail: false, message: nil)
    }
    
    
}
