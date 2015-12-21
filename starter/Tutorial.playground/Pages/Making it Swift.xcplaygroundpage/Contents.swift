//: Back to [The C API](@previous)

import Foundation
import SQLite
import XCPlayground

destroyPart2Database()

/*:

# Making it Swift

As a Swift developer you're probably feeling a little uneasy about what happened in the first part of this tutorial. That C API is a bit painful. The good news is you can take the power of Swift and wrap those C routines up to make things easier to work with. 

*/


//: ## Errors


//: ## The Database Connection


/*:

### Preparing Statements

This is done so often and in the same way that it makes sense to wrap it to be used in the other wrapped methods.

*/


//: ### Create Table


/*:

### The Contact

Time to define a proper first-class type for the contact record that is being used in the database.

    struct Contact {
        let id: Int32
        let name: String
    }

*/


//: ### Create


//: ### Read


//: ### Update


//: ### Delete


//: ### Read Multiple Rows

