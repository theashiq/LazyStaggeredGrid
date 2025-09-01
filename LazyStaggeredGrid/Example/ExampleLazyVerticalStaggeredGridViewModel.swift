import SwiftUI

public class ExampleLazyVerticalStaggeredGridViewModel: ObservableObject {
    @Published var scrollToID: UUID? = nil
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

    func clearItems() {
        items.removeAll()
    }
    
    func scrollTo(index: Int) {
        if items.indices.contains(index) {
            scrollToID = items[index].id
            focusedItemId = items[index].id
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                self.focusedItemId = nil
            }
        }
    }
}
