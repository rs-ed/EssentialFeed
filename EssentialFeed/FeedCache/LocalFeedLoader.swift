//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 12.03.23.
//

import Foundation

private final class FeedCachePolicy {
    private let calendar = Calendar(identifier: .gregorian)

    private var macCacheAgeInDays: Int { 7 }

    func validate(timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheDate = calendar.date(byAdding: .day, value: macCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheDate
    }
}

public final class LocalFeedLoader {
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    private let store: FeedStore
    private let currentDate: () -> Date
    private let cachePolicy = FeedCachePolicy()
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] cacheDeletionError in
            guard let self else { return }
            if let cacheDeletionError {
                completion(cacheDeletionError)
            } else {
                cache(feed, with: completion)
            }
        }
    }

    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate(), completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case let .found(feed, timestamp) where cachePolicy.validate(timestamp: timestamp, against: currentDate()):
                completion(.success(feed.toModels()))
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                store.deleteCachedFeed { _ in }
            case let .found(_, timestamp) where !cachePolicy.validate(timestamp: timestamp, against: currentDate()):
                store.deleteCachedFeed { _ in }
            case .empty, .found:
                break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
