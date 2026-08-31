import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merchant/features/orders/presentation/widgets/reject_reason_sheet.dart';
import 'package:merchant/features/orders/data/orders_repository.dart';

void main() {
  testWidgets('RejectReasonSheet logic', (WidgetTester tester) async {
    RejectReason? selectedReason;
    String? enteredNote;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RejectReasonSheet(
            onConfirm: (reason, note) async {
              selectedReason = reason;
              enteredNote = note;
            },
          ),
        ),
      ),
    );

    // Initial state: submit button should be disabled (we test this by trying to tap it and expecting nothing to happen, or checking if it is enabled).
    // Let's just select a reason
    await tester.tap(find.text('Out of stock'));
    await tester.pumpAndSettle();
    
    // Tap confirm
    await tester.tap(find.text('Confirm reject'));
    await tester.pumpAndSettle();

    expect(selectedReason, RejectReason.outOfStock);
    expect(enteredNote, isNull);
  });
}
