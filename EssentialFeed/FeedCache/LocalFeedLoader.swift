//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 12.03.23.
//

import Foundation

public final class LocalFeedLoader {
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    public typealias SaveResult = Error?

    private let store: FeedStore
    private let currentDate: () -> Date

    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] cacheDeletionError in
            guard let self else { return }
            if let cacheDeletionError {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }

    private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: currentDate(), completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    }
}