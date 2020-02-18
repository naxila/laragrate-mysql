//
//  Table.swift
//  Migrator MySQL
//
//  Created by Алихан on 14/02/2020.
//  Copyright © 2020 Nexen Origin, LLC. All rights reserved.
//

import Foundation

struct Table {
    let title: String
    var fields: [TableField]
    var backReferences: [TableReference]
    var isAuthTable = false
}

struct TableField {
    let title: String
    var type: TableFieldType
    var defaultValue: String?
    var isPrimary: Bool = false
    var isNullable: Bool = false
    var isUnique: Bool = false
    var reference: TableReference?
}

struct TableReference {
    let table: String
    let field: String
    let toTable: String
    let toField: String
}

enum TableFieldType {
    case int
    case string
    case datetime
    case timestamp
}
