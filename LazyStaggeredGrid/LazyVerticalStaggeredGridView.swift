//
//  LazyVerticalStaggeredGridView.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct LazyVerticalStaggeredGridView<T: Identifiable, Content: View>: View {
    let items: [T]
    let columns: Int
    let verticalSpacing: CGFloat
    let horizontalSpacing: CGFloat
    @Binding var scrollTo: T.ID?
    let widthByHeightRatio: (T) -> CGFloat
    @ViewBuilder let itemView: (T, CGFloat) -> Content
    
    init(
        items: [T],
        columns: Int,
        verticalSpacing: CGFloat = 0,
        horizontalSpacing: CGFloat = 0,
        scrollTo: Binding<T.ID?> = .constant(nil),
        widthByHeightRatio: @escaping (T) -> CGFloat = { _ in 1.0 },
        @ViewBuilder itemView: @escaping (T, CGFloat) -> Content
    ) {
        self.items = items
        self.columns = columns
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self._scrollTo = scrollTo
        self.widthByHeightRatio = widthByHeightRatio
        self.itemView = itemView
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollReaderProxy in
                ScrollView {
                    let totalSpacing = horizontalSpacing * CGFloat(columns - 1)
                    let contentWidth = geometryProxy.size.width - (horizontalSpacing * 2)
                    let columnWidth = (contentWidth - totalSpacing) / CGFloat(columns)
                    let chunkedColumns = chunkColumns()
                    
                    HStack(alignment: .top, spacing: horizontalSpacing) {
                        ForEach(chunkedColumns.indices, id: \.self) { col in
                            LazyVStack(spacing: verticalSpacing) {
                                ForEach(chunkedColumns[col]) { item in
                                    let height = columnWidth / max(widthByHeightRatio(item), 0.01)
                                    itemView(item, height)
                                        .frame(width: columnWidth, height: height)
                                        .id(item.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, horizontalSpacing)
                    .padding(.top, verticalSpacing)
                }
                .onChange(of: scrollTo) { targetID in
                    if let targetID {
                        withAnimation {
                            scrollReaderProxy.scrollTo(targetID, anchor: .top)
                        }
                    }
                }
            }
        }
    }
    
    private func chunkColumns() -> [[T]] {
        var columnData = Array(repeating: [T](), count: columns)
        for (index, item) in items.enumerated() {
            columnData[index % columns].append(item)
        }
        return columnData
    }
}
