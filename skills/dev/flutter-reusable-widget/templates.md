# Payload-driven widget templates

## Single-file review / confirmation screen

```dart
import 'package:flutter/material.dart';

/// One row in the review summary.
class ReviewDetailRow {
  const ReviewDetailRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;
}

/// Caller-owned config. Pass translated strings.
class ReviewScreenPayload {
  const ReviewScreenPayload({
    required this.title,
    required this.detailRows,
    required this.primaryCtaLabel,
    this.subtitle,
    this.note,
    this.secondaryCtaLabel,
    this.canSubmit = true,
    this.isSubmitting = false,
    this.semanticsScreenId,
  });

  final String title;
  final String? subtitle;
  final List<ReviewDetailRow> detailRows;
  final String? note;
  final String primaryCtaLabel;
  final String? secondaryCtaLabel;
  final bool canSubmit;
  final bool isSubmitting;
  final String? semanticsScreenId;
}

/// Reusable review UI. Swap flows by swapping [payload] + callbacks.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({
    required this.payload,
    required this.onPrimary,
    this.onSecondary,
    super.key,
  });

  final ReviewScreenPayload payload;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    // Use project base widget / palette / tap wrapper in real apps.
    return Scaffold(
      appBar: AppBar(title: Text(payload.title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (payload.subtitle != null) Text(payload.subtitle!),
          ...payload.detailRows.map(
            (r) => ListTile(
              title: Text(r.label),
              trailing: Text(
                r.value,
                style: r.emphasized
                    ? const TextStyle(fontWeight: FontWeight.w700)
                    : null,
              ),
            ),
          ),
          if (payload.note != null) Text(payload.note!),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: payload.canSubmit && !payload.isSubmitting
                    ? onPrimary
                    : null,
                child: Text(payload.primaryCtaLabel),
              ),
              if (payload.secondaryCtaLabel != null && onSecondary != null)
                TextButton(
                  onPressed: onSecondary,
                  child: Text(payload.secondaryCtaLabel!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Feature mapper (stays in feature, not in common file)

```dart
class ReviewMapper {
  static ReviewScreenPayload fromSend({
    required String title,
    required String amount,
    required String fee,
    required bool canSubmit,
  }) {
    return ReviewScreenPayload(
      title: title,
      detailRows: [
        ReviewDetailRow(label: 'Amount', value: amount, emphasized: true),
        ReviewDetailRow(label: 'Fee', value: fee),
      ],
      primaryCtaLabel: 'Confirm',
      canSubmit: canSubmit,
    );
  }
}
```

## Parent wiring

```dart
// Inside feature view / controller side-effect:
ReviewScreen(
  payload: ReviewMapper.fromSend(...),
  onPrimary: controller.onConfirm,
  onSecondary: controller.onEdit,
);
```
