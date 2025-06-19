# 🎬 Animation & Dialog Framework Implementation Plan

**Objective**: Integrate a comprehensive animation and dialog framework inspired by the budget project's elegant system into the Finance app, creating smooth, reusable, and consistent user interactions.

## 📊 Current State Analysis

### Finance Project (Current)
✅ **Strengths:**
- Clean navigation framework with GoRouter
- Basic bounce animations in bottom navigation
- App settings system with `reduceAnimations` preference
- Material 3 theming with custom colors
- Comprehensive page template system

❌ **Gaps:**
- No unified dialog/popup framework
- Limited animation system (only nav bar bounces)
- No bottom sheet system
- No reusable transition animations
- Missing Material 3 container transitions
- Basic dialog usage with standard `showDialog`

### Budget Project (Reference)
✅ **Advanced Features to Adopt:**
- **PopupFramework**: Reusable template for dialogs/bottom sheets
- **Rich Animation Library**: 10+ animation widgets (AnimatedExpanded, FadeIn, ScaleIn, etc.)
- **Bottom Sheet System**: Smart snapping and responsive sheets
- **Page Transitions**: Custom slide transitions with Material 3 curves
- **Material 3 Container**: OpenContainer hero-like transitions
- **Performance Settings**: Battery saver and animation level controls
- **Platform-Aware Design**: iOS vs Android specific behaviors

---

## 🚀 Implementation Phases

### **Phase 1: Foundation & Core Framework** (Week 1-2)

#### 1.1 Animation Settings Enhancement
```dart
// lib/core/settings/app_settings.dart - Extend existing system
static Map<String, dynamic> _getDefaultSettings() {
  return {
    // Existing settings...
    
    // Enhanced animation settings
    'reduceAnimations': false,
    'animationLevel': 'normal', // 'none', 'reduced', 'normal', 'enhanced'
    'batterySaver': false,
    'outlinedIcons': false,
    'appAnimations': true,
  };
}
```

#### 1.2 Platform Detection Service
```dart
// lib/core/services/platform_service.dart
enum PlatformOS { isIOS, isAndroid, isWeb, isDesktop }

class PlatformService {
  static PlatformOS getPlatform() { /* Implementation */ }
  static bool getIsFullScreen(BuildContext context) { /* Implementation */ }
}
```

#### 1.3 Animation Utilities Base
```dart
// lib/shared/widgets/animations/animation_utils.dart
class AnimationUtils {
  static bool shouldAnimate() {
    return !AppSettings.getWithDefault<bool>('reduceAnimations', false) &&
           !AppSettings.getWithDefault<bool>('batterySaver', false);
  }
  
  static Duration getDuration([Duration? fallback]) {
    if (!shouldAnimate()) return Duration.zero;
    return fallback ?? const Duration(milliseconds: 300);
  }
}
```

### **Phase 2: Animation Widget Library** (Week 2-3)

#### 2.1 Core Animation Widgets
Create a comprehensive animation library in `lib/shared/widgets/animations/`:

**Entry Animations:**
- `FadeIn` - Fade with customizable delay and curves
- `ScaleIn` - Scale entrance with elastic curves
- `SlideIn` - Directional slide animations
- `BouncingWidget` - Elastic bouncing effects
- `BreathingWidget` - Pulsing scale animations

**Transition Animations:**
- `AnimatedExpanded` - Smooth expand/collapse with fade
- `AnimatedSizeSwitcher` - Content switching with size transitions
- `ScaledAnimatedSwitcher` - Scale + fade content switching
- `SlideFadeTransition` - Combined slide and fade effects

**Interactive Animations:**
- `TappableWidget` - Tap response with customizable feedback
- `ShakeAnimation` - Horizontal shake effects for errors
- `AnimatedScaleOpacity` - Combined scale and opacity changes

```dart
// Example: lib/shared/widgets/animations/fade_in.dart
class FadeIn extends StatefulWidget {
  const FadeIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  @override
  State<FadeIn> createState() => _FadeInState();
}
```

#### 2.2 Animation Performance Integration
```dart
// Integration with existing settings
Widget build(BuildContext context) {
  if (!AnimationUtils.shouldAnimate()) {
    return child; // Skip animation
  }
  
  return AnimatedBuilder(/* animation implementation */);
}
```

### **Phase 3: Dialog & Popup Framework** (Week 3-4)

#### 3.1 PopupFramework Widget
```dart
// lib/shared/widgets/dialogs/popup_framework.dart
class PopupFramework extends StatelessWidget {
  const PopupFramework({
    required this.child,
    this.title,
    this.subtitle,
    this.customSubtitleWidget,
    this.hasPadding = true,
    this.underTitleSpace = true,
    this.showCloseButton = false,
    this.icon,
    this.outsideExtraWidget,
    super.key,
  });

  // Implementation with Material 3 design
  // Platform-aware layouts (iOS centered vs Android left-aligned)
  // Consistent spacing and typography
}
```

#### 3.2 Dialog Services
```dart
// lib/core/services/dialog_service.dart
class DialogService {
  static Future<T?> showPopup<T>(
    BuildContext context,
    Widget child, {
    String? title,
    String? subtitle,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => PopupFramework(
        title: title,
        subtitle: subtitle,
        child: child,
      ),
    );
  }
}
```

#### 3.3 Bottom Sheet System
```dart
// lib/shared/widgets/dialogs/bottom_sheet_service.dart
class BottomSheetService {
  static Future<T?> showCustomBottomSheet<T>(
    BuildContext context,
    Widget child, {
    List<double>? snapSizes,
    bool isDismissible = true,
    String? title,
  }) {
    // Implementation with smart snapping
    // Responsive to content size
    // Keyboard handling
  }
}
```

### **Phase 4: Page Transitions & Navigation** (Week 4-5)

#### 4.1 Enhanced Page Transitions
```dart
// lib/app/router/page_transitions.dart
class AppPageTransitions {
  static Page<T> slideTransitionPage<T extends Object?>(
    Widget child, {
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubicEmphasized,
          )),
          child: child,
        );
      },
      transitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 300),
      ),
      reverseTransitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 200),
      ),
    );
  }
}
```

#### 4.2 Material 3 Container Transitions
Add `animations` package dependency for OpenContainer:
```yaml
dependencies:
  animations: ^2.0.7
```

```dart
// lib/shared/widgets/transitions/open_container_navigation.dart
class OpenContainerNavigation extends StatelessWidget {
  const OpenContainerNavigation({
    required this.openPage,
    required this.closedBuilder,
    this.onOpen,
    super.key,
  });

  final Widget openPage;
  final Widget Function(VoidCallback openContainer) closedBuilder;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      transitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 400),
      ),
      openBuilder: (context, _) => openPage,
      closedBuilder: (context, openContainer) {
        return closedBuilder(() {
          onOpen?.call();
          openContainer();
        });
      },
    );
  }
}
```

### **Phase 5: Enhanced Navigation Features** (Week 5-6)

#### 5.1 Long Press Navigation Dialogs
Enhance existing `main_shell.dart`:
```dart
// Enhanced customization dialog with PopupFramework
void _showCustomizationDialog(
  BuildContext context,
  int index,
  NavigationState state,
) {
  DialogService.showPopup(
    context,
    NavigationCustomizationContent(
      currentIndex: index,
      availableItems: NavigationItem.allItems
          .where((item) => !state.navigationItems.contains(item))
          .toList(),
    ),
    title: 'navigation.customize_title'.tr(),
    subtitle: 'navigation.customize_message'.tr(),
  );
}
```

#### 5.2 Page Template Enhancements
```dart
// lib/shared/widgets/page_template.dart - Enhanced version
class PageTemplate extends StatelessWidget {
  const PageTemplate({
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
    this.showBackButton = true,
    this.onBackPressed,
    this.customAppBar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Scaffold(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
        appBar: customAppBar ?? (title != null ? AppBar(
          title: AnimatedSwitcher(
            duration: AnimationUtils.getDuration(
              const Duration(milliseconds: 200),
            ),
            child: Text(
              title!,
              key: ValueKey(title),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          actions: actions,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              : null,
        ) : null),
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
```

### **Phase 6: Integration & Polish** (Week 6-7)

#### 6.1 Existing Component Enhancement
Update existing components to use the new framework:

**Settings Page:**
```dart
// Replace standard showDialog with PopupFramework
void _showThemeDialog() {
  DialogService.showPopup(
    context,
    ThemeSelectionContent(),
    title: 'Choose Theme',
  );
}
```

**Navigation Items:**
```dart
// Add smooth transitions to navigation items
class _AnimatedNavigationItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TappableWidget(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: AnimationUtils.getDuration(
          const Duration(milliseconds: 200),
        ),
        // ... existing implementation
      ),
    );
  }
}
```

#### 6.2 Performance Optimization
```dart
// lib/core/services/animation_performance_service.dart
class AnimationPerformanceService {
  static bool get shouldUseComplexAnimations {
    return !AppSettings.getWithDefault<bool>('batterySaver', false) &&
           AppSettings.getWithDefault<String>('animationLevel', 'normal') != 'none';
  }
  
  static Duration getOptimizedDuration(Duration standard) {
    final level = AppSettings.getWithDefault<String>('animationLevel', 'normal');
    
    switch (level) {
      case 'none':
        return Duration.zero;
      case 'reduced':
        return Duration(milliseconds: (standard.inMilliseconds * 0.5).round());
      case 'enhanced':
        return Duration(milliseconds: (standard.inMilliseconds * 1.2).round());
      default:
        return standard;
    }
  }
}
```

### **Phase 7: Testing & Documentation** (Week 7-8)

#### 7.1 Comprehensive Testing
```dart
// test/widgets/animations/animation_test.dart
void main() {
  group('Animation Framework', () {
    testWidgets('FadeIn respects animation settings', (tester) async {
      // Test animation behavior with different settings
    });
    
    testWidgets('PopupFramework displays correctly', (tester) async {
      // Test popup framework functionality
    });
  });
}
```

#### 7.2 Documentation Updates
- Update `FRAMEWORK_DESCRIPTION.md` with animation patterns, so Frontend Dev know how to make use of the templates, and features implemented
- Create animation component documentation
- Add usage examples for dialog framework

---

## 📁 File Structure

```
lib/
├── shared/
│   └── widgets/
│       ├── animations/
│       │   ├── animation_utils.dart
│       │   ├── fade_in.dart
│       │   ├── scale_in.dart
│       │   ├── slide_in.dart
│       │   ├── bouncing_widget.dart
│       │   ├── breathing_widget.dart
│       │   ├── animated_expanded.dart
│       │   ├── animated_size_switcher.dart
│       │   ├── tappable_widget.dart
│       │   └── shake_animation.dart
│       ├── dialogs/
│       │   ├── popup_framework.dart
│       │   ├── bottom_sheet_service.dart
│       │   └── dialog_service.dart
│       └── transitions/
│           ├── open_container_navigation.dart
│           └── page_transitions.dart
├── core/
│   └── services/
│       ├── platform_service.dart
│       ├── animation_performance_service.dart
│       └── dialog_service.dart
└── app/
    └── router/
        └── page_transitions.dart
```

---

## 🎯 Success Criteria

### **Phase 1-2 (Foundation)**
- [ ] Enhanced animation settings system
- [ ] Platform detection service
- [ ] Core animation widgets library
- [ ] Performance-aware animation system

### **Phase 3-4 (Dialogs & Transitions)**
- [ ] PopupFramework template working
- [ ] Bottom sheet system implemented
- [ ] Page transitions enhanced
- [ ] Material 3 container transitions

### **Phase 5-6 (Integration)**
- [ ] Navigation long-press dialogs
- [ ] Settings dialogs using new framework
- [ ] All existing components enhanced
- [ ] Performance optimization complete

### **Phase 7-8 (Polish)**
- [ ] Comprehensive test coverage
- [ ] Documentation updated
- [ ] Performance benchmarks established
- [ ] Accessibility compliance verified

---

## 🚀 Quick Start (Minimum Viable Animation)

For immediate impact, implement these in Phase 1:

1. **FadeIn widget** for page entrances
2. **TappableWidget** for button feedback
3. **PopupFramework** for dialogs
4. **Enhanced navigation bounce** animations

This provides 80% of the visual impact with 20% of the effort.

---

## 🔗 Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  animations: ^2.0.7  # Material 3 container transitions
  
dev_dependencies:
  flutter_test:
    sdk: flutter
```

---

## 📱 Platform Considerations

- **iOS**: Centered layouts, different padding, spring animations
- **Android**: Left-aligned layouts, Material Design 3 curves
- **Web**: Reduced animations by default, mouse hover states
- **Desktop**: Keyboard navigation, window resize handling

---

This implementation plan provides a comprehensive roadmap to transform the Finance app with the smooth, delightful animations and dialog system from the budget project while maintaining the existing clean architecture and performance considerations. 