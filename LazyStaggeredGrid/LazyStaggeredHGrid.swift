//
//  LazyStaggeredHGrid.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct LazyStaggeredHGrid<T: Identifiable, Content: View>: View {
    private static var coordinateSpace: String { "hGridCoordinateSpace" }
    
    let items: [T]
    let rows: Int
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    @Binding var scrollTo: T.ID?
    @Binding var scrollOffset: CGFloat
    let widthByHeightRatio: (T) -> CGFloat
    let chunkingStrategy: StaggeredGridChunkingStrategy<T>
    let onItemTap: (T) -> Void
    @ViewBuilder let itemView: (T, CGFloat) -> Content
    
    init(
        items: [T],
        rows: Int,
        horizontalSpacing: CGFloat = 0,
        verticalSpacing: CGFloat = 0,
        scrollTo: Binding<T.ID?> = .constant(nil),
        scrollOffset: Binding<CGFloat> = .constant(0),
        widthByHeightRatio: @escaping (T) -> CGFloat = { _ in 1.0 },
        chunkingStrategy: StaggeredGridChunkingStrategy<T> = .roundRobin,
        onItemTap: @escaping (T) -> Void = { _ in },
        @ViewBuilder itemView: @escaping (T, CGFloat) -> Content
    ) {
        self.items = items
        self.rows = rows
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self._scrollTo = scrollTo
        self._scrollOffset = scrollOffset
        self.widthByHeightRatio = widthByHeightRatio
        self.chunkingStrategy = chunkingStrategy
        self.onItemTap = onItemTap
        self.itemView = itemView
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollReaderProxy in
                ScrollView(.horizontal) {
                    let totalSpacing = verticalSpacing * CGFloat(rows - 1)
                    let contentHeight = geometryProxy.size.height
                    let rowHeight = (contentHeight - totalSpacing) / CGFloat(rows)
                    let chunkedRows = chunkRows(
                        geometryProxy: geometryProxy,
                        items: items,
                        rows: rows,
                        spacing: horizontalSpacing,
                        rowHeight: rowHeight
                    )
                    HStack(spacing: 0) {
                        scrollOffsetDetectorView
                        VStack(alignment: .leading, spacing: verticalSpacing) {
                            ForEach(chunkedRows.indices, id: \.self) { row in
                                LazyHStack(spacing: horizontalSpacing) {
                                    ForEach(chunkedRows[row]) { item in
                                        let width = rowHeight * max(widthByHeightRatio(item), 0.01)
                                        itemView(item, width)
                                            .frame(width: width, height: rowHeight)
                                            .id(item.id)
                                            .onTapGesture { onItemTap(item) }
                                    }
                                }
                                .frame(height: rowHeight)
                            }
                        }
                    }
                }
                .coordinateSpace(name: Self.coordinateSpace)
                .onPreferenceChange(StaggeredGridScrollOffsetPreferenceKey.self) { value in
                    self.scrollOffset = value
                }
                .onChange(of: scrollTo) { targetID in
                    if let targetID {
                        DispatchQueue.main.async {
                            withAnimation {
                                scrollReaderProxy.scrollTo(targetID, anchor: .leading)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var scrollOffsetDetectorView: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(
                    key: StaggeredGridScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named(Self.coordinateSpace)).minX
                )
        }
        .frame(width: 0, height: 0)
    }
    
    private func chunkRows(
        geometryProxy: GeometryProxy,
        items: [T],
        rows: Int,
        spacing: CGFloat,
        rowHeight: CGFloat
    ) -> [[T]] {
        switch chunkingStrategy {
        case .roundRobin:
            var rowData = Array(repeating: [T](), count: rows)
            for (index, item) in items.enumerated() {
                rowData[index % rows].append(item)
            }
            return rowData
            
        case .balanced:
            var rowData = Array(repeating: [T](), count: rows)
            var widths = Array(repeating: CGFloat(0), count: rows)
            
            for item in items {
                let aspectRatio = max(widthByHeightRatio(item), 0.01)
                let estimatedWidth = rowHeight / aspectRatio
                
                var minIndex = 0
                var minWidth = widths[0]
                for i in 1..<widths.count {
                    if widths[i] < minWidth {
                        minWidth = widths[i]
                        minIndex = i
                    }
                }
                
                let spacingToAdd = widths[minIndex] > 0 ? spacing : 0
                widths[minIndex] += estimatedWidth + spacingToAdd
                rowData[minIndex].append(item)
            }
            return rowData
            
        case .custom(let callback):
            return callback(geometryProxy, items, rows, rowHeight, horizontalSpacing, verticalSpacing)
        }
    }
}
