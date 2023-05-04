//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 16.04.23.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    public static let modelName = "FeedStore"
    public static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public struct ModelNotFound: Error {
        public let modelName: String
    }

    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
        }

        container = try NSPersistentContainer.load(
            name: CoreDataFeedStore.modelName,
            model: model,
            url: storeURL
        )
        context = container.newBackgroundContext()
    }

    deinit {
        cleanUpReferencesToPersistentStores()
    }

    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(
                Result {
                    try ManagedCache.fetch(in: context).map {
                        CachedFeed(feed: $0.localFeed(), timestamp: $0.timestamp)
                    }
                }
            )
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(
                Result {
                    do {
                        let managedCache = try ManagedCache.createNewSingleInstance(in: context)
                        managedCache.timestamp = timestamp
                        managedCache.feed = ManagedCache.managedImages(for: feed, in: context)
                        try context.save()
                    } catch {
                        context.rollback()
                        throw error
                    }
                }
            )
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(
                Result {
                    do {
                        try ManagedCache.delete(in: context)
                        if context.hasChanges {
                            try context.save()
                        }
                    } catch {
                        context.rollback()
                        throw error
                    }
                }
            )
        }
    }

    private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        context.perform { [context] in
            action(context)
        }
    }
}
