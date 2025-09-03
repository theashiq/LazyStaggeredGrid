# LazyStaggeredGrid

While SwiftUI's built-in `LazyVGrid` and `LazyHGrid` provide efficient regular grid layouts, they do not natively support staggered or masonry-style layouts, like a Pinterest grid. `LazyStaggeredGrid` is a SwiftUI package that fills this gap by providing highly performant, customizable, and flexible staggered grid layouts for your iOS applications. It supports both vertical and horizontal orientations, along with various chunking strategies to optimize content distribution.

## Features

-   **Vertical Staggered Grid (`LazyStaggeredVGrid`):** Efficiently displays content in a vertical, masonry-style layout.
-   **Horizontal Staggered Grid (`LazyStaggeredHGrid`):** Provides a horizontal, masonry-style layout for your views.
-   **Customizable Columns/Rows:** Easily define the number of columns (for vertical) or rows (for horizontal).
-   **Flexible Spacing:** Control vertical and horizontal spacing between items.
-   **Multiple Chunking Strategies:**
    -   **Round Robin:** Distributes items evenly across columns/rows in a sequential manner.
    -   **Balanced:** Attempts to balance the height/width of columns/rows for a more visually appealing layout.
    -   **Custom:** Allows you to define your own logic for distributing items.
-   **Scroll Offset Tracking:** Provides a mechanism to track the scroll position of the grid.
-   **Scroll to Item:** Programmatically scroll to a specific item within the grid.
-   **Header and Footer Support:** Add custom header and footer views to your staggered grids.

-   **Scroll Indicator Control:** Show or hide scroll indicators with the `showsIndicators` parameter.

## Requirements

-   iOS 13.0+
-   macOS 11.0+
-   watchOS 7.0+
-   Swift 5.3+ (or compatible with Xcode 12.0+)

## Installation

### Swift Package Manager

You can add `LazyStaggeredGrid` to your project using Swift Package Manager.

1.  In Xcode, select `File > Add Packages...`.
2.  Enter the repository URL: `https://github.com/theashiq/LazyStaggeredGrid.git`.
3.  Choose the desired version (e.g., `Up to Next Major Version` with `1.1.0`).
4.  Click `Add Package`.

## Usage

### Basic Vertical Grid

```swift
import SwiftUI
import LazyStaggeredGrid

struct MyVerticalGridView: View {
    let items = (0..<100).map { ExampleItem(id: UUID(), instanceNumber: $0) }

    var body: some View {
        LazyStaggeredVGrid(items: items, columns: 3) { item, width, height in
            Text("Item \(item.instanceNumber)")
                .frame(width: width, height: height)
                .background(Color.blue.opacity(0.5))
                .cornerRadius(8)
        }
        .padding()
    }
}
```

### Basic Horizontal Grid

```swift
import SwiftUI
import LazyStaggeredGrid

struct MyHorizontalGridView: View {
    let items = (0..<100).map { ExampleItem(id: UUID(), instanceNumber: $0) }

    var body: some View {
        LazyStaggeredHGrid(items: items, rows: 3) { item, width, height in
            Text("Item \(item.instanceNumber)")
                .frame(width: width, height: height)
                .background(Color.green.opacity(0.5))
                .cornerRadius(8)
        }
        .padding()
    }
}
```

### Customization

`LazyStaggeredGrid` offers various parameters for customization:

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
    chunkingStrategy: .balanced // or .roundRobin, .custom
) { item, width, height in
    // Your custom item view here
} header: {
    Text("My Custom Header")
        .font(.largeTitle)
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.2))
} footer: {
    Text("My Custom Footer")
        .font(.caption)
        .frame(maxWidth: .infinity)
        .background(Color.yellow.opacity(0.2))
}
```

## Examples

For comprehensive usage examples and an interactive demonstration of `LazyStaggeredGrid`'s capabilities, please refer to the `LazyStaggeredGridExampleApp` folder on the [example branch](https://github.com/theashiq/LazyStaggeredGrid/tree/example) of this repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.