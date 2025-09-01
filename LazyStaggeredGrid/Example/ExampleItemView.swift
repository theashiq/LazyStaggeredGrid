//
//  ExampleItemView.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

struct ExampleItemView: View {
    let item: ExampleItem
    let onCrossTapped: () -> Void
    
    var body: some View {
        Rectangle()
            .fill(item.color)
            .cornerRadius(8)
            .overlay(
                Text("Index: \(item.index)")
                    .foregroundColor(.white)
                    .bold()
            )
            .overlay {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .padding(5)
                    .onTapGesture(perform: onCrossTapped)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
    }
}
