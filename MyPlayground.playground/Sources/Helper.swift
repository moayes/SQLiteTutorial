import XCPlayground
import Foundation

private let tutorialDirectoryUrl = XCPlaygroundSharedDataDirectoryURL.URLByAppendingPathComponent("SQLiteTutorial").URLByResolvingSymlinksInPath!

private enum Database: String {
    case Part1
    
    var path: String {
        return tutorialDirectoryUrl.URLByAppendingPathComponent("\(self.rawValue).sqlite").relativePath!
    }
}

public let part1DbPath = Database.Part1.path


private func destroyDatabase(db: Database) {
    do {
        if NSFileManager.defaultManager().fileExistsAtPath(db.path) {
            try NSFileManager.defaultManager().removeItemAtPath(db.path)
        }
    } catch {
        print("Could not destroy \(db) Database file.")
    }
}

public func destroyPart1Database() {
    destroyDatabase(.Part1)
}