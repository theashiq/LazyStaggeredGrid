//
//  ExampleLazyVerticalStaggeredGridView.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct ExampleLazyVerticalStaggeredGridView: View {
    @StateObject var viewModel = ExampleLazyVerticalStaggeredGridViewModel()
    @State private var items: [ExampleItem]
    
    @State private var columns: Int = 3
    @State private var verticalSpacing: CGFloat = 10
    @State private var horizontalSpacing: CGFloat = 10
    @State private var scrollToIndex: Int = 10

    
    public init() {
        self.items = (0...99).map(ExampleItem.create)
    }
    
    public var body: some View {
        VStack {
            controls
            gridView
        }
    }
    
    private var controls: some View {
        VStack {
            Divider()
            
            HStack {
                Button("Add 2 Items") {
                    let nextIndex = items.count
                    let newItems = (nextIndex..<nextIndex + 2).map(ExampleItem.create)
                    items.append(contentsOf: newItems)
                    
                    if let lastItem = newItems.last {
                        viewModel.scrollToID = lastItem.id
                    }
                }
                
                Divider().frame(height: 16)
                
                Button("Scroll to index \(scrollToIndex)") {
                    if items.indices.contains(scrollToIndex) {
                        viewModel.scrollToID = items[scrollToIndex].id
                    }
                    scrollToIndex = items.indices.randomElement() ?? 0
                }
                
                Divider().frame(height: 16)
                
                Button("Clear All") {
                    items.removeAll()
                }
            }
            
            Divider()
            
            Section("Spacing") {
                HStack {
                    Text("Vertical Spacing:").frame(width: UIScreen.main.bounds.width / 2, alignment: .trailing)
                    HStack {
                        Slider(value: $verticalSpacing, in: -10...20.0, step: 1.0)
                        Text("\(Int(verticalSpacing))")
                    }.frame(alignment: .leading)
                }
                
                HStack {
                    Text("Horizntal Spacing:").frame(width: UIScreen.main.bounds.width / 2, alignment: .trailing)
                    HStack {
                        Slider(value: $horizontalSpacing, in: -10...20.0, step: 1.0)
                        Text("\(Int(horizontalSpacing))")
                    }.frame(alignment: .leading)
                }
            }
            
            Divider()
        }
        .padding([.horizontal, .top])
    }
    
    private var gridView: some View {
        LazyVerticalStaggeredGridView(
            items: self.items,
            columns: columns,
            verticalSpacing: verticalSpacing,
            horizontalSpacing: horizontalSpacing,
            scrollTo: $viewModel.scrollToID,
            widthByHeightRatio: widthByHeightRatio
        ) { item, height in
            Rectangle()
                .fill(item.color)
                .cornerRadius(8)
                .overlay(
                    Text("Index: \(item.index)")
                        .foregroundColor(.white)
                        .bold()
                )
                .onAppear {
                    print("appeared \(item.index)")
                }
        }
    }
    
    private func widthByHeightRatio(item: ExampleItem) -> CGFloat {
        return item.widthByHeightRatio
    }
}


struct ExampleLazyVerticalStaggeredGridView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleLazyVerticalStaggeredGridView()
    }
}
