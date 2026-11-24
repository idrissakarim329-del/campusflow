import 'package:campusflow_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sans jeton, l\'application affiche l\'écran de connexion',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CampusFlowApp()));
    await tester.pumpAndSettle();

    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
