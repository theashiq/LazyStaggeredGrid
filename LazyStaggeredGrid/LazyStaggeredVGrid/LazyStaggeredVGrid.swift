//
//  LazyStaggeredVGrid.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

fileprivate struct StaggeredGridScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}

struct LazyStaggeredVGrid<T: Identifiable, Content: View>: View {
    private static var coordinateSpace: String { "vGridCoordinateSpace" }

    let items: [T]
    let columns: Int
    let verticalSpacing: CGFloat
    let horizontalSpacing: CGFloat
    @Binding var scrollTo: T.ID?
    @Binding var scrollOffset: CGFloat
    let widthByHeightRatio: (T) -> CGFloat
    @ViewBuilder let itemView: (T, CGFloat) -> Content
    
    init(
        items: [T],
        columns: Int,
        verticalSpacing: CGFloat = 0,
        horizontalSpacing: CGFloat = 0,
        scrollTo: Binding<T.ID?> = .constant(nil),
        scrollOffset: Binding<CGFloat> = .constant(0),
        widthByHeightRatio: @escaping (T) -> CGFloat = { _ in 1.0 },
        @ViewBuilder itemView: @escaping (T, CGFloat) -> Content
    ) {
        self.items = items
        self.columns = columns
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self._scrollTo = scrollTo
        self._scrollOffset = scrollOffset
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
                    
                    scrollOffsetDetectorView
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
                }
                .coordinateSpace(name: Self.coordinateSpace)
                .onPreferenceChange(StaggeredGridScrollOffsetPreferenceKey.self) { value in
                    self.scrollOffset = value
                }
                .onChange(of: scrollTo) { targetID in
                    if let targetID {
                        DispatchQueue.main.async {
                            withAnimation {
                                scrollReaderProxy.scrollTo(targetID, anchor: .top)
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
                    value: geometry.frame(in: .named(Self.coordinateSpace)).minY
                )
        }
        .frame(height: 0)
    }
    
    
    private func chunkColumns() -> [[T]] {
        var columnData = Array(repeating: [T](), count: columns)
        for (index, item) in items.enumerated() {
            columnData[index % columns].append(item)
        }
        return columnData
    }
}
