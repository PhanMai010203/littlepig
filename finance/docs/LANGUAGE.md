# 🌐 LANGUAGE.md – Internationalization & Local-Aware Formatting Guide

> **Audience:** Front-end Flutter developers working on the Finance App UI layer.
>
> This document explains _everything_ you need to know about adding, using and maintaining **text**, **dates**, **numbers** and **currency** in a multi-language, locale-aware way.

---

## 1. Quick TL;DR ✅

1. **NEVER** hard-code user-visible strings – _every_ label goes through **Easy Localization**.
2. Use `.tr()` + the `AppText` widget _(or your own Text)_ for translated strings.
3. Use `DateFormat`, **NOT** manual `substring`s, for dates.
4. Use the `CurrencyFormatter` helper for _all_ money values.
5. New languages → add a JSON file under `assets/translations/` **and** register it in `main.dart`.
6. Keep keys **kebab-case** and group by feature (e.g. `budgets-create-title`).

---

## 2. Technology Stack 🧩

| Library | Purpose |
| ------- | ------- |
| [`easy_localization`](https://pub.dev/packages/easy_localization) | Text translations, pluralisation & runtime locale switching. |
| [`intl`](https://pub.dev/packages/intl) | Date/number formatting – used by both `DateFormat` & `NumberFormat`. |
| `CurrencyFormatter` (see `lib/shared/utils/currency_formatter.dart`) | App-specific money formatter that wraps `intl` and applies currency quirks. |

Easy Localization and Intl are initialised _once_ in `main.dart`:
```dart
await EasyLocalization.ensureInitialized();

runApp(
  EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('vi')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    child: MainAppProvider(...),
  ),
);
```

---

## 3. Project Translation Files 📂

```
assets/translations/
  ├── en.json  // English (fallback)
  └── vi.json  // Vietnamese
```

*JSON structure rule of thumb*
```jsonc
{
  "budgets": {
    "title": "Budgets",           // Feature headline
    "empty": "No budgets found",  // Empty-state label
    "settings": {
      "title": "Budget settings"  // Nested paths allowed
    }
  },
  "common": {
    "retry": "Retry",
    "cancel": "Cancel"
  }
}
```

### Naming conventions 🏷️
* **Snake/kebab case:** `transaction-note-empty` or `budgets.empty` are both ok – choose one, keep consistent for that file.
* **Feature prefix:** Keys MUST start with a feature namespace (`budgets`, `transactions`, `settings`, …).
* **Plural suffix:** add `_plural` automatically recognised by Easy Localization.

---

## 4. Using Translations in Widgets 💬

### Basic
```dart
AppText('budgets.title'.tr());
```

### With parameters / placeholders
```dart
// JSON: "greeting": "Hello @name!"
AppText('greeting'.tr(namedArgs: {'name': userName}));
```

### Plurals
```jsonc
"items": {
  "zero": "No items",
  "one": "1 item",
  "other": "@count items"
}
```
```dart
AppText('items'.plural(itemCount));
```

### Context-free helper
When you are outside of a widget tree (e.g. inside a service), use:
```dart
final ctx = navigatorKey.currentContext!;
final result = tr(ctx, 'budgets.title');
```

---

## 5. Date & Time Formatting 🗓️

Always rely on **Intl** to produce locale-correct strings. Do **NOT** compose dates manually.

```dart
String pretty = DateFormat('EEEE, MMMM d', context.locale.toString())
                  .format(someDate);
// e.g. "Monday, June 23"  vs  "Thứ Hai, 23 tháng 6"
```

### Recommended patterns
| Purpose | Pattern | Sample (en) | Sample (vi) |
| ------- | ------- | ----------- | ----------- |
| Long header | `EEEE, MMMM d` | Monday, June 23 | Thứ Hai, 23 tháng 6 |
| Short header | `EEE, MMM d` | Mon, Jun 23 | Th 2, 23 thg 6 |
| Month / Year picker | `MMMM yyyy` | June 2025 | Tháng 6 2025 |

> **Tip:** `context.locale` is automatically updated when the user changes language.

---

## 6. Currency & Number Formatting 💵

Use `CurrencyFormatter.formatAmount()` for **all** monetary values. It:
* Picks the correct thousands / decimal separators per locale.
* Places the symbol _before_ **or** _after_ depending on cultural norms.
* Supports compact style (e.g. `1.2K`).

Examples:
```dart
final text = CurrencyFormatter.formatAmount(
  amount: -1234.56,
  currency: userCurrency,        // From repository
  forceSign: true,               // Show '+' or '-'
);
```

For plain numbers without currency, use `NumberFormat.decimalPattern(context.locale.toString())`.

---

## 7. Adding a New Language 🆕

1. **Create (`code.json`)** under `assets/translations/`.
2. **Copy keys** from `en.json` – values can be English until translated.
3. **Register locale** in `main.dart`:
   ```dart
   supportedLocales: const [
     Locale('en'),
     Locale('vi'),
     Locale('fr'),   // <-- new
   ],
   ```
4. **Add to CI** (if any) – ensure the asset path is packaged.
5. **Test** on device/emulator with Settings → Language.

> **Hint:** Use the [easy_localization_export](https://pub.dev/packages/easy_localization_export) tool to generate a CSV for translators.

---

## 8. Runtime Locale Switching 🔄

In UI code:
```dart
await context.setLocale(const Locale('vi'));
```
The whole widget tree re-builds; `AppLifecycleManager` ensures Material You & high-refresh settings survive the rebuild.

Use `LanguageSelector` widget (see `shared/widgets/language_selector.dart`) for a drop-in picker.

---

## 9. Testing & QA 🧪

* **Widget tests**: wrap with `EasyLocalization` + required providers using `pumpApp()` helper.
* **Golden tests**: capture for **each** supported locale if string length affects layout.
* **Manual QA**: Check right-to-left (RTL) by enabling "Force RTL" in Flutter DevTools.
* **CI**: Lint to catch missing keys – run `dart run easy_localization:generate -O json` to validate.

---

## 10. Common Pitfalls & Best Practices ⚠️

| Pitfall | Fix |
| ------- | ---- |
| Forgetting `.tr()` | `AppText('common.retry')` → `AppText('common.retry'.tr())` |
| String concatenation | Use placeholders instead of `"Hello " + name` |
| Hard-coded currency symbol (`'4'`) | Use `CurrencyFormatter` |
| `DateTime.toString()` in UI | Always `DateFormat` |
| Layout breaks in German (long words) | Use `maxLines`, `overflow` & responsive layout |

---

## 11. Resources & Further Reading 📚

* [README – Getting Started](README.md#🚀-getting-started)
* [Easy Localization docs](https://pub.dev/packages/easy_localization)
* [Intl – DateFormat patterns](https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html)
* [Flutter i18n Cookbook](https://docs.flutter.dev/ui/accessibility-and-localization/)

> _Last updated: <!-- 2025-06-27 -->_ 