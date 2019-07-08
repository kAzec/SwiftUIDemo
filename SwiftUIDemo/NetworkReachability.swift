//
//  NetworkStatus.swift
//  SwiftUIDemo
//
//  Created by Fengwei Liu on 7/1/19.
//  Copyright © 2019 Fengwei Liu. All rights reserved.
//

import SwiftUI
import Combine

final class Reachability : BindableObject {
    private (set) var title = ""
    private (set) var description = ""

    let didChange = PassthroughSubject<Void, Never>()

    init() {

    }
}
