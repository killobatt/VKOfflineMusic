// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDLyrics.swift instead.

import CoreData

enum CDLyricsAttributes: String {
    case id = "id"
    case text = "text"
}

enum CDLyricsRelationships: String {
    case audio = "audio"
}

@objc
public class _CDLyrics: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Lyrics"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _CDLyrics.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    public var id: NSNumber?

    // func validateId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    public var text: String?

    // func validateText(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    public var audio: CDAudio?

    // func validateAudio(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

