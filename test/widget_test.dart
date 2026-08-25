import 'package:mavishim/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_app_repository.dart';

void main() {
  testWidgets('secret sequence unlocks and app backgrounding locks again', (
    tester,
  ) async {
    final repository = FakeAppRepository();
    await tester.pumpWidget(
      MavishimApp(repository: repository, snapshot: repository.snapshot),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Gizli kilit ekranı'), findsOneWidget);
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    final right = Offset(size.width * 0.75, size.height * 0.4);
    final left = Offset(size.width * 0.25, size.height * 0.4);
    await tester.tapAt(right);
    await tester.tapAt(right);
    await tester.tapAt(left);
    await tester.tapAt(left);
    await tester.tapAt(right);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Gizli kilit ekranı'), findsNothing);
    expect(find.text('Mavishim'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      4,
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.bySemanticsLabel('Gizli kilit ekranı'), findsOneWidget);

    await tester.tapAt(right);
    await tester.tapAt(right);
    await tester.tapAt(left);
    await tester.tapAt(left);
    await tester.tapAt(right);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Gizli kilit ekranı'), findsNothing);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      4,
    );
  });
}
