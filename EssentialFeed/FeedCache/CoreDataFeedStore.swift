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
            do {
                if let managedCache = try ManagedCache.fetch(in: context) {
                    completion(.success(.found(feed: managedCache.localFeed(), timestamp: managedCache.timestamp)))
                } else {
                    completion(.success(.empty))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.createNewSingleInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedCache.managedImages(for: feed, in: context)
                try context.save()
                completion(nil)
            } catch {
                context.rollback()
                completion(error)
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.delete(in: context)
                if context.hasChanges {
                    try context.save()
                }
                completion(nil)
            } catch {
                context.rollback()
                completion(error)
            }
        }
    }

    private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        context.perform { [context] in
            action(context)
        }
    }
}
