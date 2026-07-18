import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  final items = [
    DropdownItem(value: '1', label: 'Alpha'),
    DropdownItem(value: '2', label: 'Beta'),
    DropdownItem(value: '3', label: 'Gamma'),
  ];

  /// Pumps a [KaziDropdown] whose selection is held in local state, mirroring
  /// how the real forms drive it (controlled via [onChanged]).
  Future<DropdownItem?> pumpDropdown(
    WidgetTester tester, {
    DropdownItem? initial,
    bool showSearch = false,
    String? Function(DropdownItem?)? validator,
  }) async {
    DropdownItem? selected = initial;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return KaziDropdown(
                label: 'Fruit',
                hint: 'Select a fruit',
                searchLabel: 'Search',
                noResultsLabel: 'No results',
                showSeach: showSearch,
                items: items,
                selectedItem: selected,
                validator: validator,
                onChanged: (item) => setState(() => selected = item),
              );
            },
          ),
        ),
      ),
    );
    return selected;
  }

  testWidgets('shows the hint and opens the picker listing the items', (
    tester,
  ) async {
    await pumpDropdown(tester);

    // The field renders the hint as both label and placeholder text.
    expect(find.text('Select a fruit'), findsWidgets);

    await tester.tap(find.byType(KaziDropdown));
    await tester.pumpAndSettle();

    // Title + all items are visible inside the bottom sheet.
    expect(find.text('Fruit'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Gamma'), findsOneWidget);
  });

  testWidgets('selecting an item reflects it in the field', (tester) async {
    await pumpDropdown(tester);

    await tester.tap(find.byType(KaziDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();

    // Sheet closed and the field now shows the chosen label.
    expect(find.text('Alpha'), findsNothing);
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('search filters the items', (tester) async {
    await pumpDropdown(tester, showSearch: true);

    await tester.tap(find.byType(KaziDropdown));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'gam');
    await tester.pumpAndSettle();

    expect(find.text('Gamma'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
    expect(find.text('Beta'), findsNothing);
  });

  testWidgets('optional dropdown shows a clear button that deselects', (
    tester,
  ) async {
    await pumpDropdown(tester, initial: items.first);

    // With a selection and no validator, the clear affordance is shown.
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Selection cleared: label gone, hint back, no clear button.
    expect(find.text('Alpha'), findsNothing);
    expect(find.text('Select a fruit'), findsWidgets);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets(
    'renders inside a scroll view with a stretched adjacent widget',
    (tester) async {
      // Reproduces the service form layout: a scrolling column where the
      // dropdown sits in an IntrinsicHeight + Row(stretch) next to an attached
      // button, which previously crashed with "forces an infinite height".
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: KaziDropdown(
                            label: 'Fruit',
                            hint: 'Select a fruit',
                            searchLabel: 'Search',
                            noResultsLabel: 'No results',
                            items: items,
                            onChanged: (_) {},
                          ),
                        ),
                        const SizedBox(
                            width: 52,
                            child: ColoredBox(
                              color: Colors.blue,
                              child: Center(child: Icon(Icons.add)),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(KaziDropdown), findsOneWidget);
    },
  );

  testWidgets('required dropdown shows the arrow, not a clear button', (
    tester,
  ) async {
    await pumpDropdown(
      tester,
      initial: items.first,
      validator: (item) => item == null ? 'required' : null,
    );

    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byIcon(Icons.keyboard_arrow_down_outlined), findsOneWidget);
  });
}
