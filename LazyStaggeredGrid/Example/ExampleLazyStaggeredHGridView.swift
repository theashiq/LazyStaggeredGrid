//
//  ExampleLazyStaggeredHGridView.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct ExampleLazyStaggeredHGridView: View {
    @ObservedObject var viewModel: ExampleLazyStaggeredGridViewModel
    var strategy: StaggeredGridChunkingStrategy<ExampleItem>
    var rows: Double
    var verticalSpacing: CGFloat
    var horizontalSpacing: CGFloat
    var scrollToInstance: Int
    
    var body: some View {
        LazyStaggeredHGrid(
            items: viewModel.items,
            rows: Int(rows),
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            scrollTo: $viewModel.scrollToID,
            scrollOffset: $viewModel.scrollOffset,
            widthByHeightRatio: { $0.widthByHeightRatio },
            chunkingStrategy: strategy,
            onItemTap: viewModel.focus
        ) { item, width in
            ExampleItemView(item: item) {
                viewModel.removeItem(item)
            }
            .opacity(viewModel.focusedItemId == item.id ? 0.2 : 1.0)
            .animation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true), value: viewModel.focusedItemId)
        }
    }
}
