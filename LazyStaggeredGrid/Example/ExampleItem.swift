//
//  ExampleItem.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct ExampleItem: Identifiable, Hashable {
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
