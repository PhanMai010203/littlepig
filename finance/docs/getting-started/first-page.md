# 🚀 Creating Your First Page

Learn how to create a new page in the Flutter boilerplate by building a practical example: a Goal Tracking page.

## 🎯 What We'll Build

By the end of this tutorial, you'll have created:
- ✅ A fully functional Goal Tracking page
- ✅ Navigation integration
- ✅ Theme-aware UI components
- ✅ Custom widgets using the boilerplate system

## 📝 Prerequisites

Before starting, make sure you've completed:
- [Installation & Setup](installation.md)
- [Project Structure](project-structure.md) understanding

## 🏗️ Step-by-Step Guide

### Step 1: Create the Feature Structure

First, let's create the folder structure for our new feature:

```bash
# Navigate to your project root
cd lib/features

# Create the goal tracking feature structure
mkdir -p goal_tracking/presentation/{pages,widgets}
mkdir -p goal_tracking/domain/entities
```

Your structure should now look like:
```
features/goal_tracking/
├── domain/
│   └── entities/
└── presentation/
    ├── pages/
    └── widgets/
```

### Step 2: Create the Goal Entity

Let's start with the business logic by creating a Goal entity:

```dart
// lib/features/goal_tracking/domain/entities/goal.dart
class Goal {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final GoalCategory category;

  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.category,
  });

  double get progress => currentAmount / targetAmount;
  
  bool get isCompleted => currentAmount >= targetAmount;
  
  Duration get timeRemaining => deadline.difference(DateTime.now());
}

enum GoalCategory {
  emergency,
  vacation,
  purchase,
  education,
  other,
}

extension GoalCategoryExtension on GoalCategory {
  String get displayName {
    switch (this) {
      case GoalCategory.emergency:
        return 'Emergency Fund';
      case GoalCategory.vacation:
        return 'Vacation';
      case GoalCategory.purchase:
        return 'Major Purchase';
      case GoalCategory.education:
        return 'Education';
      case GoalCategory.other:
        return 'Other';
    }
  }
  
  String get iconPath {
    switch (this) {
      case GoalCategory.emergency:
        return 'assets/icons/icon_emergency.svg';
      case GoalCategory.vacation:
        return 'assets/icons/icon_vacation.svg';
      case GoalCategory.purchase:
        return 'assets/icons/icon_purchase.svg';
      case GoalCategory.education:
        return 'assets/icons/icon_education.svg';
      case GoalCategory.other:
        return 'assets/icons/icon_other.svg';
    }
  }
}
```

### Step 3: Create the Goal Card Widget

Now let's create a reusable widget for displaying goals:

```dart
// lib/features/goal_tracking/presentation/widgets/goal_card.dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: getColor(context, 'surface'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: getColor(context, 'border'),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildProgress(context),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getColor(context, 'primaryLight').withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(),
            color: getColor(context, 'primary'),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                goal.title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                colorName: 'text',
              ),
              const SizedBox(height: 2),
              AppText(
                goal.category.displayName,
                fontSize: 12,
                colorName: 'textLight',
              ),
            ],
          ),
        ),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit,
              color: getColor(context, 'textLight'),
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget _buildProgress(BuildContext context) {
    final progressPercent = (goal.progress * 100).clamp(0, 100).toInt();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              '\$${goal.currentAmount.toStringAsFixed(0)}',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              colorName: 'text',
            ),
            AppText(
              '$progressPercent%',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              colorName: goal.isCompleted ? 'success' : 'primary',
            ),
          ],
        ),
        const SizedBox(height: 4),
        AppText(
          'of \$${goal.targetAmount.toStringAsFixed(0)} goal',
          fontSize: 12,
          colorName: 'textLight',
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: goal.progress.clamp(0.0, 1.0),
          backgroundColor: getColor(context, 'border'),
          valueColor: AlwaysStoppedAnimation<Color>(
            goal.isCompleted 
                ? getColor(context, 'success')
                : getColor(context, 'primary'),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final daysRemaining = goal.timeRemaining.inDays;
    
    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 14,
          color: getColor(context, 'textLight'),
        ),
        const SizedBox(width: 4),
        AppText(
          daysRemaining > 0 
              ? '$daysRemaining days left'
              : goal.isCompleted
                  ? 'Goal completed!'
                  : 'Overdue',
          fontSize: 12,
          colorName: daysRemaining > 0 
              ? 'textLight' 
              : goal.isCompleted
                  ? 'success'
                  : 'warning',
        ),
        const Spacer(),
        if (!goal.isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getColor(context, 'primary').withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppText(
              'Add Funds',
              fontSize: 10,
              colorName: 'primary',
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  IconData _getCategoryIcon() {
    switch (goal.category) {
      case GoalCategory.emergency:
        return Icons.security;
      case GoalCategory.vacation:
        return Icons.flight;
      case GoalCategory.purchase:
        return Icons.shopping_cart;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.other:
        return Icons.star;
    }
  }
}
```

### Step 4: Create the Main Goal Tracking Page

Now let's create the main page:

```dart
// lib/features/goal_tracking/presentation/pages/goal_tracking_page.dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/page_template.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/goal.dart';
import '../widgets/goal_card.dart';

class GoalTrackingPage extends StatefulWidget {
  const GoalTrackingPage({super.key});

  @override
  State<GoalTrackingPage> createState() => _GoalTrackingPageState();
}

class _GoalTrackingPageState extends State<GoalTrackingPage> {
  // Sample data - in a real app, this would come from a repository/BLoC
  final List<Goal> _goals = [
    Goal(
      id: '1',
      title: 'Emergency Fund',
      description: 'Save for unexpected expenses',
      targetAmount: 10000,
      currentAmount: 3500,
      deadline: DateTime.now().add(const Duration(days: 180)),
      category: GoalCategory.emergency,
    ),
    Goal(
      id: '2',
      title: 'Summer Vacation',
      description: 'Trip to Europe',
      targetAmount: 5000,
      currentAmount: 1200,
      deadline: DateTime.now().add(const Duration(days: 120)),
      category: GoalCategory.vacation,
    ),
    Goal(
      id: '3',
      title: 'New Laptop',
      description: 'MacBook Pro for work',
      targetAmount: 2500,
      currentAmount: 2500,
      deadline: DateTime.now().subtract(const Duration(days: 30)),
      category: GoalCategory.purchase,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Goal Tracking',
      actions: [
        IconButton(
          onPressed: _showFilterOptions,
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter Goals',
        ),
        IconButton(
          onPressed: _showSortOptions,
          icon: const Icon(Icons.sort),
          tooltip: 'Sort Goals',
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewGoal,
        icon: const Icon(Icons.add),
        label: const AppText('New Goal'),
        backgroundColor: getColor(context, 'primary'),
        foregroundColor: getColor(context, 'white'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildGoalsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final totalGoals = _goals.length;
    final completedGoals = _goals.where((goal) => goal.isCompleted).length;
    final totalSaved = _goals.fold<double>(
      0, 
      (sum, goal) => sum + goal.currentAmount,
    );
    final totalTarget = _goals.fold<double>(
      0, 
      (sum, goal) => sum + goal.targetAmount,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            getColor(context, 'primary'),
            getColor(context, 'primaryLight'),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Your Progress',
                      fontSize: 16,
                      colorName: 'white',
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      '\$${totalSaved.toStringAsFixed(0)}',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      colorName: 'white',
                    ),
                    AppText(
                      'of \$${totalTarget.toStringAsFixed(0)} total',
                      fontSize: 14,
                      colorName: 'white',
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    '$completedGoals/$totalGoals',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    colorName: 'white',
                  ),
                  AppText(
                    'Goals Complete',
                    fontSize: 12,
                    colorName: 'white',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: totalTarget > 0 ? totalSaved / totalTarget : 0,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    if (_goals.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _goals.length,
      itemBuilder: (context, index) {
        final goal = _goals[index];
        return GoalCard(
          goal: goal,
          onTap: () => _viewGoalDetails(goal),
          onEdit: () => _editGoal(goal),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: getColor(context, 'textLight'),
          ),
          const SizedBox(height: 16),
          AppText(
            'No Goals Yet',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            colorName: 'text',
          ),
          const SizedBox(height: 8),
          AppText(
            'Create your first financial goal\nto start tracking your progress',
            fontSize: 14,
            colorName: 'textLight',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewGoal,
            icon: const Icon(Icons.add),
            label: const AppText('Create Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: getColor(context, 'primary'),
              foregroundColor: getColor(context, 'white'),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewGoal() {
    // TODO: Navigate to add goal page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add new goal functionality coming soon!')),
    );
  }

  void _viewGoalDetails(Goal goal) {
    // TODO: Navigate to goal details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${goal.title}')),
    );
  }

  void _editGoal(Goal goal) {
    // TODO: Navigate to edit goal page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${goal.title}')),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'Filter Goals',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            // TODO: Add filter options
            const SizedBox(height: 16),
            const AppText('Filter options coming soon!'),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'Sort Goals',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            // TODO: Add sort options
            const SizedBox(height: 16),
            const AppText('Sort options coming soon!'),
          ],
        ),
      ),
    );
  }
}
```

### Step 5: Add Navigation Route

Now let's add the route for our new page:

#### Add Route Constant
```dart
// lib/app/router/app_routes.dart
class AppRoutes {
  static const String home = '/';
  static const String transactions = '/transactions';
  static const String budgets = '/budgets';
  static const String goalTracking = '/goal-tracking';  // Add this line
  static const String more = '/more';
  static const String settings = '/settings';
}
```

#### Configure Router
```dart
// lib/app/router/app_router.dart
import '../../features/goal_tracking/presentation/pages/goal_tracking_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // ... existing routes
          GoRoute(
            path: AppRoutes.goalTracking,
            name: AppRoutes.goalTracking,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GoalTrackingPage(),
            ),
          ),
          // ... other routes
        ],
      ),
      // ... non-shell routes
    ],
  );
}
```

### Step 6: Add to Navigation (Optional)

If you want to add your page to the bottom navigation:

```dart
// lib/features/navigation/domain/entities/navigation_item.dart
class NavigationItem {
  // ... existing items
  
  static const goalTracking = NavigationItem(
    label: 'Goals',
    iconPath: 'assets/icons/icon_goals.svg',
    routePath: AppRoutes.goalTracking,
  );

  static List<NavigationItem> get allItems => [
    home,
    transactions,
    budgets,
    goalTracking,  // Add this line
    more,
  ];
}
```

### Step 7: Test Your Page

Now you can test your new page:

```bash
# Run the app
flutter run

# Navigate to your page by adding it to navigation or accessing the route directly
```

## 🎯 Testing the Implementation

### Navigate to Your Page

You can access your new page by:

1. **Direct URL** (in debug mode): Add `/goal-tracking` to your app URL
2. **Add to Navigation**: Follow Step 6 to add it to bottom navigation
3. **Navigate Programmatically**: From any widget:
   ```dart
   context.go(AppRoutes.goalTracking);
   ```

### Expected Results

Your page should display:
- ✅ **Header**: Progress summary with gradient background
- ✅ **Goal Cards**: Sample goals with progress indicators
- ✅ **Theme Integration**: Colors adapt to light/dark mode
- ✅ **Navigation**: App bar with filter and sort buttons
- ✅ **FAB**: Floating action button to add new goals

## 🎨 Customization Options

### Styling Your Page

#### Custom Colors
```dart
// Use different colors for different goal categories
Color getCategoryColor(GoalCategory category) {
  switch (category) {
    case GoalCategory.emergency:
      return getColor(context, 'error');
    case GoalCategory.vacation:
      return getColor(context, 'info');
    // ... other categories
  }
}
```

#### Custom Animations
```dart
// Add animations to goal cards
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  // ... container properties
)
```

### Extending Functionality

#### Add Goal Form
Create a form to add new goals with validation:

```dart
// lib/features/goal_tracking/presentation/pages/add_goal_page.dart
class AddGoalPage extends StatefulWidget {
  // Implementation for adding new goals
}
```

#### Goal Details Page
Create a detailed view for individual goals:

```dart
// lib/features/goal_tracking/presentation/pages/goal_details_page.dart
class GoalDetailsPage extends StatefulWidget {
  // Implementation for goal details and editing
}
```

## 🎯 What You've Learned

By completing this tutorial, you've learned:

- ✅ **Feature Structure**: How to organize code using clean architecture
- ✅ **Custom Widgets**: Creating reusable UI components
- ✅ **Theme Integration**: Using the boilerplate's theming system
- ✅ **Navigation**: Adding routes and integrating with Go Router
- ✅ **State Management**: Basic state handling (ready for BLoC integration)
- ✅ **Best Practices**: Following Flutter and project conventions

## 🚀 Next Steps

### Immediate Enhancements
1. **Add State Management**: Implement BLoC for goal management
2. **Data Persistence**: Save goals locally using shared preferences
3. **Form Validation**: Create add/edit goal forms
4. **Animations**: Add smooth transitions and micro-interactions

### Advanced Features
1. **Goal Categories**: Implement filtering and sorting
2. **Goal Notifications**: Remind users about deadlines
3. **Progress Charts**: Visual progress tracking
4. **Goal Sharing**: Share achievements with others

### Integration Points
- **[App Text Widget](../components/app-text.md)** - Learn more about text customization
- **[Color System](../theming/colors.md)** - Deep dive into theming
- **[Custom Widgets](../components/custom-widgets.md)** - Explore other available widgets
- **[Navigation System](../navigation/setup.md)** - Advanced navigation patterns

## 🎉 Congratulations!

You've successfully created your first page using the Flutter boilerplate! You now have a solid foundation for building more complex features and understanding the project structure.

---

**Next Steps:**
- [Explore AppText Widget →](../components/app-text.md)
- [Learn about Theming →](../theming/colors.md)
- [Advanced Navigation →](../navigation/custom-navigation.md)
