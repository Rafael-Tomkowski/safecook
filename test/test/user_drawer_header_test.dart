// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:safecook/widgets/user_drawer_header.dart';

// void main() {
//   setUp(() async {
//     SharedPreferences.setMockInitialValues({});
//   });

//   testWidgets('UserDrawerHeader renderiza e possui alvo clicável >= 48dp',
//       (tester) async {
//     await tester.pumpWidget(
//       const MaterialApp(
//         home: Scaffold(
//           drawer: Drawer(
//             child: ListView(
//               children: [UserDrawerHeader()],
//             ),
//           ),
//           body: Text('x'),
//         ),
//       ),
//     );

//     // Abre o drawer
//     final scaffoldState = tester.firstState(find.byType(Scaffold)) as ScaffoldState;
//     scaffoldState.openDrawer();
//     await tester.pumpAndSettle();

//     // Deve existir o header
//     expect(find.byType(UserDrawerHeader), findsOneWidget);

//     // Alvo do avatar (SizedBox 72x72)
//     final sizedBoxes = find.byWidgetPredicate((w) =>
//         w is SizedBox && w.width == 72 && w.height == 72);
//     expect(sizedBoxes, findsWidgets);
//   });
// }
