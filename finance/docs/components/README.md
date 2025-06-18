# 🧩 Components Documentation

Welcome to the components documentation! This section covers all the custom widgets and UI components available in the Flutter boilerplate.

## 📚 Available Components

### Core Components
- **[AppText](app-text.md)** - Primary text component with theme integration
- **[PageTemplate](page-template.md)** - Consistent page layout wrapper
- **[Custom Widgets](custom-widgets.md)** - Additional specialized widgets

## 🎯 Quick Navigation

### Text & Typography
- [AppText Widget](app-text.md#basic-usage) - Basic text usage
- [Color System](app-text.md#color-system-integration) - Text colors
- [Typography Scaling](app-text.md#typography-scaling) - Font sizes and weights
- [Rich Text](app-text.md#rich-text-with-spans) - Multi-style text

### Layout & Structure
- [PageTemplate](page-template.md#basic-usage) - Page wrapper
- [Loading States](page-template.md#loading-states) - Handle loading
- [Error Handling](page-template.md#error-handling) - Error states
- [Layout Patterns](page-template.md#layout-patterns) - Common layouts

### Interactive Elements
- [Adaptive Buttons](custom-widgets.md#theme-responsive-buttons) - Theme-aware buttons
- [Input Fields](custom-widgets.md#input-widgets) - Form inputs
- [Status Cards](custom-widgets.md#status-cards) - Information displays
- [Loading Indicators](custom-widgets.md#loading-indicators) - Progress displays

### Visual Elements
- [Gradient Containers](custom-widgets.md#gradient-containers) - Gradient backgrounds
- [Status Badges](custom-widgets.md#badge-widgets) - Status indicators
- [Image Widgets](custom-widgets.md#image-widgets) - Image handling
- [Chart Widgets](custom-widgets.md#chart-widgets) - Data visualization

## 🚀 Getting Started

### 1. Choose Your Component
Start with the component that best fits your needs:
- For text display → [AppText](app-text.md)
- For page structure → [PageTemplate](page-template.md)
- For specific functionality → [Custom Widgets](custom-widgets.md)

### 2. Import the Component
```dart
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/page_template.dart';
// Import other components as needed
```

### 3. Use with Theme Integration
All components automatically integrate with the app's theme system:
```dart
AppText(
  'Your text here',
  colorName: 'primary', // Automatically adapts to theme
)
```

## 🎨 Design Principles

### Theme Consistency
All components follow these principles:
- **Automatic theme adaptation** - Light/dark mode support
- **Color consistency** - Use predefined color names
- **Typography harmony** - Consistent font sizes and weights
- **Spacing uniformity** - Standard padding and margins

### Performance Optimization
Components are optimized for:
- **Minimal rebuilds** - Efficient state management
- **Memory efficiency** - Proper resource disposal
- **Smooth animations** - 60fps performance target
- **Lazy loading** - Load content when needed

### Accessibility
Built-in accessibility features:
- **Screen reader support** - Semantic labels
- **Keyboard navigation** - Full keyboard support
- **Color contrast** - WCAG compliant colors
- **Touch targets** - Minimum 44px touch areas

## 📱 Responsive Design

### Breakpoints
Components adapt to different screen sizes:

| Breakpoint | Width | Usage |
|------------|-------|-------|
| Mobile | < 480px | Phone portrait |
| Mobile Large | 480px - 768px | Phone landscape, small tablets |
| Tablet | 768px - 1024px | Tablet portrait |
| Desktop | > 1024px | Desktop and large screens |

### Adaptive Behavior
- **Font sizes** scale with screen size
- **Layouts** adjust for different orientations
- **Touch targets** maintain accessibility standards
- **Content density** adapts to available space

## 🛠️ Customization

### Extending Components
You can extend existing components:

```dart
class CustomAppText extends AppText {
  const CustomAppText(
    String text, {
    super.key,
    // Add your custom properties
    this.customProperty,
  }) : super(text);
  
  final String? customProperty;
  
  @override
  Widget build(BuildContext context) {
    // Your custom implementation
    return super.build(context);
  }
}
```

### Creating New Components
Follow the established patterns:

```dart
class MyCustomWidget extends StatelessWidget {
  const MyCustomWidget({
    super.key,
    required this.title,
    this.colorName = 'text',
  });
  
  final String title;
  final String colorName;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getColor(context, 'surface'),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        title,
        colorName: colorName,
      ),
    );
  }
}
```

## 📊 Usage Examples

### Simple Page Layout
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'My Page',
      body: Column(
        children: [
          AppText(
            'Welcome!',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          // Add more components
        ],
      ),
    );
  }
}
```

### Form with Validation
```dart
class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Form Example',
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            ThemedTextField(
              label: 'Name',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            AdaptiveButton(
              text: 'Submit',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Process form
                }
              },
              style: ButtonStyle.primary,
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔗 Related Documentation

- [Getting Started](../getting-started/) - Initial setup and installation
- [Theming System](../theming/) - Color and theme management
- [Navigation](../navigation/) - Page navigation and routing
- [Configuration](../configuration/) - App settings and configuration

## 🐛 Troubleshooting

### Common Issues

**Component not showing correct colors?**
- Ensure you're using `colorName` instead of hardcoded colors
- Check that the color name exists in the theme system

**Layout not responsive?**
- Use `MediaQuery.of(context)` for screen size checks
- Implement breakpoint-based logic for different screen sizes

**Performance issues?**
- Avoid rebuilding static components
- Use `const` constructors where possible
- Implement proper `dispose()` methods for stateful widgets

**Accessibility concerns?**
- Add semantic labels with `Semantics` widget
- Ensure sufficient color contrast
- Test with screen readers

### Getting Help

1. Check the component-specific documentation
2. Review the [troubleshooting guide](../advanced/troubleshooting.md)
3. Look at the complete examples provided
4. Test on different devices and screen sizes

---

## 🌟 Best Practices Summary

1. **Always use theme-aware components** instead of hardcoded styles
2. **Follow the established naming conventions** for consistency
3. **Test on multiple screen sizes** for responsive design
4. **Include accessibility features** from the start
5. **Optimize for performance** with efficient rebuilds
6. **Document custom components** following the same patterns

Start exploring the individual component documentation to learn more about each widget's capabilities and usage patterns!
