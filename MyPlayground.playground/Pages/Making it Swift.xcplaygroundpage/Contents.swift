//: Back to [The C API](@previous)

import Foundation
import SQLite

destroyPart2Database()

/*:

# Making it Swift

As a Swift developer you're probably feeling a little uneasy about what happened in the first part of this tutorial. That C API is a bit painful. The good news is you can take the power of Swift and wrap those C routines up to make things easier to work with. 

*/


//: ## Errors

enum SQLiteError: ErrorType {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

class SQLiteDatabase {
    private let dbPointer: COpaquePointer

    static func open(path: String) throws -> SQLiteDatabase {
        var db: COpaquePointer = nil
        if sqlite3_open(path, &db) == SQLITE_OK {
            return SQLiteDatabase(dbPointer: db)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            
            if let message = String.fromCString(sqlite3_errmsg(db)) {
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }

    private init(dbPointer: COpaquePointer) {
        self.dbPointer = dbPointer
    }

    deinit {
        sqlite3_close(dbPointer)
    }
    
    private var errorMessage: String {
        if let errorMessage = String.fromCString(sqlite3_errmsg(dbPointer)) {
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
}

extension SQLiteDatabase {
    func prepareStatement(sql: String) throws -> COpaquePointer {
        var statement: COpaquePointer = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }
}

extension SQLiteDatabase {
    func createTable(schema: String) throws {
        let createTableStatement = try prepareStatement(schema)
        defer {
            sqlite3_finalize(createTableStatement)
        }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Table created.")
    }
}

struct Contact: CustomDebugStringConvertible {
    let id: Int32
    let name: String
    
    var debugDescription: String {
        return "\(id) | \(name)"
    }
}

extension SQLiteDatabase {
    func insertContact(contact: Contact) throws {
        let insertSql = "INSERT INTO Contact (Id, Name) VALUES (?, ?);"
        let insertStatement = try prepareStatement(insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        let name: NSString = contact.name
        guard sqlite3_bind_int(insertStatement, 1, contact.id) == SQLITE_OK  &&
              sqlite3_bind_text(insertStatement, 2, name.UTF8String, -1, nil) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully inserted row.")
    }
}

extension SQLiteDatabase {
    func contact(id: Int32) -> Contact? {
        let querySql = "SELECT * FROM Contact WHERE Id = ?;"
        guard let queryStatement = try? prepareStatement(querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
            return nil
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            return nil
        }
        
        let id = sqlite3_column_int(queryStatement, 0)
        
        let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
        let name = String.fromCString(UnsafePointer<CChar>(queryResultCol1))!
        
        return Contact(id: id, name: name)
    }
}

extension SQLiteDatabase {
    func updateContact(contact: Contact) throws {
        let updateSql = "UPDATE Contact SET Name = ? WHERE Id = ?;"
        let updateStatement = try prepareStatement(updateSql)
        defer {
            sqlite3_finalize(updateStatement)
        }
        
        let name: NSString = contact.name
        guard sqlite3_bind_text(updateStatement, 1, name.UTF8String, -1, nil) == SQLITE_OK && sqlite3_bind_int(updateStatement, 2, contact.id) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully updated row.")
    }
}

extension SQLiteDatabase {
    func deleteContact(id id: Int32) throws {
        let deleteSql = "DELETE FROM Contact WHERE Id = ?;"
        let deleteStatement = try prepareStatement(deleteSql)
        defer {
            sqlite3_finalize(deleteStatement)
        }
        
        guard sqlite3_bind_int(deleteStatement, 1, id) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully deleted row.")
    }
}

do {
    let db = try SQLiteDatabase.open(part2DbPath)
    
    let contactTableSchema = "CREATE TABLE Contact(" +
        "Id INT PRIMARY KEY NOT NULL," +
        "Name CHAR(255)" +
    ");"

    try db.createTable(contactTableSchema)
    
    try db.insertContact(Contact(id: 1, name: "Ray"))
    db.contact(1)
    
    try db.insertContact(Contact(id: 2, name: "Chris"))
    db.contact(2)
    
    try db.updateContact(Contact(id: 2, name: "Joe"))
    db.contact(2)
    
    try db.deleteContact(id: 2)
    db.contact(2)
    
} catch SQLiteError.OpenDatabase(let message) {
    print(message)
} catch SQLiteError.Prepare(let message) {
    print(message)
} catch SQLiteError.Step(let message) {
    print(message)
}
