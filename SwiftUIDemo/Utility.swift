//
//  Utility.swift
//  SwiftUIDemo
//
//  Created by Fengwei Liu on 7/7/19.
//  Copyright © 2019 Fengwei Liu. All rights reserved.
//

import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}
