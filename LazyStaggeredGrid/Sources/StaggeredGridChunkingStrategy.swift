//
//  StaggeredGridChunkingStrategy.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

@available(macOS 10.15, *)
public enum StaggeredGridChunkingStrategy<T> {
    case roundRobin
    case balanced
    case custom((
        _ geometry: GeometryProxy,
        _ items: [T],
        _ columns: Int,
        _ columnWidth: CGFloat,
        _ verticalSpacing: CGFloat,
        _ horizontalSpacing: CGFloat
    ) -> [[T]])
}
