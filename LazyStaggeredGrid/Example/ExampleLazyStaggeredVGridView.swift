//
//  ExampleLazyStaggeredVGridView.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct ExampleLazyStaggeredVGridView: View {
    @StateObject var viewModel = ExampleLazyStaggeredVGridViewModel()
    @State private var strategy: StaggeredGridChunkingStrategy<ExampleItem> = .roundRobin

    // MARK: Grid configuration
    @State private var columns: Double = 3
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
                        Image(systemName: "chevron.up.circle")
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
            
            Section("Number of Columns") {
                Divider()
                HStack {
                    Slider(value: $columns, in: 1.0...10.0, step: 1.0)
                    Text("\(Int(columns))")
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
                }
            },
            set: { (index: Int) in
                switch index {
                case 0:
                    strategy = .roundRobin
                case 1:
                    strategy = .balanced
                default:
                    strategy = .balanced
                }
            }
        )) {
            Text("Round Robin").tag(0)
            Text("Balanced").tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }

    
    private var gridView: some View {
        LazyStaggeredVGrid(
            items: viewModel.items,
            columns: Int(columns),
            verticalSpacing: verticalSpacing,
            horizontalSpacing: horizontalSpacing,
            scrollTo: $viewModel.scrollToID,
            scrollOffset: $viewModel.scrollOffset,
            widthByHeightRatio: { $0.widthByHeightRatio },
            chunkingStrategy: strategy,
            onItemTap: viewModel.focus
        ) { item, height in
            ExampleItemView(item: item) {
                viewModel.removeItem(item)
            }
            .opacity(viewModel.focusedItemId == item.id ? 0.2 : 1.0)
            .animation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true), value: viewModel.focusedItemId)
        }
    }
}


struct ExampleLazyVerticalStaggeredGridView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleLazyStaggeredVGridView()
    }
}
