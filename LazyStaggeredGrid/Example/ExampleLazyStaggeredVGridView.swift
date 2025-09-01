//
//  ExampleLazyStaggeredVGridView.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct ExampleLazyStaggeredVGridView: View {
    @ObservedObject var viewModel: ExampleLazyStaggeredGridViewModel
    var strategy: StaggeredGridChunkingStrategy<ExampleItem>
    var columns: Double
    var verticalSpacing: CGFloat
    var horizontalSpacing: CGFloat
    var scrollToInstance: Int
    
    var body: some View {
        LazyStaggeredVGrid(
            items: viewModel.items,
            columns: Int(columns),
            verticalSpacing: verticalSpacing,
            horizontalSpacing: horizontalSpacing,
            scrollTo: $viewModel.scrollToID,
            scrollOffset: $viewModel.scrollOffset,
            widthByHeightRatio: { $0.widthByHeightRatio },
            chunkingStrategy: strategy,
            onItemTap: viewModel.focus
        ) { item, height in
            ExampleItemView(item: item) {
                viewModel.removeItem(item)
            }
            .opacity(viewModel.focusedItemId == item.id ? 0.2 : 1.0)
            .animation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true), value: viewModel.focusedItemId)
        }
    }
}
