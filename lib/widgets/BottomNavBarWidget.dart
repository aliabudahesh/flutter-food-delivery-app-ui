import 'package:flutter/material.dart';
import 'package:flutter_app/config/app_config.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBarWidget extends StatefulWidget {
  const BottomNavBarWidget({super.key});

  @override
  State<BottomNavBarWidget> createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFFfd5352),
      onTap: _onItemTapped,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppConfig.isBookingMode
              ? localizations.translate('app.title.booking')
              : localizations.translate('app.title.food'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.near_me),
          label: localizations.translate('home.menu.nearby'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.event_note),
          label: AppConfig.isBookingMode
              ? localizations.translate('home.menu.summary')
              : localizations.translate('cart.title'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(FontAwesomeIcons.user),
          label: localizations.translate('home.menu.account'),
        ),
      ],
    );
  }
}
