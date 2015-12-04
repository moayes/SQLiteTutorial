//: Playground - noun: a place where people can play

import SQLite
import XCPlayground
import Foundation

let directoryUrl = XCPlaygroundSharedDataDirectoryURL
let dbPath = directoryUrl.URLByAppendingPathComponent("database.sqlite")

enum SQLiteResultCode: Int32, Equatable {
    case Ok = 0
    case Error = 1
}

func ==(lhs: Int32, rhs: SQLiteResultCode) -> Bool {
    return lhs == rhs.rawValue
}

//var db: COpaquePointer = nil
//if sqlite3_open(dbPath.absoluteString, &db) == .Ok {
//    print("OK GOT DAH DB")
//} else {
//    print("NO DB")
//}
//
//
//
//var statement: COpaquePointer = nil
//sqlite3_prepare_v2(db, "SELECT name FROM sqlite_master WHERE type='table';", -1, &statement, nil) == .Ok
//sqlite3_step(statement) == SQLITE_DONE
//
//
//
//let createTableString = "CREATE TABLE Contact(" +
//                        "Id INT PRIMARY KEY NOT NULL," +
//                        "Name CHAR(255)" +
//                        ");"
//
//var createTableStatement: COpaquePointer = nil
//sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil)
//sqlite3_step(createTableStatement)
//
//
//let insertStatementString = "INSERT INTO Contact (Id, Name) VALUES (1, 'Chris');"
//var insertStatement: COpaquePointer = nil
//sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil)
//sqlite3_step(insertStatement)
//
//
//let queryStatementString = "SELECT * FROM Contact;"
//var queryStatement: COpaquePointer = nil
//sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
//sqlite3_step(queryStatement)
//let query1Result = sqlite3_column_text(queryStatement, 1)
//String.fromCString(UnsafePointer<CChar>(query1Result))
//
//
//let updateStatementString = "UPDATE Contact SET Name = 'Christopher' WHERE Id = 1"
//var updateStatement: COpaquePointer = nil
//sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil)
//sqlite3_step(updateStatement)
//
//sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
//sqlite3_step(queryStatement)
//let query2Result = sqlite3_column_text(queryStatement, 1)
//String.fromCString(UnsafePointer<CChar>(query2Result))
//

//sqlite3_close(db)

enum SQLiteError: ErrorType {
    case CannotOpenDatabase
}

class SQLiteDatabase {
    let dbPointer: COpaquePointer
    
    static func open(name: String) throws -> SQLiteDatabase {
        var db: COpaquePointer = nil
        if sqlite3_open(directoryUrl.URLByAppendingPathComponent(name).absoluteString, &db) == .Ok {
            return SQLiteDatabase(dbPointer: db)
        } else {
            throw SQLiteError.CannotOpenDatabase
        }
    }
    
    init(dbPointer: COpaquePointer) {
        self.dbPointer = dbPointer
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
}

struct Contact {
    let id: Int
    let name: String
}

extension SQLiteDatabase {
    func insertContact(contact: Contact) {
        let insertStatementString = "INSERT INTO Contact (Id, Name) VALUES (\(contact.id), '\(contact.name)');"
        var insertStatement: COpaquePointer = nil
        sqlite3_prepare_v2(dbPointer, insertStatementString, -1, &insertStatement, nil)
        sqlite3_step(insertStatement)
        String.fromCString(sqlite3_errmsg(dbPointer))
    }
}




do {
    let db = try SQLiteDatabase.open("database.sqlite")
    db.insertContact(Contact(id: 3, name: "Juan"))
    
} catch {
    print("UH OH")
}