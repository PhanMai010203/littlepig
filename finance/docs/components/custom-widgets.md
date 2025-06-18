# 🧩 Custom Widgets

This section covers additional custom widgets available in the boilerplate beyond AppText and PageTemplate.

## 🎯 Overview

The boilerplate includes several specialized widgets that handle common UI patterns while maintaining theme consistency and performance.

## 🎨 Gradient Containers

### Basic Gradient Container
Create theme-aware gradient backgrounds:

```dart
import '../../../../shared/widgets/gradient_container.dart';

GradientContainer(
  colors: ['primary', 'primaryLight'],
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: AppText(
      'Content with gradient background',
      colorName: 'white',
    ),
  ),
)
```

### Advanced Gradient Options
```dart
GradientContainer(
  colors: ['primary', 'secondary', 'accent'],
  direction: GradientDirection.topToBottom,
  borderRadius: BorderRadius.circular(12),
  child: Container(
    height: 200,
    child: Center(
      child: AppText(
        'Multi-color gradient',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        colorName: 'white',
      ),
    ),
  ),
)
```

### Gradient Directions
```dart
// Horizontal gradient
GradientContainer(
  colors: ['primary', 'primaryDark'],
  direction: GradientDirection.leftToRight,
  child: _content,
)

// Diagonal gradient
GradientContainer(
  colors: ['success', 'successLight'],
  direction: GradientDirection.topLeftToBottomRight,
  child: _content,
)

// Radial gradient
GradientContainer(
  colors: ['warning', 'warningLight'],
  direction: GradientDirection.radial,
  child: _content,
)
```

## 🔘 Theme-Responsive Buttons

### Adaptive Button
Automatically adjusts to theme and context:

```dart
import '../../../../shared/widgets/adaptive_button.dart';

AdaptiveButton(
  text: 'Primary Action',
  onPressed: () => _handlePrimaryAction(),
  style: ButtonStyle.primary,
)

AdaptiveButton(
  text: 'Secondary Action',
  onPressed: () => _handleSecondaryAction(),
  style: ButtonStyle.secondary,
)

AdaptiveButton(
  text: 'Danger Action',
  onPressed: () => _handleDangerAction(),
  style: ButtonStyle.danger,
)
```

### Button with Icons
```dart
AdaptiveButton(
  text: 'Save Changes',
  icon: Icons.save,
  onPressed: () => _saveChanges(),
  style: ButtonStyle.primary,
)

AdaptiveButton(
  text: 'Delete Item',
  icon: Icons.delete_outline,
  onPressed: () => _deleteItem(),
  style: ButtonStyle.danger,
  confirmAction: true, // Shows confirmation dialog
)
```

### Loading Button States
```dart
class LoadingButtonExample extends StatefulWidget {
  @override
  State<LoadingButtonExample> createState() => _LoadingButtonExampleState();
}

class _LoadingButtonExampleState extends State<LoadingButtonExample> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AdaptiveButton(
      text: 'Submit',
      onPressed: _isLoading ? null : _handleSubmit,
      isLoading: _isLoading,
      style: ButtonStyle.primary,
    );
  }

  void _handleSubmit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Handle success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted successfully!')),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

## 📊 Status Cards

### Basic Status Card
Display information with visual status indicators:

```dart
import '../../../../shared/widgets/status_card.dart';

StatusCard(
  title: 'Account Balance',
  value: '\$1,234.56',
  status: CardStatus.positive,
  icon: Icons.account_balance_wallet,
)

StatusCard(
  title: 'Monthly Expenses',
  value: '\$856.23',
  status: CardStatus.negative,
  icon: Icons.trending_down,
)

StatusCard(
  title: 'Savings Goal',
  value: '67%',
  status: CardStatus.warning,
  icon: Icons.savings,
)
```

### Interactive Status Cards
```dart
StatusCard(
  title: 'Investment Portfolio',
  value: '\$5,432.10',
  subtitle: '+2.3% this month',
  status: CardStatus.positive,
  icon: Icons.trending_up,
  onTap: () => Navigator.pushNamed(context, '/investments'),
  showArrow: true,
)
```

### Custom Status Colors
```dart
StatusCard(
  title: 'Custom Status',
  value: 'Active',
  status: CardStatus.custom,
  customColor: getColor(context, 'info'),
  icon: Icons.info_outline,
)
```

## 🔢 Input Widgets

### Themed Text Field
```dart
import '../../../../shared/widgets/themed_text_field.dart';

ThemedTextField(
  label: 'Enter amount',
  hint: '0.00',
  prefixIcon: Icons.attach_money,
  keyboardType: TextInputType.number,
  onChanged: (value) => _handleAmountChange(value),
)

ThemedTextField(
  label: 'Description',
  hint: 'What is this expense for?',
  maxLines: 3,
  onChanged: (value) => _handleDescriptionChange(value),
)
```

### Validation Support
```dart
class ValidatedForm extends StatefulWidget {
  @override
  State<ValidatedForm> createState() => _ValidatedFormState();
}

class _ValidatedFormState extends State<ValidatedForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ThemedTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AdaptiveButton(
            text: 'Submit',
            onPressed: _submitForm,
            style: ButtonStyle.primary,
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
```

## 📱 Loading Indicators

### Themed Loading Spinner
```dart
import '../../../../shared/widgets/themed_loading.dart';

// Basic loading spinner
ThemedLoading()

// Loading with message
ThemedLoading(
  message: 'Loading your data...',
)

// Custom size and color
ThemedLoading(
  size: LoadingSize.large,
  colorName: 'primary',
)
```

### Full-Screen Loading Overlay
```dart
class LoadingOverlayExample extends StatefulWidget {
  @override
  State<LoadingOverlayExample> createState() => _LoadingOverlayExampleState();
}

class _LoadingOverlayExampleState extends State<LoadingOverlayExample> {
  bool _showLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        _buildMainContent(),
        
        // Loading overlay
        if (_showLoading)
          ThemedLoadingOverlay(
            message: 'Processing your request...',
            onCancel: () {
              setState(() {
                _showLoading = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        AppText('Main content goes here'),
        AdaptiveButton(
          text: 'Start Loading',
          onPressed: _startLoading,
          style: ButtonStyle.primary,
        ),
      ],
    );
  }

  void _startLoading() async {
    setState(() {
      _showLoading = true;
    });

    // Simulate work
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _showLoading = false;
    });
  }
}
```

## 🖼️ Image Widgets

### Themed Avatar
```dart
import '../../../../shared/widgets/themed_avatar.dart';

// User avatar with fallback
ThemedAvatar(
  imageUrl: user.profileImageUrl,
  fallbackText: user.initials,
  size: AvatarSize.medium,
)

// Icon avatar
ThemedAvatar(
  icon: Icons.person,
  backgroundColor: 'primary',
  size: AvatarSize.large,
)
```

### Cached Network Image
```dart
import '../../../../shared/widgets/cached_image.dart';

CachedImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 150,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(8),
  placeholder: ThemedLoading(),
  errorWidget: Icon(Icons.error_outline),
)
```

## 📋 List Widgets

### Themed List Tile
```dart
import '../../../../shared/widgets/themed_list_tile.dart';

ThemedListTile(
  title: 'Settings',
  subtitle: 'Configure your preferences',
  leadingIcon: Icons.settings,
  trailingIcon: Icons.arrow_forward_ios,
  onTap: () => Navigator.pushNamed(context, '/settings'),
)

ThemedListTile(
  title: 'Notifications',
  subtitle: 'Manage your notifications',
  leadingIcon: Icons.notifications,
  trailing: Switch(
    value: _notificationsEnabled,
    onChanged: (value) {
      setState(() {
        _notificationsEnabled = value;
      });
    },
  ),
)
```

### Expandable List Tile
```dart
ThemedExpandableListTile(
  title: 'Account Information',
  leadingIcon: Icons.account_circle,
  children: [
    ThemedListTile(
      title: 'Profile',
      onTap: () => _openProfile(),
    ),
    ThemedListTile(
      title: 'Security',
      onTap: () => _openSecurity(),
    ),
    ThemedListTile(
      title: 'Privacy',
      onTap: () => _openPrivacy(),
    ),
  ],
)
```

## 🏷️ Badge Widgets

### Status Badges
```dart
import '../../../../shared/widgets/status_badge.dart';

StatusBadge(
  text: 'Active',
  status: BadgeStatus.success,
)

StatusBadge(
  text: 'Pending',
  status: BadgeStatus.warning,
)

StatusBadge(
  text: 'Failed',
  status: BadgeStatus.error,
)

// Custom badge
StatusBadge(
  text: 'Premium',
  status: BadgeStatus.custom,
  customColor: getColor(context, 'primary'),
)
```

### Count Badges
```dart
CountBadge(
  count: 5,
  child: Icon(Icons.notifications),
)

CountBadge(
  count: 99,
  maxCount: 99,
  child: Icon(Icons.message),
)
```

## 📊 Chart Widgets

### Simple Progress Chart
```dart
import '../../../../shared/widgets/progress_chart.dart';

ProgressChart(
  progress: 0.65, // 65%
  title: 'Savings Goal',
  subtitle: '\$6,500 of \$10,000',
  color: getColor(context, 'success'),
)
```

### Circular Progress
```dart
CircularProgressChart(
  progress: 0.75,
  title: 'Monthly Budget',
  subtitle: '75% used',
  size: 120,
  strokeWidth: 8,
  backgroundColor: getColor(context, 'surfaceVariant'),
  progressColor: getColor(context, 'warning'),
)
```

## 🔗 Related Documentation

- [AppText Widget](app-text.md) - Text component documentation
- [PageTemplate Widget](page-template.md) - Page wrapper documentation
- [Theming System](../theming/colors.md) - Understanding theme integration
- [Navigation System](../navigation/setup.md) - Navigation setup

## 📋 Complete Usage Example

Here's a comprehensive example showing multiple custom widgets together:

```dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/gradient_container.dart';
import '../../../../shared/widgets/status_card.dart';
import '../../../../shared/widgets/adaptive_button.dart';
import '../../../../shared/widgets/themed_text_field.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../core/theme/app_colors.dart';

class CustomWidgetsShowcase extends StatefulWidget {
  const CustomWidgetsShowcase({super.key});

  @override
  State<CustomWidgetsShowcase> createState() => _CustomWidgetsShowcaseState();
}

class _CustomWidgetsShowcaseState extends State<CustomWidgetsShowcase> {
  bool _isLoading = false;
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Custom Widgets',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            GradientContainer(
              colors: ['primary', 'primaryLight'],
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Welcome Back!',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      colorName: 'white',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        AppText(
                          'Premium User',
                          colorName: 'white',
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          text: 'Pro',
                          status: BadgeStatus.custom,
                          customColor: getColor(context, 'warning'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Status cards
            AppText(
              'Account Overview',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: StatusCard(
                    title: 'Balance',
                    value: '\$2,456.78',
                    status: CardStatus.positive,
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatusCard(
                    title: 'Expenses',
                    value: '\$892.34',
                    status: CardStatus.negative,
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form section
            AppText(
              'Quick Transfer',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 16),
            
            ThemedTextField(
              controller: _textController,
              label: 'Amount',
              hint: '0.00',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: AdaptiveButton(
                    text: 'Cancel',
                    onPressed: () => _textController.clear(),
                    style: ButtonStyle.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdaptiveButton(
                    text: 'Transfer',
                    onPressed: _isLoading ? null : _handleTransfer,
                    isLoading: _isLoading,
                    style: ButtonStyle.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Quick actions
            AppText(
              'Quick Actions',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                _buildQuickAction(
                  'Send Money',
                  Icons.send,
                  () => _quickAction('send'),
                ),
                _buildQuickAction(
                  'Request',
                  Icons.request_page,
                  () => _quickAction('request'),
                ),
                _buildQuickAction(
                  'Pay Bills',
                  Icons.receipt_long,
                  () => _quickAction('bills'),
                ),
                _buildQuickAction(
                  'Top Up',
                  Icons.add_circle_outline,
                  () => _quickAction('topup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: getColor(context, 'surface'),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: getColor(context, 'border'),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: getColor(context, 'primary'),
              size: 20,
            ),
            const SizedBox(width: 8),
            AppText(
              title,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTransfer() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer completed successfully!')),
    );

    _textController.clear();
  }

  void _quickAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${action.toUpperCase()} action selected')),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
```

This showcase demonstrates how the custom widgets work together to create a cohesive, theme-aware user interface with minimal code and maximum consistency.
