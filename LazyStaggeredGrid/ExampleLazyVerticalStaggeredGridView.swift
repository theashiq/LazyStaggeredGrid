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
    @State private var spacing: CGFloat = 10
    
    public var body: some View {
        LazyVerticalStaggeredGridView(items: (0...99).enumerated().map { ExampleItem.create($0.1) }, columns: columns, spacing: spacing, widthByHeightRatio: widthByHeightRatio) { item, height in
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
