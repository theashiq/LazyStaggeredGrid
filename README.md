# LazyStaggeredGrid

A SwiftUI package that provides customizable, and flexible staggered grid layouts.

## Features

*   **Vertical and Horizontal Grids:** Provides both `LazyStaggeredVGrid` and `LazyStaggeredHGrid` for masonry-style layouts.
*   **Lazy Loading:** Efficiently loads and unloads views as they scroll on and off the screen.
*   **Customizable:** Control the number of columns/rows, spacing, and item aspect ratio.
*   **Multiple Chunking Strategies:** Choose from `roundRobin`, `balanced`, or create your own custom strategy.
*   **Scroll Control:** Programmatically scroll to any item and track the scroll offset.
*   **Headers and Footers:** Add custom header and footer views to your grids.

## Requirements

-   iOS 13.0+
-   macOS 11.0+
-   watchOS 7.0+

## Installation

You can add `LazyStaggeredGrid` to your project using Swift Package Manager.

1.  In Xcode, select `File > Add Packages...`.
2.  Enter the repository URL: `https://github.com/theashiq/LazyStaggeredGrid.git`.
3.  Choose the desired version.

## Usage

### Vertical Grid

```swift
import SwiftUI
import LazyStaggeredGrid

struct MyVerticalGridView: View {
    let items: [MyItem]

    var body: some View {
        LazyStaggeredVGrid(items: items, columns: 3) { item, width, height in
            MyItemView(item: item)
        }
    }
}
```

### Horizontal Grid

```swift
import SwiftUI
import LazyStaggeredGrid

struct MyHorizontalGridView: View {
    let items: [MyItem]

    var body: some View {
        LazyStaggeredHGrid(items: items, rows: 3) { item, width, height in
            MyItemView(item: item)
        }
    }
}
```

## Customization

```swift
LazyStaggeredVGrid(
    items: myItems,
    columns: 3,
    verticalSpacing: 10,
    horizontalSpacing: 10,
    showsIndicators: true,
    scrollTo: $scrollToID,
    scrollOffset: $scrollOffset,
    widthByHeightRatio: { item in item.aspectRatio },
    chunkingStrategy: .balanced
) { item, width, height in
    // Your custom item view here
} header: {
    Text("Header")
} footer: {
    Text("Footer")
}
```

## Running the Example App

This repository includes an example app that demonstrates the features of `LazyStaggeredGrid`.

1.  Clone the repository.
2.  Open the `LazyStaggeredGrid.xcworkspace` file in the `LazyStaggeredGridExampleApp` directory.
3.  Select the `LazyStaggeredGridExampleApp` scheme and run.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
