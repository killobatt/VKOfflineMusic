// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDAudioList.swift instead.

import CoreData

enum CDAudioListAttributes: String {
    case identifier = "identifier"
    case title = "title"
}

enum CDAudioListRelationships: String {
    case audios = "audios"
}

@objc
public class _CDAudioList: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "AudioList"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _CDAudioList.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    public var identifier: String

    // func validateIdentifier(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    public var title: String?

    // func validateTitle(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    public var audios: NSOrderedSet

}

extension _CDAudioList {

    public func addAudios(objects: NSOrderedSet) {
        let mutable = self.audios.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.audios = mutable.copy() as! NSOrderedSet
    }

    public func removeAudios(objects: NSOrderedSet) {
        let mutable = self.audios.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.audios = mutable.copy() as! NSOrderedSet
    }

    public func addAudiosObject(value: CDAudio!) {
        let mutable = self.audios.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.audios = mutable.copy() as! NSOrderedSet
    }

    public func removeAudiosObject(value: CDAudio!) {
        let mutable = self.audios.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.audios = mutable.copy() as! NSOrderedSet
    }

}
