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

*/

//: ## Open a Connection

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


//: ## Create a Table

let createTableString = "CREATE TABLE Contact(" +
  "Id INT PRIMARY KEY NOT NULL," +
  "Name CHAR(255)" +
");"

func createTable() {
  // 1
  var createTableStatement: COpaquePointer = nil
  // 2
  if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
    // 3
    if sqlite3_step(createTableStatement) == SQLITE_DONE {
      print("Contact table created.")
    } else {
      print("Contact table could not be created.")
    }
  } else {
    print("CREATE TABLE statement could not be prepared.")
  }
  // 4
  sqlite3_finalize(createTableStatement)
}

createTable()

//: ## Insert a Contact

let insertStatementString = "INSERT INTO Contact (Id, Name) VALUES (?, ?);"

func insert() {
  var insertStatement: COpaquePointer = nil
  
  // 1
  if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
    let id: Int32 = 1
    let name: NSString = "Ray"
    
    // 2
    sqlite3_bind_int(insertStatement, 1, id)
    // 3
    sqlite3_bind_text(insertStatement, 2, name.UTF8String, -1, nil)
    
    // 4
    if sqlite3_step(insertStatement) == SQLITE_DONE {
      print("Successfully inserted row.")
    } else {
      print("Could not insert row.")
    }
  } else {
    print("INSERT statement could not be prepared.")
  }
  // 5
  sqlite3_finalize(insertStatement)
}

insert()

//: ## Querying

let queryStatementString = "SELECT * FROM Contact;"


func query() {
  var queryStatement: COpaquePointer = nil
  // 1
  if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
    // 2
    if sqlite3_step(queryStatement) == SQLITE_ROW {
      // 3
      let id = sqlite3_column_int(queryStatement, 0)
      
      // 4
      let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
      let name = String.fromCString(UnsafePointer<CChar>(queryResultCol1))!
      
      // 5
      print("Query Result:")
      print("\(id) | \(name)")
      
    } else {
      print("Query returned no results")
    }
  } else {
    print("SELECT statement could not be prepared")
  }
  
  // 6
  sqlite3_finalize(queryStatement)
}

query()

//: ## Update

let updateStatementString = "UPDATE Contact SET Name = 'Chris' WHERE Id = 1;"

func update() {
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


//: ## Delete

let deleteStatementStirng = "DELETE FROM Contact WHERE Id = 1;"

func delete() {
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


//: ## Errors

let malformedQueryString = "SELECT Stuff from Things WHERE Whatever;"

func prepareMalformedQuery() {
  var malformedStatement: COpaquePointer = nil
  // 1
  if sqlite3_prepare_v2(db, malformedQueryString, -1, &malformedStatement, nil) == SQLITE_OK {
    print("This should not have happened.")
  } else {
    // 2
    let errorMessage = String.fromCString(sqlite3_errmsg(db))!
    print("Query could not be prepared! \(errorMessage)")
  }
  
  // 3
  sqlite3_finalize(malformedStatement)
}

prepareMalformedQuery()


//: ## Close the database connection

sqlite3_close(db)


//: Continue to [Making It Swift](@next)
