//
//  ExampleLazyStaggeredHGridView.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct ExampleLazyStaggeredHGridView: View {
    @StateObject var viewModel = ExampleLazyStaggeredGridViewModel()
    @State private var strategy: StaggeredGridChunkingStrategy<ExampleItem> = .roundRobin

    // MARK: Grid configuration
    @State private var rows: Double = 3
    @State private var verticalSpacing: CGFloat = 10
    @State private var horizontalSpacing: CGFloat = 10
    @State private var scrollToInstance: Int = 10
    
    public var body: some View {
        VStack {
            controls
            strategyPicker
            gridView
        }
    }
    
    private var controls: some View {
        VStack {
            Divider()
            
            HStack {
                Button("Add 2 Items") {
                    viewModel.addItems()
                }
                Divider().frame(height: 16)
                
                Button("Clear All") {
                    viewModel.clearItems()
                }
                
                Divider().frame(height: 16)
                
                Button("Scroll to: \(scrollToInstance)") {
                    viewModel.scrollTo(instanceNumber: scrollToInstance)
                    scrollToInstance = viewModel.items.indices.randomElement() ?? 0
                }
                .foregroundStyle(viewModel.items.contains {$0.instanceNumber == scrollToInstance} ? .blue : .secondary)
                
                if viewModel.scrollOffset < -100 {
                    Divider().frame(height: 16)
                    Button {
                        viewModel.scrollToTop()
                    } label: {
                        Image(systemName: "chevron.backward.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            
            Divider()
            
            Section("Spacing") {
                Divider()
                HStack {
                    VStack {
                        Text("Vertical")
                        HStack {
                            Slider(value: $verticalSpacing, in: -10...20.0, step: 1.0)
                            Text("\(Int(verticalSpacing))")
                        }
                    }
                    Divider().frame(height: 16)
                    VStack {
                        Text("Horizontal")
                        HStack {
                            Slider(value: $horizontalSpacing, in: -10...20.0, step: 1.0)
                            Text("\(Int(horizontalSpacing))")
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            Section("Number of Rows") {
                Divider()
                HStack {
                    Slider(value: $rows, in: 1.0...10.0, step: 1.0)
                    Text("\(Int(rows))")
                }
                .padding(.horizontal)
            }
            
            Divider()
        }
        .padding([.horizontal, .top])
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
                    strategy = .custom(pyramidChunking)
                }
            }
        )) {
            Text("Round Robin").tag(0)
            Text("Balanced").tag(1)
            Text("Custom Example").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }

    
    private var gridView: some View {
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
        
    let pyramidChunking: (GeometryProxy, [ExampleItem], Int, CGFloat, CGFloat, CGFloat) -> [[ExampleItem]] = { geometry, items, rows, rowHeight, verticalSpacing, horizontalSpacing in
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


struct ExampleLazyHorizontalStaggeredGridView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleLazyStaggeredHGridView()
    }
}
