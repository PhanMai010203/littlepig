# UI Guide: Dialogs & Popups

This guide details the framework for showing dialogs, popups, and bottom sheets consistently across the Finance App.

---

## 💬 Dialogs & Popups

The project includes a powerful framework for creating dialogs and popups consistently.

-   **Framework Location**: `lib/shared/widgets/dialogs/popup_framework.dart`
-   **Bottom Sheet Service**: `lib/shared/widgets/dialogs/bottom_sheet_service.dart`
-   **Dialog Service**: `lib/core/services/dialog_service.dart`

### Showing a Dialog

**Method 1: Using DialogService (Recommended)**

```dart
import 'package:finance/core/services/dialog_service.dart';

void _showInfoDialog(BuildContext context) {
  DialogService.showPopup(
    context,
    AppText("This is an important message."),
    title: "Information",
    subtitle: "Please read carefully",
    icon: Icons.info,
    showCloseButton: true,
  );
}
```

**Method 2: Using `.asPopup()` Extension**

```dart
import 'package:finance/shared/widgets/dialogs/popup_framework.dart';

void _showCustomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return MyCustomWidget().asPopup(
        title: "Information",
        subtitle: "This is an important message.",
        icon: Icons.info,
      );
    },
  );
}
```

### Confirmation Dialogs

```dart
// Simple confirmation
final confirmed = await DialogService.showConfirmationDialog(
  context,
  title: "Delete Item",
  message: "Are you sure you want to delete this item?",
  isDangerous: true,
);

if (confirmed == true) {
  // Proceed with deletion
}
```

### Bottom Sheets

```dart
import 'package:finance/shared/widgets/dialogs/bottom_sheet_service.dart';

// Simple bottom sheet
void _showBottomSheet(BuildContext context) {
  BottomSheetService.showSimpleBottomSheet(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText("Bottom Sheet Content"),
        // Your content here
      ],
    ),
    title: "Options",
  );
}

// Options bottom sheet
void _showOptionsSheet(BuildContext context) {
  BottomSheetService.showOptionsBottomSheet<String>(
    context,
    title: "Choose an option",
    options: [
      BottomSheetOption(
        title: "Edit",
        value: "edit",
        icon: Icons.edit,
      ),
      BottomSheetOption(
        title: "Delete",
        value: "delete",
        icon: Icons.delete,
      ),
    ],
  ).then((selectedValue) {
    if (selectedValue != null) {
      // Handle selection
    }
  });
}
``` 