//
//  ExampleLazyVerticalStaggeredGridView.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct ExampleItem: Identifiable {
    let id: UUID = UUID()
    let color: Color
    let index: Int
    let widthByHeightRatio: CGFloat
    
    init(color: Color, index: Int, widthByHeightRatio: CGFloat) {
        self.color = color
        self.index = index
        self.widthByHeightRatio = widthByHeightRatio
    }
    
    static func create( _ index: Int) -> Self {
        .init(
            color: Color(
                red: .random(in: 0.3...1),
                green: .random(in: 0.3...1),
                blue: .random(in: 0.3...1)
            ),
            index: index,
            widthByHeightRatio: [0.7, 0.8, 1.0, 1.2, 1.4].randomElement()!
        )
    }
}

struct ExampleLazyVerticalStaggeredGridView: View {
    @State private var columns: Int = 3
    @State private var verticalSpacing: CGFloat = 10
    @State private var horizontalSpacing: CGFloat = 10
    
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
                Slider(value: $verticalSpacing, in: 0...20.0, step: 1.0)
                Text("\(Int(verticalSpacing))")
            }
            
            HStack {
                Text("Horizontal Spacing:")
                Slider(value: $horizontalSpacing, in: 0...20.0, step: 1.0)
                Text("\(Int(horizontalSpacing))")
            }
        }
        .padding()
    }
    
    private var gridView: some View {
        LazyVerticalStaggeredGridView(items: (0...99).enumerated().map { ExampleItem.create($0.1) }, columns: columns, verticalSpacing: verticalSpacing, horizontalSpacing: horizontalSpacing, widthByHeightRatio: widthByHeightRatio) { item, height in
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
