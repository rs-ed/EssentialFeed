//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 23.04.23.
//

import CoreData

final class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet

    static func fetch(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    static func delete(in context: NSManagedObjectContext) throws {
        if let managedCache = try ManagedCache.fetch(in: context) {
            context.delete(managedCache)
        }
    }

    private static func create(in context: NSManagedObjectContext) throws -> ManagedCache {
        ManagedCache(context: context)
    }

    static func createNewSingleInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try delete(in: context)
        return try create(in: context)
    }

    static func managedImages(for feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(
            array: feed.map {
                local in
                let managed = ManagedFeedImage(context: context)
                managed.id = local.id
                managed.imageDescription = local.description
                managed.location = local.location
                managed.url = local.url
                return managed
            }
        )
    }

    func localFeed() -> [LocalFeedImage] {
        return feed
            .compactMap { $0 as? ManagedFeedImage }
            .map { managed in
                LocalFeedImage(
                    id: managed.id,
                    description: managed.imageDescription,
                    location: managed.location,
                    url: managed.url
                )
            }
    }
}

final class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
