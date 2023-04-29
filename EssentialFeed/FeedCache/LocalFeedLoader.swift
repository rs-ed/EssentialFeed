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

    private let store: FeedStore
    private let currentDate: () -> Date
}

extension LocalFeedLoader {
    public typealias SaveResult = Result<Void, Error>

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self else { return }
            switch deletionResult {
            case .success:
                self.cache(feed, with: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate(), completion: { [weak self] result in
            guard self != nil else { return }
            completion(result)
        })
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case let .success(.some(cache)) where FeedCachePolicy.validate(timestamp: cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
            case .success:
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
                self.store.deleteCachedFeed { _ in }
            case let .success(.some(cache)) where !FeedCachePolicy.validate(timestamp: cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
            case .success:
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
