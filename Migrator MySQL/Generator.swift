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
        let migrationsGener = MigrationsGenerator(tables: tables, path: self.path, filesManagerDelegate: self)
        migrationsGener.start()
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
