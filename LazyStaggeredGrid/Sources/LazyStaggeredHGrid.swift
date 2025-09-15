//
//  LazyStaggeredHGrid.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

@available(iOS 14.0, *)
@available(macOS 11.0, *)
@available(watchOS 7.0, *)
public struct LazyStaggeredHGrid<T: Identifiable, Content: View, Header: View, Footer: View>: View where Header: View, Footer: View {
    private static var coordinateSpace: String { "hGridCoordinateSpace" }

    let items: [T]
    let rows: Int
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
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
        rows: Int,
        horizontalSpacing: CGFloat = 0,
        verticalSpacing: CGFloat = 0,
        widthByHeightRatio: @escaping (T) -> CGFloat = { _ in 1.0 },
        chunkingStrategy: StaggeredGridChunkingStrategy<T> = .roundRobin,
        showsIndicators: Bool = false,
        scrollTo: Binding<T.ID?> = .constant(nil),
        scrollOffset: Binding<CGFloat> = .constant(0),
        onItemTap: @escaping (_ item: T) -> Void = { _ in },
        @ViewBuilder header: @escaping () -> Header = { EmptyView() },
        @ViewBuilder footer: @escaping () -> Footer = { EmptyView() },
        @ViewBuilder itemView: @escaping (_ item: T, _ width: CGFloat, _ height: CGFloat) -> Content
    ) {
        self.items = items
        self.rows = rows
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
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
                ScrollView(.horizontal, showsIndicators: showsIndicators) {
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
                        header()
                        scrollOffsetDetectorView
                        VStack(alignment: .leading, spacing: verticalSpacing) {
                            ForEach(chunkedRows.indices, id: \.self) { row in
                                LazyHStack(spacing: horizontalSpacing) {
                                    ForEach(chunkedRows[row]) { item in
                                        let width = rowHeight * max(widthByHeightRatio(item), 0.01)
                                        itemView(item, width, rowHeight)
                                            .frame(width: width, height: rowHeight)
                                            .id(item.id)
                                    }
                                }
                                .frame(height: rowHeight)
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
