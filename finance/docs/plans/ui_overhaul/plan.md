# UI Widget Overhaul Plan: Finance ← Budget App Migration

## Overview

This document outlines a comprehensive plan to enhance Finance app's UI widgets by porting proven implementations from the budget app. The focus is on improving reliability, performance, and user experience while maintaining Finance's Clean Architecture and Material 3 design system.

### ⚠️ Prerequisite Reading
Before starting any implementation work **make sure to skim the documents listed under each phase below**. They explain the current architecture, widgets, and services that your changes will interact with.

You can find all docs in `docs/` (use your IDE's jump-to-file). Reading them first will save you debugging time later.

## Current State Analysis

### Finance App Widget Issues
1. **TextInput**: Basic implementation lacking advanced features
2. **TappableTextEntry**: Limited functionality and transitions
3. **Animation Performance**: Could benefit from optimizations
4. **Platform Consistency**: Missing platform-specific behaviors

### Budget App Strengths
1. **Robust TextInput**: Auto-focus restoration, keyboard handling
2. **Smooth Animations**: AnimatedSizeSwitcher, better transitions  
3. **Platform Awareness**: iOS/Android specific behaviors
4. **Advanced Interactions**: Enhanced tappable feedback

## Implementation Plan

### Phase 1: Enhanced Input System

#### 📚 Recommended Reading
* [UI Core Widgets](../../UI_CORE_WIDGETS.md)
* [UI Animation Framework](../../UI_ANIMATION_FRAMEWORK.md)
* [UI Architecture & Theming](../../UI_ARCHITECTURE_AND_THEMING.md)
* [File Structure](../../FILE_STRUCTURE.md)

#### Step 1.1: Create AnimatedSizeSwitcher Widget
**Target File**: `lib/shared/widgets/animations/animated_size_switcher.dart`
**Reference**: `budget/lib/widgets/animatedExpanded.dart` (AnimatedSizeSwitcher class)

**Implementation Details**:
```dart
// New widget to handle smooth size transitions
class AnimatedSizeSwitcher extends StatelessWidget {
  final bool enabled;
  final Widget child;
  final Duration duration;
  final Curve curve;
  // ... implementation
}
```

**Key Features to Port**:
- Size transition animations
- Enable/disable capability
- Curve customization
- Performance optimizations

#### Step 1.2: Enhanced TextInput Widget
**Target File**: `lib/shared/widgets/text_input.dart`
**Reference**: `budget/lib/widgets/textInput.dart`

**Features to Add**:

1. **Auto-Focus Restoration System**:
   ```dart
   // Add global focus management
   FocusNode? _currentTextInputFocus;
   bool shouldAutoRefocus = false;
   
   // New widget wrapper
   class ResumeTextFieldFocus extends StatelessWidget {
     // Handles app lifecycle focus restoration
   }
   ```

2. **Enhanced Styling Options**:
   ```dart
   enum TextInputStyle { 
     bubble,      // Current implementation
     underline,   // New from budget app
     minimal      // Clean variant
   }
   ```

3. **Advanced Configuration**:
   ```dart
   class TextInput extends StatelessWidget {
     // Existing properties...
     final bool autoCorrect;
     final bool enableIMEPersonalizedLearning;
     final bool handleOnTapOutside;
     final TextCapitalization textCapitalization;
     final List<TextInputFormatter>? inputFormatters;
     final ScrollController? scrollController;
     final double? topContentPadding;
     final String? prefix;
     final String? suffix;
     // ...
   }
   ```

4. **Keyboard Management**:
   ```dart
   void minimizeKeyboard(BuildContext context) {
     FocusNode? currentFocus = WidgetsBinding.instance.focusManager.primaryFocus;
     currentFocus?.unfocus();
     Future.delayed(Duration(milliseconds: 10), () {
       shouldAutoRefocus = false;
     });
   }
   
   void handleOnTapOutsideTextInput(BuildContext context) {
     // Smart keyboard dismissal logic
   }
   ```

**Integration Points**:
- Use existing `getColor()` function for theming
- Integrate with `AnimationUtils` for performance
- Maintain Material 3 design compliance

#### Step 1.3: Enhanced TappableTextEntry Widget  
**Target File**: `lib/shared/widgets/tappable_text_entry.dart`
**Reference**: `budget/lib/widgets/tappableTextEntry.dart`

**New Features to Add**:

1. **AnimatedSizeSwitcher Integration**:
   ```dart
   class TappableTextEntry extends StatelessWidget {
     final bool enableAnimatedSwitcher;
     final Function(Widget Function(String? titlePassed) titleBuilder)? customTitleBuilder;
     final String? showPlaceHolderWhenTextEquals;
     final bool disabled;
     final bool autoSizeText;
     // ...
   }
   ```

2. **Advanced Text Handling**:
   ```dart
   Widget titleBuilder(String? titlePassed) {
     return AppText(
       autoSizeText: autoSizeText,
       maxLines: 2,
       minFontSize: 16,
       text: titlePassed == null || 
             titlePassed == "" || 
             titlePassed == showPlaceHolderWhenTextEquals
           ? placeholder 
           : titlePassed,
       textColor: hasValue ? getColor(context, "text") : getColor(context, "textLight"),
     );
   }
   ```

3. **Background Styling Options**:
   ```dart
   if (addTappableBackground)
     PositionedDirectional(
       // Smart background positioning
       child: Container(
         decoration: BoxDecoration(
           borderRadius: BorderRadiusDirectional.circular(5),
           color: getColor(context, "surfaceContainer"),
         ),
       ),
     ),
   ```

### Phase 2: Enhanced Tappable System

#### 📚 Recommended Reading
* [UI Core Widgets](../../UI_CORE_WIDGETS.md)
* [UI Animation Framework](../../UI_ANIMATION_FRAMEWORK.md)
* [UI Patterns & Best Practices](../../UI_PATTERNS_AND_BEST_PRACTICES.md)

#### Step 2.1: Platform-Specific Tappable Behaviors
**Target File**: `lib/shared/widgets/animations/tappable_widget.dart`
**Reference**: `budget/lib/widgets/tappable.dart`

**Enhancements to Add**:

1. **iOS-Specific FadedButton**:
   ```dart
   class FadedButton extends StatefulWidget {
     final double pressedOpacity;
     final Duration kFadeOutDuration;
     final Duration kFadeInDuration;
     // Precise animation timing control
   }
   ```

2. **Platform Detection**:
   ```dart
   @override
   Widget build(BuildContext context) {
     if (PlatformService.getPlatform() == PlatformOS.isIOS) {
       return FadedButton(
         child: child,
         onTap: onTap,
         pressedOpacity: hasOpacity ? 0.5 : 1,
       );
     }
     // Android Material implementation
   }
   ```

3. **Enhanced Mouse/Web Support**:
   ```dart
   Future<void> _onPointerDown(PointerDownEvent event) async {
     if (event.kind == PointerDeviceKind.mouse &&
         event.buttons == kSecondaryMouseButton) {
       if (onLongPress != null) onLongPress!();
     }
   }
   ```

### Phase 3: Advanced Bottom Sheet System

#### 📚 Recommended Reading
* [UI Dialogs & Pop-ups](../../UI_DIALOGS_AND_POPUPS.md)
* [Navigation & Routing](../../NAVIGATION_ROUTING.md)
* [UI Animation Framework](../../UI_ANIMATION_FRAMEWORK.md)

#### Step 3.1: Sliding Sheet Implementation
**Target File**: `lib/shared/widgets/dialogs/bottom_sheet_service.dart`
**Reference**: `budget/lib/widgets/openBottomSheet.dart`

**New Features**:

1. **Smart Snapping Behavior**:
   ```dart
   Future openBottomSheet(
     BuildContext context,
     Widget child, {
     bool snap = true,
     bool fullSnap = false,
     List<double>? snapSizes,
     bool resizeForKeyboard = true,
   }) async {
     // Implement sliding_sheet-like behavior with native widgets
   }
   ```

2. **Enhanced Keyboard Handling**:
   ```dart
   // Adaptive snapping based on keyboard state
   snappings: popupWithKeyboard == false && 
              fullSnap == false && 
              !PlatformService.isFullScreen(context)
            ? [0.6, 1] 
            : [0.95, 1],
   ```

3. **Theme Context Preservation**:
   ```dart
   BuildContext? themeContext = useParentContextForTheme && 
                                isContextValidForTheme(context) 
                              ? context 
                              : null;
   ```

### Phase 4: Supporting Widgets and Utilities

#### 📚 Recommended Reading
* [Platform Service](refer to `core/services/platform_service.dart`)
* [UI Architecture & Theming](../../UI_ARCHITECTURE_AND_THEMING.md)
* [DI Workflow Guide](../../DI_WORKFLOW_GUIDE.md)

#### Step 4.1: Create Missing Animation Widgets
**Target Files**: 
- `lib/shared/widgets/animations/animated_size_switcher.dart`
- `lib/shared/widgets/animations/breathing_widget.dart` (enhance existing)

**Reference**: `budget/lib/widgets/animatedExpanded.dart`

#### Step 4.2: Platform Utilities Enhancement
**Target File**: `lib/core/services/platform_service.dart`

**Add Methods**:
```dart
class PlatformService {
  static bool get isFullScreen => _determineFullScreen();
  static bool get prefersCenteredDialogs => getPlatform() == PlatformOS.isIOS;
  static double getWidthConstraint(BuildContext context) { }
  static bool isContextValidForTheme(BuildContext context) { }
}
```

### Phase 5: Documentation Updates

#### 📚 Recommended Reading
* [README – Developer Hub](../../README.md)
* [Language & Internationalisation](../../LANGUAGE.md)
* [UI Testing & Troubleshooting](../../UI_TESTING_AND_TROUBLESHOOTING.md)
* [Attachments System](../../ATTACHMENTS_SYSTEM.md) (for screenshots/GIFs in docs)

#### Step 5.1: Update Core Widget Documentation
**Target File**: `docs/UI_CORE_WIDGETS.md`

**Sections to Update**:
1. **Enhanced TextInput Usage**:
   ```markdown
   ### Advanced TextInput Features
   
   #### Auto-Focus Restoration
   ```dart
   // Wrap your app with focus management
   ResumeTextFieldFocus(
     child: MaterialApp(...)
   )
   ```
   
   #### Styling Options
   ```dart
   TextInput(
     style: TextInputStyle.underline,
     handleOnTapOutside: true,
     textCapitalization: TextCapitalization.sentences,
   )
   ```
   ```

2. **TappableTextEntry Advanced Usage**:
   ```markdown
   ### Custom Title Builders
   ```dart
   TappableTextEntry(
     customTitleBuilder: (titleBuilder) => CustomWidget(
       child: titleBuilder(title),
     ),
     enableAnimatedSwitcher: true,
   )
   ```
   ```

#### Step 5.2: Update Animation Framework Documentation  
**Target File**: `docs/UI_ANIMATION_FRAMEWORK.md`

**Add Sections**:
```markdown
### AnimatedSizeSwitcher

For smooth size transitions when content changes:

```dart
AnimatedSizeSwitcher(
  enabled: true,
  duration: Duration(milliseconds: 300),
  child: MyWidget(key: ValueKey(contentId)),
)
```

### Platform-Specific Animations

The tappable system now automatically adapts to platform:

```dart
TappableWidget(
  // Automatically uses FadedButton on iOS
  // Uses Material ripple on Android
  child: MyContent(),
)
```
```

#### Step 5.3: Update Dialog Documentation
**Target File**: `docs/UI_DIALOGS_AND_POPUPS.md`

**Add Advanced Bottom Sheet Features**:
```markdown
### Snapping Bottom Sheets

```dart
BottomSheetService.showCustomBottomSheet(
  context,
  myContent,
  snapSizes: [0.3, 0.6, 0.9],
  resizeForKeyboard: true,
  fullSnap: false,
)
```

### Keyboard-Aware Sheets

Bottom sheets now automatically adjust for keyboard:
- Smart snapping when keyboard appears
- Preserved scroll position
- Theme context maintenance
```

#### Step 5.4: Update Best Practices Documentation
**Target File**: `docs/UI_PATTERNS_AND_BEST_PRACTICES.md`

**Add Sections**:
```markdown
### Text Input Best Practices

#### Focus Management
Always wrap your app with focus restoration:

```dart
class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return ResumeTextFieldFocus(
      child: MaterialApp(...)
    );
  }
}
```

#### Platform-Specific Interactions
Let the tappable system handle platform differences:

```dart
// Automatically adapts to iOS/Android
widget.tappable(
  onTap: () => handleTap(),
  // Uses appropriate animation for platform
)
```
```

## Implementation Timeline

### Week 1: Foundation
- [ ] Create AnimatedSizeSwitcher widget
- [ ] Enhance TextInput with auto-focus restoration
- [ ] Add keyboard management utilities

### Week 2: Core Widgets
- [ ] Upgrade TappableTextEntry with new features
- [ ] Implement platform-specific tappable behaviors
- [ ] Add FadedButton for iOS

### Week 3: Advanced Features
- [ ] Enhance BottomSheetService with snapping
- [ ] Add theme context preservation
- [ ] Implement keyboard-aware behaviors

### Week 4: Polish & Documentation
- [ ] Update all documentation files
- [ ] Add comprehensive examples
- [ ] Performance testing and optimization

## Testing Strategy

### Unit Tests
**Files to Test**:
- `test/shared/widgets/animations/animated_size_switcher_test.dart`
- `test/shared/widgets/text_input_test.dart` 
- `test/shared/widgets/tappable_text_entry_test.dart`

### Widget Tests
**Focus Areas**:
- Auto-focus restoration behavior
- Platform-specific animations
- Keyboard handling
- Theme context preservation

### Integration Tests
**Critical Flows**:
- Text input with keyboard interactions
- Bottom sheet with snapping behavior
- Cross-platform tappable feedback

## Success Criteria

### Performance Metrics
- [ ] Text input focus restoration works reliably
- [ ] Animations run at 60fps consistently
- [ ] No memory leaks in animation controllers
- [ ] Reduced jank in bottom sheet interactions

### User Experience
- [ ] Smooth size transitions in TappableTextEntry
- [ ] Platform-appropriate feedback on all tappable elements
- [ ] Keyboard appears/dismisses smoothly
- [ ] Bottom sheets snap to appropriate positions

### Code Quality
- [ ] All widgets follow Finance's architecture patterns
- [ ] Material 3 design compliance maintained
- [ ] Comprehensive test coverage (>90%)
- [ ] Documentation fully updated

## Risk Mitigation

### Potential Issues
1. **Animation Performance**: Monitor frame rates during complex transitions
2. **Platform Compatibility**: Test thoroughly on iOS/Android/Web
3. **Keyboard Behavior**: Edge cases with rapid focus changes
4. **Theme Context**: Ensure proper theme inheritance

### Fallback Plans
1. **Performance Issues**: Disable animations in battery saver mode
2. **Platform Problems**: Graceful degradation to simpler animations
3. **Focus Problems**: Traditional focus management as backup
4. **Theme Issues**: Default to standard Material 3 theming

## Future Enhancements

### Post-Implementation Opportunities
1. **Custom Animation Curves**: User-selectable animation preferences
2. **Accessibility**: Enhanced screen reader support
3. **Haptic Feedback**: More nuanced vibration patterns
4. **Performance Analytics**: Real-time animation performance monitoring

This comprehensive plan ensures a systematic approach to enhancing Finance's UI widgets while maintaining code quality, performance, and user experience standards.