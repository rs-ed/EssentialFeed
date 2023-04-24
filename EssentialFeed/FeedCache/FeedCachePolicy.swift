//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 22.03.23.
//

import Foundation

final class FeedCachePolicy {
    private init() {}

    private static let calendar = Calendar(identifier: .gregorian)

    private static var macCacheAgeInDays: Int { 7 }

    static func validate(timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheDate = calendar.date(byAdding: .day, value: macCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheDate
    }
}
