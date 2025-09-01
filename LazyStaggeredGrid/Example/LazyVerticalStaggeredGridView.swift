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
    let spacing: CGFloat
    let widthByHeightRatio: (T) -> CGFloat
    @ViewBuilder let itemView: (T, CGFloat) -> Content
    
    init(
        items: [T],
        columns: Int,
        spacing: CGFloat = 0,
        widthByHeightRatio: @escaping (T) -> CGFloat = { _ in 1.0 },
        @ViewBuilder itemView: @escaping (T, CGFloat) -> Content
    ) {
        self.items = items
        self.columns = columns
        self.spacing = spacing
        self.widthByHeightRatio = widthByHeightRatio
        self.itemView = itemView
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollReaderProxy in
                ScrollView {
                    let totalSpacing = spacing * CGFloat(columns - 1)
                    let contentWidth = geometryProxy.size.width - (spacing * 2)
                    let columnWidth = (contentWidth - totalSpacing) / CGFloat(columns)
                    let chunkedColumns = chunkColumns()
                    
                    HStack(alignment: .top, spacing: spacing) {
                        ForEach(chunkedColumns.indices, id: \.self) { col in
                            LazyVStack(spacing: spacing) {
                                ForEach(chunkedColumns[col]) { item in
                                    let height = columnWidth / max(widthByHeightRatio(item), 0.01)
                                    itemView(item, height)
                                        .frame(width: columnWidth, height: height)
                                        .id(item.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, spacing)
                    .padding(.top, spacing)
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
