import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_app/config/app_config.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/pages/HomePage.dart';
import 'package:flutter_app/pages/SignInPage.dart';
import 'package:flutter_app/pages/SignUpPage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: AppLocalizations.supportedLocales.first,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (BuildContext context, Widget? child) {
        final AppLocalizations? localizations = AppLocalizations.of(context);
        return Directionality(
          textDirection: localizations?.textDirection ?? TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(fontFamily: 'Roboto', hintColor: const Color(0xFFd0cece)),
      title: AppConfig.isBookingMode ? 'Business Booking' : 'Food Delivery',
      home: const HomePage(),
      routes: <String, WidgetBuilder>{
        '/signin': (BuildContext context) => const SignInPage(),
        '/signup': (BuildContext context) => const SignUpPage(),
      },
    );
  }
}
