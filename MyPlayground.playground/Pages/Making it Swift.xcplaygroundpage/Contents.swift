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
    func createTable(schema: String) throws {
        var createTableStatement: COpaquePointer = nil
        defer {
            sqlite3_finalize(createTableStatement)
        }
        
        if sqlite3_prepare_v2(dbPointer, schema, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Table created.")
            } else {
                throw SQLiteError.Step(message: errorMessage)
            }
        } else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
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
        let insertStatementString = "INSERT INTO Contact (Id, Name) VALUES (?, ?);"
        var insertStatement: COpaquePointer = nil
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        if sqlite3_prepare_v2(dbPointer, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            let name: NSString = contact.name
            
            sqlite3_bind_int(insertStatement, 1, contact.id)
            sqlite3_bind_text(insertStatement, 2, name.UTF8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                throw SQLiteError.Step(message: errorMessage)
            }
        } else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
    }
}

extension SQLiteDatabase {
    func contact(id: Int32) -> Contact? {
        let queryStatementString = "SELECT * FROM Contact WHERE Id = ?;"
        var queryStatement: COpaquePointer = nil
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        if sqlite3_prepare_v2(dbPointer, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, id)
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let name = String.fromCString(UnsafePointer<CChar>(queryResultCol1))!
                
                return Contact(id: id, name: name)
                
            } else {
                return nil
            }
        } else {
            print("SELECT statement could not be prepared")
            return nil
        }
    }
}

extension SQLiteDatabase {
    func updateContact(contact: Contact) throws {
        let updateStatementString = "UPDATE Contact SET Name = ? WHERE Id = ?"
        var updateStatement: COpaquePointer = nil
        defer {
            sqlite3_finalize(updateStatement)
        }
        
        if sqlite3_prepare_v2(dbPointer, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            let name: NSString = contact.name
            
            sqlite3_bind_text(updateStatement, 1, name.UTF8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, contact.id)
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                throw SQLiteError.Step(message: errorMessage)
            }
        } else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
    }
}

extension SQLiteDatabase {
    func deleteContact(id id: Int32) throws {
        let deleteStatementStirng = "DELETE FROM Contact WHERE Id = ?"
        var deleteStatement: COpaquePointer = nil
        defer {
            sqlite3_finalize(deleteStatement)
        }
        
        if sqlite3_prepare_v2(dbPointer, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(deleteStatement, 1, id)
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                throw SQLiteError.Step(message: errorMessage)
            }
        } else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
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
