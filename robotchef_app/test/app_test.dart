import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screen/home_screen.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('app should work', (tester) async {
    await tester.pumpWidget(new MyApp());
    expect(find.text('RobotChef'), findsOneWidget);
    expect(find.text('이미지 선택'), findsOneWidget);
    expect(find.text('즐겨찾기'), findsOneWidget);
    
    /// skipOffstage: false로 설정하지 않으면 테스트가 되지 않는 문제가 있는데
    /// 원인을 알기 힘들다 아는 사람 있으면 제보바람
    expect(find.text('검색', skipOffstage: false), findsOneWidget);
    expect(find.text('더 보기', skipOffstage: false), findsOneWidget);
  });
}