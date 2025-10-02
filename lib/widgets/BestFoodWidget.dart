import 'package:flutter/material.dart';
import 'package:flutter_app/config/app_config.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/models/business.dart';

class BestFoodWidget extends StatelessWidget {
  const BestFoodWidget({super.key, this.businesses, this.onTap});

  final List<Business>? businesses;
  final ValueChanged<Business>? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          const BestFoodTitle(),
          Expanded(
            child: BestFoodList(
              businesses: businesses,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class BestFoodTitle extends StatelessWidget {
  const BestFoodTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final String titleKey =
        AppConfig.isBookingMode ? 'home.section.best.booking' : 'home.section.best.food';
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            localizations.translate(titleKey),
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF3a3a3b),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class BestFoodTiles extends StatelessWidget {
  const BestFoodTiles({
    super.key,
    required this.business,
    required this.imageUrl,
    this.onTap,
  });

  final Business business;
  final String imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final String title = AppConfig.isBookingMode
        ? localizations.translate(business.name)
        : business.name;
    final String subtitle = AppConfig.isBookingMode
        ? localizations.translate(business.description ?? '')
        : (business.description ?? '');
    final String ratingLabel = AppConfig.isBookingMode
        ? '${business.rating.toStringAsFixed(1)} · ${business.ratingCount}'
        : '${business.rating.toStringAsFixed(1)} (${business.ratingCount})';

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
            decoration: const BoxDecoration(boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0xFFfae3e2),
                blurRadius: 15.0,
                offset: Offset(0, 0.75),
              ),
            ]),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 1,
              margin: const EdgeInsets.all(5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF3a3a3b),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6e6e71),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ratingLabel,
                  style: const TextStyle(
                    color: Color(0xFF6e6e71),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class BestFoodList extends StatelessWidget {
  const BestFoodList({super.key, this.businesses, this.onTap});

  final List<Business>? businesses;
  final ValueChanged<Business>? onTap;

  @override
  Widget build(BuildContext context) {
    if (AppConfig.isBookingMode) {
      final List<Business> items = businesses ?? const <Business>[];
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final Business business = items[index];
          final String image = business.photos.isNotEmpty
              ? business.photos.first
              : 'assets/images/bestfood/ic_best_food_8.jpeg';
          return BestFoodTiles(
            business: business,
            imageUrl: image,
            onTap: onTap == null ? null : () => onTap!(business),
          );
        },
      );
    }

    return ListView(
      children: const <Widget>[
        BestFoodTiles(
          business: Business(
            id: 'food_fried_egg',
            name: 'Fried Egg',
            description: 'Classic breakfast with veggies',
            rating: 4.9,
            ratingCount: 200,
          ),
          imageUrl: 'assets/images/bestfood/ic_best_food_8.jpeg',
        ),
        BestFoodTiles(
          business: Business(
            id: 'food_mixed_vegetable',
            name: 'Mixed vegetable',
            description: 'Healthy mix of greens',
            rating: 4.9,
            ratingCount: 100,
          ),
          imageUrl: 'assets/images/bestfood/ic_best_food_9.jpeg',
        ),
        BestFoodTiles(
          business: Business(
            id: 'food_salad_chicken',
            name: 'Salad with chicken meat',
            description: 'Fresh salad with grilled chicken',
            rating: 4.0,
            ratingCount: 50,
          ),
          imageUrl: 'assets/images/bestfood/ic_best_food_10.jpeg',
        ),
        BestFoodTiles(
          business: Business(
            id: 'food_new_mixed_salad',
            name: 'New mixed salad',
            description: 'Crunchy salad bowl',
            rating: 4.0,
            ratingCount: 100,
          ),
          imageUrl: 'assets/images/bestfood/ic_best_food_5.jpeg',
        ),
      ],
    );
  }
}
