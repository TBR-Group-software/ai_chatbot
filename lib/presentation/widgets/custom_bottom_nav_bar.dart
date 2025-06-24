import 'package:flutter/material.dart';

/// A beautifully designed custom bottom navigation bar with smooth animations and modern styling.
///
/// This widget provides an elegant alternative to Flutter's standard bottom navigation,
/// featuring rounded corners, subtle shadows, and smooth transition animations between
/// tabs. It's specifically designed for the AI Chatbot application's three main sections:
/// Home, Memory, and History.
///
/// The navigation bar implements modern design principles:
/// * **Rounded Design**: Fully rounded container with subtle elevation
/// * **Smooth Animations**: Color and icon transitions with 300ms duration
/// * **Theme Integration**: Respects app-wide color schemes and themes
/// * **Accessibility**: Proper hit testing and gesture handling
/// * **Responsive Layout**: Adapts to different screen sizes and orientations
///
/// Visual features:
/// * **Floating Appearance**: Elevated design with shadow and margin
/// * **State-Based Colors**: Selected and unselected states with distinct colors
/// * **Icon + Label**: Combined icon and text for clear navigation
/// * **Smooth Transitions**: AnimatedSwitcher and AnimatedDefaultTextStyle
/// * **Modern Styling**: Rounded corners and surface container styling
///
/// Example usage:
/// ```dart
/// // Basic bottom navigation bar
/// Scaffold(
///   bottomNavigationBar: CustomBottomNavBar(
///     selectedIndex: _currentIndex,
///     onItemSelected: (index) {
///       setState(() {
///         _currentIndex = index;
///       });
///       _navigateToTab(index);
///     },
///   ),
/// )
///
/// // With route-based navigation
/// CustomBottomNavBar(
///   selectedIndex: context.tabsRouter.activeIndex,
///   onItemSelected: (index) {
///     context.tabsRouter.setActiveIndex(index);
///   },
/// )
///
/// // In a StatefulWidget with tab management
/// class MainPage extends StatefulWidget {
///   @override
///   _MainPageState createState() => _MainPageState();
/// }
///
/// class _MainPageState extends State<MainPage> {
///   int _selectedTab = 0;
///   
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: _buildBody(),
///       bottomNavigationBar: CustomBottomNavBar(
///         selectedIndex: _selectedTab,
///         onItemSelected: _onTabSelected,
///       ),
///     );
///   }
///   
///   void _onTabSelected(int index) {
///     setState(() {
///       _selectedTab = index;
///     });
///   }
/// }
/// ```
///
/// Navigation mapping:
/// * **Index 0**: Home - Main dashboard and quick access
/// * **Index 1**: Memory - AI memory management and storage
/// * **Index 2**: History - Chat history and conversation management
class CustomBottomNavBar extends StatelessWidget {

  /// Creates a custom bottom navigation bar widget.
  ///
  /// Both parameters are required for proper functionality. The widget
  /// manages its own visual state based on the provided [selectedIndex]
  /// and communicates user interactions through [onItemSelected].
  ///
  /// [selectedIndex] The currently active tab index (0-2)
  /// [onItemSelected] Callback for handling tab selection
  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });
  /// The currently selected tab index.
  ///
  /// This value determines which navigation item appears as selected
  /// and should correspond to the currently active page. Valid values
  /// are 0 (Home), 1 (Memory), and 2 (History).
  ///
  /// The selected item will display with the primary theme color and
  /// appropriate visual emphasis.
  final int selectedIndex;
  
  /// Callback invoked when a navigation item is selected.
  ///
  /// This function receives the index of the tapped navigation item
  /// and should handle the navigation logic, such as changing the
  /// displayed page or updating the app's navigation state.
  ///
  /// Example usage:
  /// ```dart
  /// onItemSelected: (index) {
  ///   switch (index) {
  ///     case 0:
  ///       _navigateToHome();
  ///       break;
  ///     case 1:
  ///       _navigateToMemory();
  ///       break;
  ///     case 2:
  ///       _navigateToHistory();
  ///       break;
  ///   }
  /// }
  /// ```
  final Function(int) onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
          bottom: Radius.circular(20),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _NavBarItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: selectedIndex == 0,
              onTap: () => onItemSelected(0),
            ),
            _NavBarItem(
              icon: Icons.archive_rounded,
              label: 'Memory',
              isSelected: selectedIndex == 1,
              onTap: () => onItemSelected(1),
            ),
            _NavBarItem(
              icon: Icons.history_rounded,
              label: 'History',
              isSelected: selectedIndex == 2,
              onTap: () => onItemSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual navigation bar item with icon, label, and selection state.
///
/// This private widget represents a single tab in the custom bottom navigation
/// bar. It handles the visual representation of selection states and provides
/// smooth animations between selected and unselected appearances.
///
/// The item features:
/// * **Animated Icon**: Smooth color transitions using AnimatedSwitcher
/// * **Animated Text**: Color changes with AnimatedDefaultTextStyle
/// * **Proper Sizing**: Fixed dimensions for consistent layout
/// * **Gesture Handling**: Full area tap detection with proper behavior
/// * **Theme Awareness**: Automatic color adaptation to current theme
///
/// This widget is internal to [CustomBottomNavBar] and should not be
/// used directly in other contexts.
class _NavBarItem extends StatelessWidget {

  /// Creates a navigation bar item widget.
  ///
  /// This is a private widget used internally by [CustomBottomNavBar]
  /// and requires all parameters for proper functionality.
  ///
  /// [icon] The icon to display
  /// [label] The text label
  /// [isSelected] The selection state
  /// [onTap] The tap callback
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  /// The icon to display for this navigation item.
  ///
  /// Should be a Material Design icon that clearly represents the
  /// associated app section. The icon color changes based on selection state.
  final IconData icon;
  
  /// The text label displayed below the icon.
  ///
  /// Should be a short, descriptive label that identifies the navigation
  /// destination. The text color changes based on selection state.
  final String label;
  
  /// Whether this navigation item is currently selected.
  ///
  /// When true, the item displays with primary theme colors. When false,
  /// it displays with standard on-surface colors. This drives the
  /// animation transitions.
  final bool isSelected;
  
  /// Callback invoked when this navigation item is tapped.
  ///
  /// Should communicate the selection back to the parent navigation bar
  /// for handling the actual navigation logic.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurface;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 56,
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                key: ValueKey(isSelected),
                color: isSelected ? selectedColor : unselectedColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: 12,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
