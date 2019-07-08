//
//  GitHubTrendingStore.swift
//  SwiftUIDemo
//
//  Created by Fengwei Liu on 7/7/19.
//  Copyright © 2019 Fengwei Liu. All rights reserved.
//

import SwiftUI
import Combine

final class GitHubTrendingStore : BindableObject {
    var currentLanguage = Language.swift {
        didSet {
            if currentLanguage != oldValue {
                self.storage.removeAll()
                self.subscribers.removeAll()
                didChange.send()
            }
        }
    }

    
    enum Items {
        case loading
        case loaded([GitHubTrendingItem])
        case failed(URLError)
    }

    private var storage: [TimeRange : Items] {
        didSet {
            didChange.send()
        }
    }

    private var subscribers = [TimeRange : AnySubscriber<[GitHubTrendingItem], URLError>]()

    let didChange = PassthroughSubject<Void, Never>()

    init(storage: [TimeRange : Items] = [:]) {
        self.storage = storage
    }

    func items(in timeRange: TimeRange) -> Items {
        if let items = storage[timeRange] {
            return items
        } else {
            if subscribers[timeRange] == nil {
                reloadItems(in: timeRange)
            }
            return .loading
        }
    }

    func reloadItems(in timeRange: TimeRange) {
        storage[timeRange] = .loading

        let subscriber = GitHubTrendingAPI.fetchTrendingItems(for: currentLanguage, in: timeRange)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.storage[timeRange] = .failed(error)
                }
                self?.subscribers[timeRange] = nil
            }) { [weak self] items in
                self?.storage[timeRange] = .loaded(items)
            }

        self.subscribers[timeRange] = AnySubscriber(subscriber)
    }
}
