import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/config/app_config.dart';
import 'package:flutter_app/data/sample_data.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/models/business.dart';
import 'package:flutter_app/models/service.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/pages/SignInPage.dart';
import 'package:flutter_app/repositories/booking_repository.dart';
import 'package:flutter_app/widgets/BestFoodWidget.dart';
import 'package:flutter_app/widgets/BottomNavBarWidget.dart';
import 'package:flutter_app/widgets/PopularFoodsWidget.dart';
import 'package:flutter_app/widgets/SearchWidget.dart';
import 'package:flutter_app/widgets/TopMenus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BookingRepository _repository = BookingRepository();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final String title = AppConfig.isBookingMode
        ? localizations.translate('home.title.booking')
        : localizations.translate('home.title.food');
    final List<TopMenuItemData> menuItems = SampleData.getTopMenuData();
    final List<RecommendedItem> recommendedItems =
        SampleData.getRecommendedItems();
    final List<Business> businesses = SampleData.getBusinesses();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
              color: Color(0xFF3a3737),
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Color(0xFF3a3737),
              ),
              onPressed: () {
                Navigator.push(context, ScaleRoute(page: const SignInPage()));
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SearchWidget(
              hintText: AppConfig.isBookingMode
                  ? localizations.translate('home.search.booking')
                  : localizations.translate('home.search.food'),
            ),
            TopMenus(items: menuItems),
            PopularFoodsWidget(
              items: recommendedItems,
              onTap: (RecommendedItem item) {
                if (AppConfig.isBookingMode) {
                  _openBookingDetails(context, item);
                } else {
                  Navigator.push(
                      context, ScaleRoute(page: const FoodDetailsPage()));
                }
              },
            ),
            BestFoodWidget(
              businesses: businesses,
              onTap: (Business business) {
                if (AppConfig.isBookingMode) {
                  final Service service = _repository
                      .getServicesForBusiness(business.id)
                      .first;
                  _openBookingDetails(
                      context,
                      RecommendedItem(
                        titleKey: service.name,
                        subtitleKey: business.description ?? '',
                        price: service.price,
                        duration: service.durationMinutes,
                        imageAsset: business.photos.isNotEmpty
                            ? business.photos.first
                            : 'assets/images/bestfood/ic_best_food_8.jpeg',
                      ));
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBarWidget(),
    );
  }

  void _openBookingDetails(BuildContext context, RecommendedItem item) {
    final List<Business> businesses = _repository.getBusinesses();
    if (businesses.isEmpty) {
      return;
    }

    Business? selectedBusiness;
    for (final Business candidate in businesses) {
      if (candidate.services.any((Service service) => service.name == item.titleKey)) {
        selectedBusiness = candidate;
        break;
      }
    }
    selectedBusiness ??= businesses.first;

    final List<Service> services =
        _repository.getServicesForBusiness(selectedBusiness.id);
    if (services.isEmpty) {
      return;
    }

    final Service service = services.firstWhere(
      (Service s) => s.name == item.titleKey,
      orElse: () => services.first,
    );

    Navigator.push(
      context,
      ScaleRoute(
        page: FoodDetailsPage(
          business: selectedBusiness,
          service: service,
        ),
      ),
    );
    debugPrint('[analytics] ${AppConfig.isBookingMode ? 'view_business' : 'view_food'}:${selectedBusiness.id}:${service.id}');
  }
}
