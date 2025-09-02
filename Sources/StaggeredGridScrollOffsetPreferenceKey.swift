//
//  StaggeredGridScrollOffsetPreferenceKey.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 2/9/25.
//

import SwiftUI

struct StaggeredGridScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}
