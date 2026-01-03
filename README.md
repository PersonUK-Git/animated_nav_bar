# Animated Nav Bar

A highly customizable, animated bottom navigation bar for Flutter. It features a smooth scale effect on tap and syncs perfectly with a `PageController`, supporting drag-to-change-page interactions.

## Features

*   **Smooth Animations**: Scale effects on touch and scroll.
*   **PageController Sync**: Scrolls the bar's indicator when you swipe the `PageView` and vice versa.
*   **Customizable**: Control colors, dimensions, and border radius.
*   **Drag Support**: Drag the nav bar to scrub through pages.

## Demo

![Demo Animation](https://github.com/PersonUK-Git/animated_nav_bar/raw/main/demo.gif)



## Usage

1.  Add `animated_nav_bar` to your `pubspec.yaml` (once published).
2.  Import the package:

```dart
import 'package:animated_nav_bar/animated_nav_bar.dart';
```

3.  Use it in your `Scaffold`:

```dart
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          Container(color: Colors.blue),
          Container(color: Colors.red),
          Container(color: Colors.green),
          Container(color: Colors.purple),
        ],
      ),
      bottomNavigationBar: AnimatedNavBar(
        selectedIndex: _selectedIndex,
        iconSize: 28,
        backgroundColor: Colors.black.withOpacity(0.8),
        indicatorColor: Colors.white.withOpacity(0.2),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        pageController: _pageController,
        icons: const [
          Icons.home,
          Icons.search,
          Icons.notifications,
          Icons.person,
        ],
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}
```

## Customization

| Property | Type | Default | Description |
|---|---|---|---|
| `icons` | `List<IconData>` | Required | List of icons. |
| `selectedIndex` | `int` | Required | Current active index. |
| `onTabSelected` | `ValueChanged<int>` | Required | Callback for tab selection. |
| `pageController` | `PageController` | Required | Controller for the associated PageView. |
| `backgroundColor` | `Color?` | `Black (opacity 0.3)` | Background color of the bar. |
| `indicatorColor` | `Color?` | `White (opacity 0.15)` | Color of the sliding indicator. |
| `selectedItemColor` | `Color?` | `White` | Color of the selected icon. |
| `unselectedItemColor` | `Color?` | `White (opacity 0.5)` | Color of unselected icons. |
| `height` | `double` | `70.0` | Height of the barContainer. |
| `indicatorWidth` | `double` | `70.0` | Width of the indicator pill. |
| `indicatorHeight` | `double` | `60.0` | Height of the indicator pill. |
| `borderRadius` | `BorderRadius?` | `Circular(35)` | Border radius of the bar. |

## License

MIT
