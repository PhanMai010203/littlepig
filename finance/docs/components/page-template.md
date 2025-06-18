# 📄 PageTemplate Widget

The `PageTemplate` widget provides a consistent layout structure for all pages in your application, including navigation, theming, and common UI patterns.

## 🎯 Overview

PageTemplate is a wrapper widget that handles:
- App bar with consistent styling
- Automatic theme integration
- Navigation structure
- Safe area handling
- Loading states
- Error handling

## 🚀 Basic Usage

### Simple Page
```dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/app_text.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'My Page',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppText('Page content goes here'),
      ),
    );
  }
}
```

### Page with Custom App Bar
```dart
PageTemplate(
  title: 'Settings',
  showBackButton: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.save),
      onPressed: () => _saveSettings(),
    ),
  ],
  body: _buildSettingsContent(),
)
```

## 🎨 Customization Options

### App Bar Configuration
```dart
PageTemplate(
  title: 'Custom Page',
  
  // Back button control
  showBackButton: true,
  
  // Custom back button action
  onBackPressed: () {
    // Custom logic before going back
    Navigator.pop(context);
  },
  
  // App bar actions
  actions: [
    IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => _shareContent(),
    ),
    IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () => _showMenu(),
    ),
  ],
  
  // Custom app bar styling
  backgroundColor: getColor(context, 'primary'),
  
  body: _buildContent(),
)
```

### Loading States
```dart
class LoadingPage extends StatefulWidget {
  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _isLoading = true;
  
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Data Page',
      isLoading: _isLoading,
      body: _isLoading 
          ? const SizedBox.shrink() // Hidden while loading
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    return Column(
      children: [
        AppText('Data loaded successfully!'),
        // Your content here
      ],
    );
  }
}
```

### Error Handling
```dart
class ErrorPage extends StatelessWidget {
  final String? error;
  
  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Error Page',
      hasError: error != null,
      errorMessage: error,
      onRetry: () => _retryOperation(),
      body: error == null ? _buildContent() : const SizedBox.shrink(),
    );
  }
  
  void _retryOperation() {
    // Retry logic
  }
  
  Widget _buildContent() {
    return AppText('Content loaded successfully');
  }
}
```

## 📱 Layout Patterns

### Scrollable Content
```dart
PageTemplate(
  title: 'Scrollable Page',
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Long Content',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 16),
        
        // Long content that needs scrolling
        for (int i = 0; i < 20; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: AppText('Item ${i + 1}'),
          ),
      ],
    ),
  ),
)
```

### List View Pattern
```dart
PageTemplate(
  title: 'List Page',
  body: ListView.builder(
    padding: const EdgeInsets.all(16.0),
    itemCount: items.length,
    itemBuilder: (context, index) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
          title: AppText(items[index].title),
          subtitle: AppText(
            items[index].description,
            colorName: 'textLight',
          ),
          onTap: () => _onItemTap(items[index]),
        ),
      );
    },
  ),
)
```

### Grid Layout
```dart
PageTemplate(
  title: 'Grid Page',
  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: gridItems.length,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(gridItems[index].icon, size: 48),
                const SizedBox(height: 8),
                AppText(
                  gridItems[index].title,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        );
      },
    ),
  ),
)
```

## 🌟 Advanced Features

### Floating Action Button
```dart
PageTemplate(
  title: 'FAB Page',
  floatingActionButton: FloatingActionButton(
    onPressed: () => _addNewItem(),
    backgroundColor: getColor(context, 'primary'),
    child: const Icon(Icons.add),
  ),
  body: _buildContent(),
)
```

### Bottom Navigation Integration
```dart
PageTemplate(
  title: 'Home',
  showBottomNavigation: true,
  currentNavIndex: 0,
  onNavChanged: (index) => _onNavigationChanged(index),
  body: _buildHomeContent(),
)
```

### Custom Footer
```dart
PageTemplate(
  title: 'Page with Footer',
  body: _buildContent(),
  bottomWidget: Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: getColor(context, 'surface'),
      boxShadow: [
        BoxShadow(
          color: getColor(context, 'shadow'),
          blurRadius: 4,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => _cancel(),
          child: AppText('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _save(),
          style: ElevatedButton.styleFrom(
            backgroundColor: getColor(context, 'primary'),
          ),
          child: AppText('Save', colorName: 'white'),
        ),
      ],
    ),
  ),
)
```

## 🎨 Theming Integration

### Automatic Theme Adaptation
The PageTemplate automatically adapts to your app's theme:

```dart
// The page automatically uses theme colors
PageTemplate(
  title: 'Themed Page',
  
  // App bar automatically uses theme colors
  // Background automatically adapts to light/dark mode
  // Text colors automatically contrast with background
  
  body: Column(
    children: [
      AppText('This text adapts to theme'),
      Container(
        color: getColor(context, 'surface'),
        child: AppText('Surface color container'),
      ),
    ],
  ),
)
```

### Custom Theme Colors
```dart
PageTemplate(
  title: 'Custom Colors',
  backgroundColor: getColor(context, 'primaryLight'),
  appBarBackgroundColor: getColor(context, 'primary'),
  appBarTextColor: getColor(context, 'white'),
  body: _buildContent(),
)
```

## 📊 State Management Integration

### With StatefulWidget
```dart
class StatefulPage extends StatefulWidget {
  @override
  State<StatefulPage> createState() => _StatefulPageState();
}

class _StatefulPageState extends State<StatefulPage> {
  int _counter = 0;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Counter Page',
      isLoading: _isLoading,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _resetCounter,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              'Count: $_counter',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
  
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  
  void _resetCounter() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate async operation
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _counter = 0;
      _isLoading = false;
    });
  }
}
```

## ⚡ Performance Best Practices

### Efficient Rebuilds
```dart
class OptimizedPage extends StatelessWidget {
  const OptimizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Optimized Page',
      
      // Static actions that don't rebuild
      actions: const [
        _StaticActionButton(),
      ],
      
      body: Column(
        children: [
          // Static content
          const _StaticHeader(),
          
          // Dynamic content
          _buildDynamicContent(),
        ],
      ),
    );
  }
  
  Widget _buildDynamicContent() {
    // Only this part rebuilds when needed
    return const Expanded(
      child: _DynamicContentWidget(),
    );
  }
}

class _StaticActionButton extends StatelessWidget {
  const _StaticActionButton();
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => Navigator.pushNamed(context, '/settings'),
    );
  }
}
```

## 🔗 Related Documentation

- [AppText Widget](app-text.md) - Text component documentation
- [Navigation System](../navigation/setup.md) - Navigation setup
- [Theming System](../theming/colors.md) - Theme integration
- [Custom Widgets](custom-widgets.md) - Other available components

## 📋 Complete Example

Here's a comprehensive example showing all PageTemplate features:

```dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../core/theme/app_colors.dart';

class ComprehensivePageExample extends StatefulWidget {
  const ComprehensivePageExample({super.key});

  @override
  State<ComprehensivePageExample> createState() => _ComprehensivePageExampleState();
}

class _ComprehensivePageExampleState extends State<ComprehensivePageExample> {
  bool _isLoading = false;
  String? _error;
  final List<String> _items = [];

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Complete Example',
      showBackButton: true,
      
      // App bar actions
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareContent,
        ),
      ],
      
      // Loading and error states
      isLoading: _isLoading,
      hasError: _error != null,
      errorMessage: _error,
      onRetry: _retryOperation,
      
      // Floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: getColor(context, 'primary'),
        child: const Icon(Icons.add),
      ),
      
      // Main content
      body: _error == null ? _buildContent() : const SizedBox.shrink(),
      
      // Bottom widget
      bottomWidget: _buildBottomBar(),
    );
  }
  
  Widget _buildContent() {
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: getColor(context, 'textLight'),
            ),
            const SizedBox(height: 16),
            AppText(
              'No items yet',
              fontSize: 18,
              colorName: 'textLight',
            ),
            const SizedBox(height: 8),
            AppText(
              'Tap the + button to add your first item',
              fontSize: 14,
              colorName: 'textLight',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            title: AppText(_items[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeItem(index),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: getColor(context, 'surface'),
        boxShadow: [
          BoxShadow(
            color: getColor(context, 'shadow'),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            '${_items.length} items',
            colorName: 'textLight',
          ),
          TextButton(
            onPressed: _items.isNotEmpty ? _clearAll : null,
            child: AppText(
              'Clear All',
              colorName: _items.isNotEmpty ? 'error' : 'textLight',
            ),
          ),
        ],
      ),
    );
  }
  
  // Action methods
  void _refreshData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate random error (20% chance)
      if (DateTime.now().millisecond % 5 == 0) {
        throw Exception('Random error occurred');
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  void _retryOperation() {
    setState(() {
      _error = null;
    });
    _refreshData();
  }
  
  void _addItem() {
    setState(() {
      _items.add('Item ${_items.length + 1}');
    });
  }
  
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }
  
  void _clearAll() {
    setState(() {
      _items.clear();
    });
  }
  
  void _shareContent() {
    // Implement sharing logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing content...')),
    );
  }
}
```

This example demonstrates how PageTemplate provides a complete, flexible foundation for building consistent pages throughout your Flutter application.
