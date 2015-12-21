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

### Creating and Opening a Database

Before doing anything with the SQLite API you need to open a database connection. 

*/


/*:

### Create a Table

Create a Contact table with a very basic schema. The table will consist of two columns. The first is `Id` as an `INT` and `PRIMARY KEY`. The second is `Name` as `CHAR(255)`.
*/


/*:

### Insert Row

Now that you have a table created, it's time to insert a row. Add a contact with the an `Id` of `1` and `Name` of `'Ray'`.

*/


/*: 

### Querying

You now have a table and a row within that table. So, prove it! 

*/


//: ### Update


//: ### Delete


//: ### Errors


//: ### Close the database connection


//: Continue to [Making It Swift](@next)
