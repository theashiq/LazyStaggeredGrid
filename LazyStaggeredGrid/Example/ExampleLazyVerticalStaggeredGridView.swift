//
//  ExampleLazyVerticalStaggeredGridView.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct ExampleLazyVerticalStaggeredGridView: View {
    @State private var columns: Int = 3
    @State private var verticalSpacing: CGFloat = 10
    @State private var horizontalSpacing: CGFloat = 10
    @State private var items: [ExampleItem]
    
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
            HStack {
                Text("Vertical Spacing:")
                Slider(value: $verticalSpacing, in: -10...20.0, step: 1.0)
                Text("\(Int(verticalSpacing))")
            }
            
            HStack {
                Text("Horizontal Spacing:")
                Slider(value: $horizontalSpacing, in: -10...20.0, step: 1.0)
                Text("\(Int(horizontalSpacing))")
            }
        }
        .padding()
    }
    
    private var gridView: some View {
        LazyVerticalStaggeredGridView(items: self.items, columns: columns, verticalSpacing: verticalSpacing, horizontalSpacing: horizontalSpacing, widthByHeightRatio: widthByHeightRatio) { item, height in
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
