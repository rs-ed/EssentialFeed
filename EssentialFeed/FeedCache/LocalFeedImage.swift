//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Roland Schmitz on 12.03.23.
//

import Foundation

public struct LocalFeedImage: Equatable {
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }

    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
}
