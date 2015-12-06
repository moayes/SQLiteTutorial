import SQLite
import XCPlayground
import Foundation

destroyPart1Database()

/*: 

# Getting Started

The first thing to do is set your playground to run manually rather than automatically. This will help ensure that your SQL commands run when you intend them to. At the bottom of the playground click and hold the Play button until the dropdown menu appears. Choose "Manually Run". 

You will also notice a `destroyPart1Database()` call at the top of this page. You can safely ignore this, the database file used is destroyed each time the playground is run to ensure all statements execute successfully as you iterate through the tutorial.

Secondly, this Playground will need to write SQLite database files to your file system. Create the directory `~/Documents/Shared Playground Data/SQLiteTutorial` by running the following command in Terminal.

`mkdir -p ~/Documents/Shared\ Playground\ Data/SQLiteTutorial`

## The C API

The first part of this tutorial will cover writing directly against some of the most common and basic SQLite APIs. It is good to get an understanding of how to write against them using Swift. You may quickly find that wrapping the C API in Swift functions would be ideal, but sit tight as you will be doing just that in the second part of the tutorial.

### Creating and Opening a Database

Before doing anything with the SQLite API you need to open a database connection. 

*/

func openDatabase() -> COpaquePointer {
    var db: COpaquePointer = nil
    if sqlite3_open(part1DbPath, &db) == SQLITE_OK {
        print("Successfully opened connection to database at \(part1DbPath)")
        return db
    } else {
        print("Unable to open database. Verify that you created the directory described in the Getting Started section.")
        XCPlaygroundPage.currentPage.finishExecution()
    }
}

let db = openDatabase()

/*: 

The `sqlite3_open()` function attempts to open a connection to a database file at the specified location. If one does not exist it will write one to the provided location. When successful the passed in pointer is written to. This pointer is used in all subsequent functions to interact with the database connection.

Many of the sqlite3 functions will return an `Int32` result code. A list of the different result codes can be seen [here](https://www.sqlite.org/rescode.html). These are also defined as constants by the sqlite library, `SQLITE_OK` is a constant for the result code `0`.

*/

/*:

### Create a Table

Create a Contact table with a very basic schema. The table will consist of two columns. The first is `Id` as an `INT` and `PRIMARY KEY`. The second is `Name` as `CHAR(255)`.
*/

func createTable() {
    let createTableString = "CREATE TABLE Contact(" +
        "Id INT PRIMARY KEY NOT NULL," +
        "Name CHAR(255)" +
    ");"
    
    var createTableStatement: COpaquePointer = nil
    if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
        if sqlite3_step(createTableStatement) == SQLITE_DONE {
            print("Contact table created.")
        } else {
            print("Contact table could not be created.")
        }
    } else {
        print("CREATE TABLE statement could not be prepared.")
    }
    sqlite3_finalize(createTableStatement)
}

createTable()


/*:

### Insert Row

Now that you have a table created, it's time to insert a row. Add a contact with the an `Id` of `1` and `Name` of `'Ray'`.

*/

func insert() {
    let insertStatementString = "INSERT INTO Contact (Id, Name) VALUES (?, ?);"
    var insertStatement: COpaquePointer = nil
    
    if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
        let id: Int32 = 1
        let name: NSString = "Ray"
        
        sqlite3_bind_int(insertStatement, 1, id)
        sqlite3_bind_text(insertStatement, 2, name.UTF8String, -1, nil)
        
        if sqlite3_step(insertStatement) == SQLITE_DONE {
            print("Successfully inserted row.")
        } else {
            print("Could not insert row.")
        }
    } else {
        print("INSERT statement could not be prepared.")
    }
    sqlite3_finalize(insertStatement)
}

insert()


/*: 

### Querying

You now have a table and a row within that table. So, prove it! 

*/

func query() {
    let queryStatementString = "SELECT * FROM Contact;"
    var queryStatement: COpaquePointer = nil
    if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
        if sqlite3_step(queryStatement) == SQLITE_ROW {
            let id = sqlite3_column_int(queryStatement, 0)
            
            let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
            let name = String.fromCString(UnsafePointer<CChar>(queryResultCol1))!
            
            print("Query Result:")
            print("\(id) | \(name)")
            
        } else {
            print("Query returned no results")
        }
    } else {
        print("SELECT statement could not be prepared")
    }
    sqlite3_finalize(queryStatement)
}

query()

/*: 

### Update

*/

func update() {
    let updateStatementString = "UPDATE Contact SET Name = 'Chris' WHERE Id = 1;"
    var updateStatement: COpaquePointer = nil
    if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
        if sqlite3_step(updateStatement) == SQLITE_DONE {
            print("Successfully updated row.")
        } else {
            print("Could not update row.")
        }
    } else {
        print("UPDATE statement could not be prepared")
    }
    sqlite3_finalize(updateStatement)
}

update()
query()

/*: 

### Delete

*/

func delete() {
    let deleteStatementStirng = "DELETE FROM Contact WHERE Id = 1;"
    var deleteStatement: COpaquePointer = nil
    if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
        if sqlite3_step(deleteStatement) == SQLITE_DONE {
            print("Successfully deleted row.")
        } else {
            print("Could not delete row.")
        }
    } else {
        print("DELETE statement could not be prepared")
    }
    
    sqlite3_finalize(deleteStatement)
}

delete()
query()

/*: 

### Errors

So far, you've hopefully not run into any SQlite errors. But the time will come where you will make a call that doesn't make sense or simply write a query that cannot be compiled. Getting the error message when these things happen can save you a lot of development time. It also gives you the opportunity to present meaningful error messages to a user if appropriate.

*/

func prepareMalformedQuery() {
    let malformedQueryString = "SELECT Stuff from Things WHERE Whatever;"
    var malformedStatement: COpaquePointer = nil
    if sqlite3_prepare_v2(db, malformedQueryString, -1, &malformedStatement, nil) == SQLITE_OK {
        print("This should not have happened.")
    } else {
        let errorMessage = String.fromCString(sqlite3_errmsg(db))!
        print("Query could not be prepared! \(errorMessage)")
    }
    
    sqlite3_finalize(malformedStatement)
}

prepareMalformedQuery()

/*:

### Close the database connection

*/

sqlite3_close(db)


//: Continue to [Making It Swift](@next)
