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
    let instanceNumber: Int
    let widthByHeightRatio: CGFloat
    
    init(color: Color, instanceNumber: Int, widthByHeightRatio: CGFloat) {
        self.color = color
        self.instanceNumber = instanceNumber
        self.widthByHeightRatio = widthByHeightRatio
    }
    
    static func create(instanceNumber: Int) -> Self {
        .init(
            color: Color(
                red: .random(in: 0.3...1),
                green: .random(in: 0.3...1),
                blue: .random(in: 0.3...1)
            ),
            instanceNumber: instanceNumber,
            widthByHeightRatio: [0.7, 0.8, 1.0, 1.2, 1.4].randomElement()!
        )
    }
}
