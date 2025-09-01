//
//  ExampleLazyStaggeredGridViewModel.swift
//  LazyStaggeredGrid
//
//  Created by Ashiqur Rahman on 1/9/25.
//

import SwiftUI

public class ExampleLazyStaggeredGridViewModel: ObservableObject {
    @Published var scrollToID: UUID? = nil
    @Published var scrollOffset: CGFloat = 0
    @Published var items: [ExampleItem] = (0...99).map(ExampleItem.create)
    @Published var focusedItemId: UUID? = nil

    func addItems() {
        let nextIndex = items.count
        let newItems = (nextIndex..<nextIndex + 2).map(ExampleItem.create)
        items.append(contentsOf: newItems)

        if let lastItem = newItems.last {
            scrollToID = lastItem.id
            focus(item: lastItem)
        }
    }
    
    func removeItem(_ item: ExampleItem) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }
    }

    func clearItems() {
        items.removeAll()
    }
    
    func scrollTo(instanceNumber: Int) {
        if let scrollToItem = items.first(where: { $0.instanceNumber == instanceNumber }) {
            scrollToID = scrollToItem.id
            focus(item: scrollToItem)
        }
    }
    
    func scrollToTop() {
        scrollToID = UUID()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            if let targetId = self.items.first?.id {
                self.scrollToID = targetId
            }
        }
    }
    
    func focus(item: ExampleItem) {
        focusedItemId = item.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.focusedItemId = nil
        }
    }
}
