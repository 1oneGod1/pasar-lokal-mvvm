import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pasar_lokal_mvvm/main.dart';

void main() {
  testWidgets('shows login screen first', (tester) async {
    await tester.pumpWidget(const PasarLokalApp());
    await tester.pump();

    expect(find.text('Selamat datang kembali!'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('logs in and renders beranda scaffold', (tester) async {
    await tester.pumpWidget(const PasarLokalApp());
    await tester.pump();

    await tester.tap(find.text('Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('LOKASI SAAT INI'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Peta'), findsOneWidget);
    expect(find.text('Pesanan'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);
  });

  testWidgets('seller demo account opens seller dashboard', (tester) async {
    await tester.pumpWidget(const PasarLokalApp());
    await tester.pump();

    final sellerTile = find.text('Putri Siregar • Penjual');
    expect(sellerTile, findsOneWidget);

    final sellerListTile = find.ancestor(
      of: sellerTile,
      matching: find.byType(ListTile),
    );
    final useButton = find.descendant(
      of: sellerListTile,
      matching: find.widgetWithText(TextButton, 'Gunakan'),
    );

    await tester.ensureVisible(useButton);
    await tester.pump();

    await tester.tap(useButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Dashboard Penjual'), findsOneWidget);
    expect(find.text('Produk Anda'), findsOneWidget);
  });
}
