// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDAudio.swift instead.

import CoreData

enum CDAudioAttributes: String {
    case albumID = "albumID"
    case artist = "artist"
    case duration = "duration"
    case genreID = "genreID"
    case id = "id"
    case localFileName = "localFileName"
    case ownerID = "ownerID"
    case remoteURLString = "remoteURLString"
    case title = "title"
}

enum CDAudioRelationships: String {
    case lists = "lists"
    case lyrics = "lyrics"
}

@objc
public class _CDAudio: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Audio"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _CDAudio.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    public var albumID: NSNumber?

    // func validateAlbumID(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    public var artist: String?

    // func validateArtist(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    public var duration: NSNumber?

    // func validateDuration(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    public var genreID: NSNumber?

    // func validateGenreID(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    public var id: NSNumber?

    // func validateId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    public var localFileName: String?

    // func validateLocalFileName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    public var ownerID: NSNumber?

    // func validateOwnerID(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    public var remoteURLString: String?

    // func validateRemoteURLString(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    public var title: String?

    // func validateTitle(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    public var lists: NSSet

    @NSManaged
    public var lyrics: CDLyrics?

    // func validateLyrics(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

extension _CDAudio {

    public func addLists(objects: NSSet) {
        let mutable = self.lists.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.lists = mutable.copy() as! NSSet
    }

    public func removeLists(objects: NSSet) {
        let mutable = self.lists.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.lists = mutable.copy() as! NSSet
    }

    public func addListsObject(value: CDAudioList!) {
        let mutable = self.lists.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.lists = mutable.copy() as! NSSet
    }

    public func removeListsObject(value: CDAudioList!) {
        let mutable = self.lists.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.lists = mutable.copy() as! NSSet
    }

}
