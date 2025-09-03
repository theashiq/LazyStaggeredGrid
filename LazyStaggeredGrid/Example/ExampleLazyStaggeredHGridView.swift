//
//  ExampleLazyStaggeredHGridView.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct ExampleLazyStaggeredHGridView<Header: View, Footer: View>: View {
    @ObservedObject var viewModel: ExampleLazyStaggeredGridViewModel
    var strategy: StaggeredGridChunkingStrategy<ExampleItem>
    var rows: Double
    var verticalSpacing: CGFloat
    var horizontalSpacing: CGFloat
    var scrollToInstance: Int
    @ViewBuilder var header: () -> Header
    @ViewBuilder var footer: () -> Footer
    
    init(
        viewModel: ExampleLazyStaggeredGridViewModel,
        strategy: StaggeredGridChunkingStrategy<ExampleItem>,
        rows: Double,
        verticalSpacing: CGFloat,
        horizontalSpacing: CGFloat,
        scrollToInstance: Int,
        @ViewBuilder header: @escaping () -> Header = { EmptyView() },
        @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }
    ) {
        self.viewModel = viewModel
        self.strategy = strategy
        self.rows = rows
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.scrollToInstance = scrollToInstance
        self.header = header
        self.footer = footer
    }
    
    var body: some View {
        LazyStaggeredHGrid(
            items: viewModel.items,
            rows: Int(rows),
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            widthByHeightRatio: { $0.widthByHeightRatio },
            chunkingStrategy: strategy,
            showsIndicators: true,
            scrollTo: $viewModel.scrollToID,
            scrollOffset: $viewModel.scrollOffset,
            onItemTap: viewModel.focus,
            header: header,
            footer: footer
        ) { item, width, height  in
            ExampleItemView(item: item) {
                viewModel.removeItem(item)
            }
            .opacity(viewModel.focusedItemId == item.id ? 0.2 : 1.0)
            .animation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true), value: viewModel.focusedItemId)
        }
    }
}
