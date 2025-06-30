# UI Guide: TextInput & Focus Management

This document covers the `TextInput` widget and its advanced focus management system, including automatic focus restoration when the app resumes from background.

---

## 🎯 Overview

The Finance App's `TextInput` widget provides a consistent, platform-adaptive text input experience with intelligent focus management. The key feature is automatic focus restoration when users return to the app from background, ensuring a seamless user experience.

**Widget Location**: `lib/shared/widgets/text_input.dart`

---

## 📋 Key Features

### ✅ Bug Fixes (Latest Version)

**Issue 1: Global Focus State Race Conditions - FIXED**
- **Problem**: Global variables caused race conditions when multiple TextInput widgets existed
- **Solution**: Replaced with instance-based state management - each `ResumeTextFieldFocus` manages its own focus state

**Issue 2: Focus Restoration Logic Flaws - FIXED**
- **Problem**: Contradictory logic prevented focus restoration and triggered unwanted auto-refocus
- **Solution**: Improved logic that only restores focus when the app actually went to background, not on intentional dismissals

### 🚀 Current Features

- **Instance-based focus management**: No race conditions between multiple text inputs
- **Smart focus restoration**: Only restores when appropriate (app background/resume)
- **Platform-adaptive styling**: Bubble, underline, and minimal styles
- **Automatic keyboard dismissal**: Smart handling based on context
- **Theme integration**: Consistent with app colors and Material You theming

---

## 🔧 Basic Usage

### Simple Text Input

```dart
import 'package:finance/shared/widgets/text_input.dart';

TextInput(
  hintText: 'Enter amount',
  keyboardType: TextInputType.number,
  onChanged: (value) => print('Input: $value'),
)
```

### Form with Focus Management

```dart
class TransactionFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResumeTextFieldFocus(  // Wrap the form for focus management
      child: PageTemplate(
        title: 'Add Transaction',
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  TextInput(
                    hintText: 'Transaction title',
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: 16),
                  TextInput(
                    hintText: 'Amount',
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    prefix: '\$',
                  ),
                  SizedBox(height: 16),
                  TextInput(
                    hintText: 'Notes (optional)',
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎨 Styling Options

### Text Input Styles

```dart
// Bubble style (default) - rounded container
TextInput(
  style: TextInputStyle.bubble,
  hintText: 'Bubble style',
)

// Underline style - underlined input
TextInput(
  style: TextInputStyle.underline,
  hintText: 'Underline style',
)

// Minimal style - transparent background
TextInput(
  style: TextInputStyle.minimal,
  hintText: 'Minimal style',
)
```

### Custom Styling

```dart
TextInput(
  backgroundColor: Colors.blue.withOpacity(0.1),
  borderRadius: BorderRadius.circular(20),
  fontSize: 18,
  fontWeight: FontWeight.w500,
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
)
```

---

## 🧠 Focus Management Deep Dive

### How It Works

1. **Wrap with ResumeTextFieldFocus**: Each major UI section gets its own focus management scope
2. **Background Detection**: When app goes to background (`paused`, `inactive`, `hidden` states), the current focus is stored
3. **Smart Restoration**: When app resumes, focus is only restored if:
   - App actually went to background (not just a brief inactive state)
   - A valid focus node was stored
   - The focus node can still be focused
4. **Automatic Cleanup**: Stored focus is cleared when inappropriate

### Instance-Based State Management

```dart
class _ResumeTextFieldFocusState extends State<ResumeTextFieldFocus> {
  // Each instance has its own state - no global variables!
  FocusNode? _storedFocusNode;
  bool _appWentToBackground = false;
  bool _shouldRestoreFocus = false;
  
  // ... rest of implementation
}
```

### Lifecycle States Handled

- **`paused`**: App going to background → store focus
- **`resumed`**: App coming back → restore focus if appropriate
- **`inactive`**: iOS app switcher/Android recent apps → store focus
- **`detached`**: App terminating → clear stored focus
- **`hidden`**: iOS 17+ hidden state → store focus

---

## 🎯 Best Practices

### ✅ DO

**Wrap pages with forms in ResumeTextFieldFocus:**
```dart
class FormPage extends StatelessWidget {
  Widget build(context) => ResumeTextFieldFocus(
    child: YourFormContent(),
  );
}
```

**Use appropriate keyboard dismissal:**
```dart
// Standard dismissal (can restore focus later)
minimizeKeyboard(context);

// Clear focus dismissal (prevent restoration)
minimizeKeyboardAndClearFocus(context);
```

**Provide clear focus nodes for complex forms:**
```dart
class _FormPageState extends State<FormPage> {
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  
  Widget build(context) => ResumeTextFieldFocus(
    child: Column(children: [
      TextInput(focusNode: _nameFocus, textInputAction: TextInputAction.next),
      TextInput(focusNode: _emailFocus, textInputAction: TextInputAction.done),
    ]),
  );
}
```

### ❌ DON'T

**Don't wrap the entire app - wrap individual pages/sections:**
```dart
// ❌ Bad - global scope
MaterialApp(home: ResumeTextFieldFocus(child: AppContent()))

// ✅ Good - page scope
PageTemplate(body: ResumeTextFieldFocus(child: FormContent()))
```

**Don't manually manage global focus state:**
```dart
// ❌ Bad - creates race conditions
FocusNode? globalFocus;
void storeGlobalFocus() => globalFocus = FocusScope.of(context).focusedChild;

// ✅ Good - let ResumeTextFieldFocus handle it
ResumeTextFieldFocus(child: YourWidget())
```

---

## 🔄 Migration Guide

### From Old Global Focus System

**Before (problematic):**
```dart
// Global variables caused race conditions
FocusNode? _currentTextInputFocus;
bool _shouldAutoRefocus = false;

class _MyWidgetState extends State<MyWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.focusManager.addListener(_handleFocusChange);
  }
  
  void _handleFocusChange() {
    _currentTextInputFocus = WidgetsBinding.instance.focusManager.primaryFocus;
    if (_currentTextInputFocus == null) {
      _shouldAutoRefocus = true; // ❌ Flawed logic
    }
  }
}
```

**After (fixed):**
```dart
// Instance-based management, no global state
class MyFormPage extends StatelessWidget {
  Widget build(context) => ResumeTextFieldFocus(  // ✅ Self-contained
    child: Column(children: [
      TextInput(hintText: 'Field 1'),
      TextInput(hintText: 'Field 2'),
    ]),
  );
}
```

---

## 🧪 Testing Focus Management

### Unit Tests

```dart
testWidgets('TextInput restores focus after app resume', (tester) async {
  final focusNode = FocusNode();
  
  await tester.pumpWidget(MaterialApp(
    home: ResumeTextFieldFocus(
      child: TextInput(focusNode: focusNode),
    ),
  ));
  
  // Focus the input
  focusNode.requestFocus();
  await tester.pump();
  expect(focusNode.hasFocus, isTrue);
  
  // Simulate app going to background
  tester.binding.defaultBinaryMessenger.send(
    'flutter/lifecycle',
    const StringCodec().encodeMessage('AppLifecycleState.paused'),
  );
  
  // Simulate app resuming
  tester.binding.defaultBinaryMessenger.send(
    'flutter/lifecycle', 
    const StringCodec().encodeMessage('AppLifecycleState.resumed'),
  );
  
  await tester.pump();
  expect(focusNode.hasFocus, isTrue); // Focus should be restored
});
```

### Integration Tests

Test with multiple text inputs to ensure no race conditions occur between different `ResumeTextFieldFocus` instances.

---

## 📋 API Reference

### TextInput Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `style` | `TextInputStyle` | `bubble` | Visual style (bubble, underline, minimal) |
| `hintText` | `String?` | `null` | Placeholder text |
| `focusNode` | `FocusNode?` | `null` | Custom focus node |
| `handleOnTapOutside` | `bool` | `true` | Auto-dismiss keyboard on outside tap |
| `textInputAction` | `TextInputAction?` | `null` | Keyboard action button |
| `keyboardType` | `TextInputType?` | `null` | Keyboard type |
| `textCapitalization` | `TextCapitalization` | `sentences` | Auto-capitalization |

### Helper Functions

```dart
// Standard keyboard dismissal
void minimizeKeyboard(BuildContext context)

// Keyboard dismissal with focus clearing
void minimizeKeyboardAndClearFocus(BuildContext context)

// Handle taps outside text inputs
void handleOnTapOutsideTextInput(BuildContext context)
```

---

## 🔍 Troubleshooting

### Common Issues

**Issue**: Focus not restoring after app resume
- **Solution**: Ensure the TextInput is wrapped in `ResumeTextFieldFocus`
- **Check**: Verify the focus node is still valid and can request focus

**Issue**: Unwanted focus restoration after keyboard dismissal
- **Solution**: Use `minimizeKeyboardAndClearFocus(context)` for final form submissions

**Issue**: Multiple text inputs interfering with each other
- **Solution**: Each `ResumeTextFieldFocus` manages its own state - no interference should occur

### Debug Information

Enable debug prints to track focus management:

```dart
// In ResumeTextFieldFocus implementation
void _handleAppGoingToBackground() {
  final currentFocus = WidgetsBinding.instance.focusManager.primaryFocus;
  print('📱 App going to background, storing focus: ${currentFocus?.debugLabel}');
  // ... rest of implementation
}
``` 