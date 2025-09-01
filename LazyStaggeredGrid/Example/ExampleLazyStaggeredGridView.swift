
//
//  ExampleLazyStaggeredGridView.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

enum GridType: String, CaseIterable, Identifiable {
    case vertical = "Vertical"
    case horizontal = "Horizontal"
    var id: String { self.rawValue }
}

struct ExampleLazyStaggeredGridView: View {
    @StateObject var viewModel = ExampleLazyStaggeredGridViewModel()
    @State private var strategy: StaggeredGridChunkingStrategy<ExampleItem> = .roundRobin
    @State private var selectedGridType: GridType = .vertical

    // MARK: Grid configuration
    @State private var columnsOrRows: Double = 3
    @State private var verticalSpacing: CGFloat = 10
    @State private var horizontalSpacing: CGFloat = 10
    @State private var scrollToInstance: Int = 10
    
    public var body: some View {
        VStack {
            gridTypePicker
            strategyPicker
            controls
            gridView
        }
        .padding(.horizontal)
    }
    
    private var gridTypePicker: some View {
        Picker("Grid Type", selection: $selectedGridType) {
            ForEach(GridType.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var controls: some View {
        HStack {
            Menu("Items") {
                Button("Add 2 Items") {
                    viewModel.addItems()
                }
                Button("Clear All") {
                    viewModel.clearItems()
                }
                Button("Scroll to: \(scrollToInstance)") {
                    viewModel.scrollTo(instanceNumber: scrollToInstance)
                    scrollToInstance = viewModel.items.indices.randomElement() ?? 0
                }
                if viewModel.scrollOffset < -100 {
                    Button {
                        viewModel.scrollToTop()
                    } label: {
                        HStack {
                            Text("Go to \(selectedGridType == .vertical ? "Top" : "Lead")")
                            Image(systemName: selectedGridType == .vertical ? "chevron.up.circle" : "chevron.backward.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
            }
            Menu("Sizing") {
                ControlGroup {
                    VStack {
                        Text("Vertical Spacing: \(Int(verticalSpacing))").font(.subheadline)
                        Slider(value: $verticalSpacing, in: -10...20.0, step: 1.0)
                    }
                    
                    VStack {
                        Text("Horizontal Spacing: \(Int(horizontalSpacing))").font(.subheadline)
                        Slider(value: $horizontalSpacing, in: -10...20.0, step: 1.0)
                    }
                    VStack {
                        Text("Number of \(selectedGridType == .vertical ? "Columns" : "Rows"): \(Int(columnsOrRows))").font(.subheadline)
                        Slider(value: $columnsOrRows, in: 1.0...10.0, step: 1.0)
                    }
                }
            }
        }
    }
    
    private var strategyPicker: some View {
        Picker("Strategy", selection: Binding(
            get: {
                switch strategy {
                case .roundRobin: return 0
                case .balanced: return 1
                case .custom: return 2
                }
            },
            set: { (index: Int) in
                switch index {
                case 0:
                    strategy = .roundRobin
                case 1:
                    strategy = .balanced
                default:
                    strategy = .custom(selectedGridType == .vertical ? verticalPyramidChunking : horizontalPyramidChunking)
                }
            }
        )) {
            Text("Round Robin").tag(0)
            Text("Balanced").tag(1)
            Text("Custom(Pyramid)").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var gridView: some View {
        Group {
            if selectedGridType == .vertical {
                ExampleLazyStaggeredVGridView(
                    viewModel: viewModel,
                    strategy: strategy,
                    columns: columnsOrRows,
                    verticalSpacing: verticalSpacing,
                    horizontalSpacing: horizontalSpacing,
                    scrollToInstance: scrollToInstance
                )
            } else {
                ExampleLazyStaggeredHGridView(
                    viewModel: viewModel,
                    strategy: strategy,
                    rows: columnsOrRows,
                    verticalSpacing: verticalSpacing,
                    horizontalSpacing: horizontalSpacing,
                    scrollToInstance: scrollToInstance
                )
            }
        }
    }
    
    let verticalPyramidChunking: (GeometryProxy, [ExampleItem], Int, CGFloat, CGFloat, CGFloat) -> [[ExampleItem]] = { geometry, items, columns, columnWidth, verticalSpacing, horizontalSpacing in
        var columnData = Array(repeating: [ExampleItem](), count: columns)
        var heights = Array(repeating: CGFloat(0), count: columns)
        
        let totalWidth = geometry.size.width
        let isCompact = totalWidth < 400
        
        for item in items {
            let baseHeight = columnWidth / max(item.widthByHeightRatio, 0.01)
            let estimatedHeight = baseHeight + verticalSpacing
            
            // Add bias to center columns
            var weightedHeights = heights.enumerated().map { index, height in
                let centerBias = abs(Double(index - columns / 2)) // more bias further from center
                return (index, height + CGFloat(centerBias) * (isCompact ? 10 : 5)) // boost outer columns
            }
            
            // Add slight randomness when tied (visually helps)
            if weightedHeights.allSatisfy({ $0.1 == weightedHeights.first?.1 }) {
                weightedHeights.shuffle()
            }
            
            if let target = weightedHeights.min(by: { $0.1 < $1.1 })?.0 {
                columnData[target].append(item)
                heights[target] += estimatedHeight
            }
        }
        
        return columnData
    }
    
    let horizontalPyramidChunking: (GeometryProxy, [ExampleItem], Int, CGFloat, CGFloat, CGFloat) -> [[ExampleItem]] = { geometry, items, rows, rowHeight, verticalSpacing, horizontalSpacing in
        var rowData = Array(repeating: [ExampleItem](), count: rows)
        var widths = Array(repeating: CGFloat(0), count: rows)
        
        let totalHeight = geometry.size.height
        let isCompact = totalHeight < 400
        
        for item in items {
            let baseWidth = rowHeight * max(item.widthByHeightRatio, 0.01)
            let estimatedWidth = baseWidth + horizontalSpacing
            
            // Add bias to center rows
            var weightedWidths = widths.enumerated().map { index, width in
                let centerBias = abs(Double(index - rows / 2)) // more bias further from center
                return (index, width + CGFloat(centerBias) * (isCompact ? 10 : 5)) // boost outer rows
            }
            
            // Add slight randomness when tied (visually helps)
            if weightedWidths.allSatisfy({ $0.1 == weightedWidths.first?.1 }) {
                weightedWidths.shuffle()
            }
            
            if let target = weightedWidths.min(by: { $0.1 < $1.1 })?.0 {
                rowData[target].append(item)
                widths[target] += estimatedWidth
            }
        }
        
        return rowData
    }
}

struct ExampleLazyStaggeredGridView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleLazyStaggeredGridView()
    }
}
