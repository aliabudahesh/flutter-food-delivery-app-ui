import 'package:flutter/material.dart';
import 'package:flutter_app/data/sample_data.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/models/business.dart';
import 'package:flutter_app/models/service.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/widgets/PopularFoodsWidget.dart';
import 'package:flutter_app/widgets/TopMenus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget _buildLocalizedApp(Widget child) {
    return MaterialApp(
      locale: const Locale('he'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  group('Booking widgets', () {
    testWidgets('PopularFoodsWidget renders booking services', (WidgetTester tester) async {
      final items = SampleData.getRecommendedItems();
      await tester.pumpWidget(
          _buildLocalizedApp(PopularFoodsWidget(items: items)));
      await tester.pumpAndSettle();

      expect(find.textContaining('תספורת'), findsOneWidget);
    });

    testWidgets('FoodDetailsPage shows slot picker in booking mode', (WidgetTester tester) async {
      final Business business = SampleData.getBusinesses().first;
      final Service service = SampleData.getServices().firstWhere((Service s) => s.businessId == business.id);
      await tester.pumpWidget(_buildLocalizedApp(FoodDetailsPage(business: business, service: service)));
      await tester.pumpAndSettle();

      expect(find.text('זמנים פנויים'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('TopMenus renders booking types', (WidgetTester tester) async {
      await tester.pumpWidget(_buildLocalizedApp(TopMenus(items: SampleData.getTopMenuData())));
      await tester.pumpAndSettle();

      expect(find.textContaining('ספרים'), findsWidgets);
    });
  });
}
