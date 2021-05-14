import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('app should work', (tester) async {
    await tester.pumpWidget(new MyApp());
    expect(find.text('RobotChef'), findsOneWidget);
    expect(find.text('이미지 선택'), findsOneWidget);
    expect(find.text('즐겨찾기'), findsOneWidget);
  });
}