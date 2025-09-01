import SwiftUI

public class ExampleLazyVerticalStaggeredGridViewModel: ObservableObject {
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
            focusedItemId = lastItem.id
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                self.focusedItemId = nil
            }
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
    
    func scrollTo(index: Int) {
        if let targetId = items.first(where: { $0.index == index })?.id {
            scrollToID = targetId
            focusedItemId = targetId
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.focusedItemId = nil
            }
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
}
