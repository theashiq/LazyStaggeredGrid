//
//  LazyStaggeredVGrid.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

@available(iOS 14.0, *)
@available(macOS 11.0, *)
@available(watchOS 7.0, *)
public struct LazyStaggeredVGrid<T: Identifiable, Content: View, Header: View, Footer: View>: View where Header: View, Footer: View {
    private static var coordinateSpace: String { "vGridCoordinateSpace" }

    let items: [T]
    let columns: Int
    let verticalSpacing: CGFloat
    let horizontalSpacing: CGFloat
    let widthByHeightRatio: (T) -> CGFloat
    let chunkingStrategy: StaggeredGridChunkingStrategy<T>
    let showsIndicators: Bool
    @Binding var scrollTo: T.ID?
    @Binding var scrollOffset: CGFloat
    @ViewBuilder let header: () -> Header
    @ViewBuilder let footer: () -> Footer
    @ViewBuilder let itemView: (_ item: T, _ width: CGFloat, _ height: CGFloat) -> Content
    
    public init(
        items: [T],
        columns: Int,
        verticalSpacing: CGFloat = 0,
        horizontalSpacing: CGFloat = 0,
        widthByHeightRatio: @escaping (T) -> CGFloat = { _ in 1.0 },
        chunkingStrategy: StaggeredGridChunkingStrategy<T> = .roundRobin,
        showsIndicators: Bool = false,
        scrollTo: Binding<T.ID?> = .constant(nil),
        scrollOffset: Binding<CGFloat> = .constant(0),
        @ViewBuilder header: @escaping () -> Header = { EmptyView() },
        @ViewBuilder footer: @escaping () -> Footer = { EmptyView() },
        @ViewBuilder itemView: @escaping (_ item: T, _ width: CGFloat, _ height: CGFloat) -> Content
    ) {
        self.items = items
        self.columns = columns
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.widthByHeightRatio = widthByHeightRatio
        self.chunkingStrategy = chunkingStrategy
        self.showsIndicators = showsIndicators
        self._scrollTo = scrollTo
        self._scrollOffset = scrollOffset
        self.header = header
        self.footer = footer
        self.itemView = itemView
    }
    
    public var body: some View {
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollReaderProxy in
                ScrollView(showsIndicators: showsIndicators) {
                    VStack(spacing: 0) {
                        let totalSpacing = horizontalSpacing * CGFloat(columns - 1)
                        let columnWidth = (geometryProxy.size.width - totalSpacing) / CGFloat(columns)
                        let chunkedColumns = chunkColumns(
                            geometryProxy: geometryProxy,
                            items: items,
                            columns: columns,
                            spacing: verticalSpacing,
                            columnWidth: columnWidth
                        )
                        header()
                        scrollOffsetDetectorView
                        HStack(alignment: .top, spacing: horizontalSpacing) {
                            ForEach(chunkedColumns.indices, id: \.self) { col in
                                LazyVStack(spacing: verticalSpacing) {
                                    ForEach(chunkedColumns[col]) { item in
                                        let height = columnWidth / max(widthByHeightRatio(item), 0.01)
                                        itemView(item, columnWidth, height)
                                            .frame(width: columnWidth, height: height)
                                            .id(item.id)
                                    }
                                }
                            }
                        }
                        footer()
                    }
                }
                .coordinateSpace(name: Self.coordinateSpace)
                .onPreferenceChange(StaggeredGridScrollOffsetPreferenceKey.self) { value in
                    self.scrollOffset = value
                }
                .onChange(of: scrollTo) { target in
                    guard let target else { return }
                    withAnimation {
                        scrollReaderProxy.scrollTo(target, anchor: .top)
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
        .frame(width: 0, height: 0)
    }
    
    private func chunkColumns(
        geometryProxy: GeometryProxy,
        items: [T],
        columns: Int,
        spacing: CGFloat,
        columnWidth: CGFloat
    ) -> [[T]] {
        switch chunkingStrategy {
        case .roundRobin:
            var columnData = Array(repeating: [T](), count: columns)
            for (index, item) in items.enumerated() {
                columnData[index % columns].append(item)
            }
            return columnData
            
        case .balanced:
            var columnData = Array(repeating: [T](), count: columns)
            var heights = Array(repeating: CGFloat(0), count: columns)
            
            for item in items {
                let aspectRatio = max(widthByHeightRatio(item), 0.01)
                let estimatedHeight = columnWidth / aspectRatio
                
                var minIndex = 0
                var minHeight = heights[0]
                for i in 1..<heights.count {
                    if heights[i] < minHeight {
                        minHeight = heights[i]
                        minIndex = i
                    }
                }
                
                let spacingToAdd = heights[minIndex] > 0 ? spacing : 0
                heights[minIndex] += estimatedHeight + spacingToAdd
                columnData[minIndex].append(item)
            }
            return columnData
            
        case .custom(let callback):
            return callback(geometryProxy, items, columns, columnWidth, verticalSpacing, horizontalSpacing)
        }
    }
}
